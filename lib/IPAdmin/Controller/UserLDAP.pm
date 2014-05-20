# Copyright 2011 by the IPAdmin Team
#
# This library is free software. You can redistribute it and/or modify
# it under the same terms as Perl itself.
package IPAdmin::Controller::UserLDAP;
use Moose;
use namespace::autoclean;
use IPAdmin::Form::UserLDAP;
use IPAdmin::Form::SetManager;
use Data::Dumper;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

IPAdmin::Controller::UserLDAP - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index

=cut

sub index : Path : Args(0) {
    my ( $self, $c ) = @_;
    $c->response->redirect($c->uri('userldap/list'));
    $c->detach();
}

=head2 base

=cut

sub base : Chained('/') : PathPart('userldap') : CaptureArgs(0) {
    my ( $self, $c ) = @_;
    $c->stash( resultset => $c->model('IPAdminDB::UserLDAP') );
}

=head2 object

=cut

sub object : Chained('base') : PathPart('username') : CaptureArgs(1) {
    my ( $self, $c, $cn ) = @_;
    #force lower case
    $cn = lc($cn);
    $c->stash( username => $cn );

    my $local_user = $c->stash->{resultset}->search({username => $cn })->single;
    
    $c->stash( object => $local_user ) if($local_user);
    if ( !$local_user  ) {
        $c->stash( error_msg => "Utente $cn non trovato nel database locale. Inserisci alcune informazioni prima di continuare" );
        $c->detach('/userldap/create');
    }
}

=head2 list

=cut

sub list : Chained('base') : PathPart('list') : Args(0) {
    my ( $self, $c ) = @_;

    my $user_schema = $c->stash->{resultset};
    my @user_table = $c->stash->{resultset}->all;

    $c->stash( userldap_table => \@user_table );
    $c->stash( template       => 'userldap/list.tt' );
}

=head2 view

=cut

sub view : Chained('object') : PathPart('view') : Args(0) {
    my ( $self, $c ) = @_;
    my @requests;     

    my @managed_area = $c->stash->{'object'}->managed_area;

    foreach my $area (@managed_area){
        @requests = $c->model("IPAdminDB::IPRequest")->search({area => $area->id})->all
    }

    
    $c->stash( requests => \@requests );
    $c->stash( template => 'userldap/view.tt' );
}

=head2 edit

=cut

sub edit : Chained('object') : PathPart('edit') : Args(0) {
    my ( $self, $c ) = @_;     
    $c->forward('save');
}

=head2 save

# Handle create and edit resources

=cut

 sub save : Private {
     my ( $self, $c ) = @_;
     my $mail = $c->user->mail || '';
     my $cn   = lc($c->user->username);

     my $item = $c->stash->{'object'} ||
	 $c->stash->{resultset}->new_result( {email => $mail, username => $cn} );

     #set the default backref according to the action (create or edit)
     my $def_br = $c->uri_for_action( '/userldap/view', [$cn] );
     $c->stash( default_backref => $def_br );

     my $form = IPAdmin::Form::UserLDAP->new( item => $item );
     $c->stash( form => $form, template => 'userldap/save.tt' );

     # the "process" call has all the saving logic,
     #   if it returns False, then a validation error happened

     if ( $c->req->param('discard') ) {
         $c->detach('/follow_backref');
     }
    return unless $form->process( params => $c->req->params, );

    #If it'a a new user, set the default role (role \"user\")
    unless ( defined( $c->stash->{object} ) ) {
        my $role_user = $c->model('IPAdminDB::Role')->search( { role => "user" } )->single;
        unless ($role_user) {
            $c->stash( error_msg => "Role \"user\" not defined!" );
            $c->detach('/error/index');
        }
        $c->model('IPAdminDB::UserRole')->create(
            {
                user_id => $item->id,
                role_id => $role_user->id,
            }
        );
    }

     $c->flash( message => 'Success! UserLDAP created.' );
     $c->detach('/follow_backref');
 }



=head2 create

=cut

sub create : Chained('base') : PathPart('create') : Args(0) {
     my ( $self, $c ) = @_;
     $c->forward('save');
 }

=head2 delete

=cut

sub delete : Chained('object') : PathPart('delete') : Args(0) {
    my ( $self, $c ) = @_;
    my $userldap = $c->stash->{'object'};
    my $id       = $userldap->id;
    my $name     = $userldap->username;
    $c->stash( default_backref => $c->uri_for_action('userldap/list') );

    if ( lc $c->req->method eq 'post' ) {
#        if ( $c->model('IPAdminDB::Rack')->search( { userldap => $id } )->count ) {
#            $c->flash( error_msg => 'UserLDAP is not empty. Cannot be deleted.' );
#            $c->stash( default_backref => $c->uri_for_action( 'userldap/view', [$id] ) );
#            $c->detach('/follow_backref');
#        }

        $userldap->delete;

        $c->flash( message => 'Success!!  ' . $name . ' successful deleted.' );
        $c->detach('/follow_backref');
    }
    else {
        $c->stash( template => 'generic_delete.tt' );
    }
}

=head2 switch_status

=cut

sub switch_status : Chained('object') : PathPart('switch_status') : Args(0) {
    my ( $self, $c ) = @_;
    my $user = $c->stash->{'object'};
    $user->active( !$user->active );
    $user->update;
    $c->response->redirect( $c->uri_for('/userldap/list') );
    $c->detach();
}

sub set_manager : Chained('object') : PathPart('set_manager') : Args(0) {
    my ( $self, $c ) = @_;
    my $user_id = $c->stash->{'object'}->id;
    my $item = $c->model('IPAdminDB::Area')->new_result( {manager => $user_id} );

    $c->stash(manager_id => $user_id );
     #set the default backref according to the action (create or edit)
     my $def_br = $c->uri_for_action( '/userldap/list' );
     $c->stash( default_backref => $def_br );

     my $form = IPAdmin::Form::SetManager->new( item => $item );
     $c->stash( form => $form, template => 'userldap/set_manager.tt' );

     # the "process" call has all the saving logic,
     #   if it returns False, then a validation error happened

     if ( $c->req->param('discard') ) {
         $c->detach('/follow_backref');
     }
    return unless $form->process( params => $c->req->params, );

    $c->flash( message => "L'Utente è ora un referente" );
    #Set user's roles
    my @user_roles = $c->model('IPAdminDB::UserRole')->search( { 'user_id' => $user_id } );

    foreach my $role (@user_roles){
      if($role eq "manager"){
            #l'utente è già referente
	    $c->detach('/follow_backref');
        }
     }

     #Add new roles
     my $user_role_id = $c->model('IPAdminDB::Role')->search( { 'role' => "manager"} )->single;
     if ($user_role_id) {
       $c->model('IPAdminDB::UserRole')->update_or_create(
               {
                   user_id => $user_id,
                   role_id => $user_role_id->id,
               }
           );
     }

    $c->detach('/follow_backref');
}


=head1 AUTHOR

Rigo

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
