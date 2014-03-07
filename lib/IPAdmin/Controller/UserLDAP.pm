# Copyright 2011 by the IPAdmin Team
#
# This library is free software. You can redistribute it and/or modify
# it under the same terms as Perl itself.
package IPAdmin::Controller::UserLDAP;
use Moose;
use namespace::autoclean;
use IPAdmin::Form::UserLDAP;
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
    $c->response->redirect('userldap/list');
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

sub object : Chained('base') : PathPart('id') : CaptureArgs(1) {
    my ( $self, $c, $cn ) = @_;
    $c->stash( username => $cn );

    my $local_user = $c->stash->{resultset}->search({username => $cn})->single;
    
    $c->stash( user => $local_user ) if($local_user);
    if ( !$local_user  ) {
        $c->stash( error_msg => "User $cn not found. You must provide some information before continue..." );
        $c->detach('/userldap/create');
    }
}

=head2 list

=cut

sub list : Chained('base') : PathPart('list') : Args(0) {
    my ( $self, $c ) = @_;

    my $user_schema = $c->stash->{resultset};

    $c->stash( template       => 'userldap/list.tt' );
}

=head2 view

=cut

sub view : Chained('object') : PathPart('view') : Args(0) {
    my ( $self, $c ) = @_;

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
     my $cn   = $c->stash->{'username'} || '';

     my $item = $c->stash->{'user'} ||
	$c->stash->{resultset}->new_result( {email => $mail, username => $cn} );

     #set the default backref according to the action (create or edit)
     my $def_br = $c->uri_for('/userldap/checkrole');
     $c->stash( default_backref => $def_br );

     my $form = IPAdmin::Form::UserLDAP->new( item => $item );
     $c->stash( form => $form, template => 'userldap/save.tt' );

     # the "process" call has all the saving logic,
     #   if it returns False, then a validation error happened

     if ( $c->req->param('discard') ) {
         $c->detach('/follow_backref');
     }
     return unless $form->process( params => $c->req->params, );

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
    my $name     = $userldap->name;
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

=head1 AUTHOR

Rigo

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
