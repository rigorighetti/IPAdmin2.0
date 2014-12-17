# Copyright 2011 by the IPAdmin Team
#
# This library is free software. You can redistribute it and/or modify
# it under the same terms as Perl itself.
package IPAdmin::Controller::UserLDAP;
use Moose;
use namespace::autoclean;
use IPAdmin::Form::UserLDAP;
use IPAdmin::Form::SetManager;
use IPAdmin::Utils qw(print_short_timestamp);

use Data::Dumper;

BEGIN { extends 'Catalyst::Controller'; }

with 'IPAdmin::ControllerRole::JQDatatable';

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
    my ($realm, $user) = IPAdmin::Utils::find_user($self,$c,$c->user->username);
    $c->stash( default_backref => $c->uri_for_action( 'userldap/view', [$user->username] ) );
    $realm eq "normal" and $c->stash( default_backref => $c->uri_for_action('iprequest/list'));
    $c->detach('/follow_backref');
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
    my ($realm, $user) = IPAdmin::Utils::find_user($self,$c,$c->user->username);



    if($realm  eq "ldap" and defined $user ){
        $c->detach('/access_denied') if($cn ne $user->username);
    }
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

    # my $user_schema = $c->stash->{resultset};
    # my @user_table = $user_schema->search({});

    # $c->stash( userldap_table => \@user_table );
    $c->stash( template       => 'userldap/list.tt' );
}

=head2 listmanager

=cut

sub listmanager : Chained('base') : PathPart('listmanager') : Args(0) {
    my ( $self, $c ) = @_;

    my $user_schema = $c->stash->{resultset};
    my @man_table   = $user_schema->search({},{prefetch => 'is_manager', group_by => 'username'});


    $c->stash( man_table => \@man_table );
    $c->stash( template  => 'userldap/listmanager.tt' );
}


=head2 view

=cut

sub view : Chained('object') : PathPart('view') : Args(0) {
    my ( $self, $c ) = @_;
    my @requests;     
    my @myrequests; 
    my @myservice_requests; 
    my @service_requests;
    my $date_myreq = {};
    my $date_req = {};
    my $date_ser = {};
    my $id = $c->stash->{'object'}->id;

    my ($e,$it);

    my @managed_area = $c->stash->{'object'}->managed_area;
    foreach my $area (@managed_area){
        $it = $c->model("IPAdminDB::IPRequest")->
            search({-and => [area => $area->id, state => {"!=" => $IPAdmin::ARCHIVED}]},
                   {prefetch => [qw(type user ),{area => ['building','department','manager']}],
                    select   => [qw(id date subnet user.fullname user.id type.type area.department area.building
                              area.manager macaddress area.department hostname state subnet host )]
                });
        while($e = $it->next){
            $date_req->{$e->id} = print_short_timestamp($e->date);
            if(defined $e->type->service_manager){
                push @myservice_requests, $e;
                next;
            }
            push @requests, $e;  
        }
    }

    @myrequests = $c->model("IPAdminDB::IPRequest")->search( {user => $id },
                {prefetch => [qw(type subnet),{area => ['building','department','manager']}],
                 select   => [qw(id date type.type area.department area.building
                              area.manager macaddress area.department hostname state subnet host )]
                });

    my @myaliases;
    foreach my $i (@myrequests){
        $date_myreq->{$i->id} = print_short_timestamp($i->date);
        foreach my $alias ($i->map_alias){
            push @myaliases, $alias;
        }
    }

    my @managed_services = $c->stash->{'object'}->managed_services;
    foreach my $service (@managed_services){
        $it = $c->model("IPAdminDB::IPRequest")->search({'type.service_manager' => $c->stash->{'object'}->id },
                {prefetch => [qw(type subnet),{area => ['building','department','manager']}],
                 select   => [qw(id date type.type area.department area.building
                              area.manager macaddress area.department hostname state subnet host )] });
        while($e = $it->next){
        $date_ser->{$e->id} = print_short_timestamp($e->date);
        push @service_requests, $e;
        }
    }
    my @managerrequest_table =  map +{
            id           => $_->id,
            date         => IPAdmin::Utils::print_short_timestamp($_->date),
            date_in      => $_->date_in  ? IPAdmin::Utils::print_short_timestamp($_->date_in) : '',
            date_out     => $_->date_out ? IPAdmin::Utils::print_short_timestamp($_->date_out) : '',
            department   => $_->department || '',
            dir_fullname => $_->dir_fullname || '',
            dir_phone    => $_->dir_phone || '',
            dir_email    => $_->dir_email || '',
            state        => $_->state,
       },  $c->model('IPAdminDB::ManagerRequest')->search({user => $id }, {prefetch => ['department', 'user']});
   
   $c->stash( request_table => \@managerrequest_table );
   $c->stash(date_req      => $date_req);
   $c->stash(date_myreq    => $date_myreq);
   $c->stash( managed_area => \@managed_area );
   $c->stash( requests     => \@requests );
   $c->stash( myrequests   => \@myrequests );
   $c->stash( myservice_requests   => \@myservice_requests );
   $c->stash( service_requests     => \@service_requests );
   $c->stash( myaliases    => \@myaliases );
   $c->stash( template     => 'userldap/view.tt' );
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
     my $cn   = $c->stash->{'username'};

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
#     my $userldap = $c->stash->{'object'};
#     my $id       = $userldap->id;
#     my $name     = $userldap->username;
#     my ($realm, $user) = IPAdmin::Utils::find_user($self,$c,$c->user->username);
#     $c->stash( default_backref => $c->uri_for_action('userldap/view'), lc($user->username));
#     $c->stash( default_backref => $c->uri_for_action('iprequest/list') ) if( $realm eq  "normal" );
    
#     if ( lc $c->req->method eq 'post' ) {
# #        if ( $c->model('IPAdminDB::Rack')->search( { userldap => $id } )->count ) {
# #            $c->flash( error_msg => 'UserLDAP is not empty. Cannot be deleted.' );
# #            $c->stash( default_backref => $c->uri_for_action( 'userldap/view', [$id] ) );
# #            $c->detach('/follow_backref');
# #        }

#         $userldap->delete;

#         $c->flash( message => 'Success!!  ' . $name . ' successful deleted.' );
#         $c->detach('/follow_backref');
#     }
#     else {
#         $c->stash( template => 'generic_delete.tt' );
#     }
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

=head2 list_js

=cut

sub list_js :Chained('base') :PathPart('list/js') :Args(0) {
    my ($self, $c) = @_;

    my @col_names = qw(id username fullname email); #TODO roles active

    $c->stash(col_names => \@col_names);
    my @col_searchable = qw( me.id me.username me.fullname me.email );
    $c->stash(col_searchable => \@col_searchable);

    # $c->stash(resultset_search_opt =>
    #           {prefetch => 'map_user_role'} );


    $c->stash(col_formatters => {
        id => sub {
            my ($c, $rs)= @_;
            return $rs->id;
        },
        username => sub {
            my ($c, $rs)= @_;
            return'<a id="click_ref" href="' .
              $c->uri_for_action('/userldap/view',  [ $rs->username ]) .
                '">' . $rs->username . '</a>';
        },
        fullname => sub {
            my ($c, $rs)= @_;
            return $rs->fullname;
        },
        email => sub {
            my ($c, $rs)= @_;
            return $rs->email;
        },
    });

    $c->detach("datatable_response");
}

=head1 AUTHOR

Rigo

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
