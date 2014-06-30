# Copyright 2011 by the IPAdmin Team
#
# This library is free software. You can redistribute it and/or modify
# it under the same terms as Perl itself.
package IPAdmin::Controller::ManagerRequest;
use Moose;
use namespace::autoclean;
use Data::Dumper;
use IPAdmin::Utils;


BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

IPAdmin::Controller::ManagerRequest - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index

=cut

sub index : Path : Args(0) {
    my ( $self, $c ) = @_;
    $c->response->redirect($c->uri_for('/managerrequest/list'));
    $c->detach();
}

=head2 base

=cut

sub base : Chained('/') : PathPart('managerrequest') : CaptureArgs(0) {
    my ( $self, $c ) = @_;
    $c->stash( resultset => $c->model('IPAdminDB::ManagerRequest') );
}

=head2 object

=cut

sub object : Chained('base') : PathPart('id') : CaptureArgs(1) {
    my ( $self, $c, $id ) = @_;

    $c->stash( object => $c->stash->{resultset}->find($id) );

    if ( !$c->stash->{object} ) {
        $c->stash( error_msg => "Object $id not found!" );
        $c->detach('/error/index');
    }
}


sub tot_assigned_ip :Private {
    my ( $self, $c, $area ) = @_;
    my $count = 0;
    return 0 unless(defined $area->building->vlan);

    foreach my $subnet ($area->building->vlan->map_subnet){
        $count += $c->model("IPAdminDB::IPRequest")->search({state => $IPAdmin::ACTIVE,
                                                            subnet => $subnet->id})->count;
    }

    return $count;
}

=head2 list

=cut

sub list : Chained('base') : PathPart('list') : Args(0) {
   my ( $self, $c ) = @_;

   my @managerrequest_table =  map +{
            id           => $_->id,
            date         => IPAdmin::Utils::print_short_timestamp($_->date),
            date_in      => $_->date_in  ? IPAdmin::Utils::print_short_timestamp($_->date_in) : '',
            date_out     => $_->date_out ? IPAdmin::Utils::print_short_timestamp($_->date_out) : '',
            area         => $_->area,
            dir_fullname => $_->dir_fullname,
            dir_phone    => $_->dir_phone,
            dir_email    => $_->dir_email,
            user         => $_->user,
            state   	 => $_->state,
            n_ip         => $self->tot_assigned_ip($c,$_->area),
	    },  $c->stash->{resultset}->search({});
   
   $c->stash( request_table => \@managerrequest_table );
   $c->stash( template        => 'managerrequest/list.tt' );
}

=head2 view

=cut

sub view : Chained('object') : PathPart('view') : Args(0) {
    my ( $self, $c ) = @_;
    my $req = $c->stash->{object};
    $c->stash( date    => IPAdmin::Utils::print_short_timestamp($req->date));
    $req->date_in  and $c->stash( date_in => IPAdmin::Utils::print_short_timestamp($req->date_in));
    $req->date_out and $c->stash( date_out => IPAdmin::Utils::print_short_timestamp($req->date_out));

    $c->stash( template => 'managerrequest/view.tt' );
}

sub print : Chained('object') : PathPart('print') : Args(0) {
    my ( $self, $c ) = @_;
    my $req = $c->stash->{object};
    $c->stash( date    => IPAdmin::Utils::print_short_timestamp($req->date));
    $req->date_in  and $c->stash( date_in => IPAdmin::Utils::print_short_timestamp($req->date_in));
    $req->date_out and $c->stash( date_out => IPAdmin::Utils::print_short_timestamp($req->date_out));

    $c->stash( template => 'managerrequest/print.tt' );
}


=head2 edit
TODO 
=cut

sub edit : Chained('object') : PathPart('edit') : Args(0) {
    my ( $self, $c ) = @_;     
    my $req = $c->stash->{object};
    my ($realm, $user) = IPAdmin::Utils::find_user($self,$c,$c->user->username);

    $c->stash( default_backref => $c->uri_for_action('/managerrequest/list') );

    if($req->state != $IPAdmin::NEW){
        $c->flash( message => 'Solo le richieste non ancora validate possono essere modificate.');
        $c->detach('/follow_backref');
    }

    if($req->user->id != $user->id ){
        $c->flash( message => 'Si possono modificare solo le proprie richieste');
        $c->detach('/follow_backref');
    }

    if ( lc $c->req->method eq 'post' ) {
        if ( $c->req->param('discard') ) {
            $c->detach('/follow_backref');
        }
        my $done = $c->forward('process_edit');
        if ($done) {
            $c->flash( message => $c->stash->{message} );
            $c->stash( default_backref =>
                $c->uri_for_action( "managerrequest/list" ) );
            $c->detach('/follow_backref');
        }
    }
    #set form defaults
    my %tmpl_param;
    my @users;
    if($realm eq "normal") {
        @users = $c->model('IPAdminDB::UserLDAP')->search({})->all;
        $tmpl_param{users}      = \@users;
    }
    #TODO ordinamento aree per nome dipartimento
    my @aree  = $c->model('IPAdminDB::Area')->search({}, {order_by => 'department'})->all;


    $tmpl_param{realm}        = $realm;
    $tmpl_param{user}         = $req->user;
    $tmpl_param{aree}         = \@aree;
    $tmpl_param{data}         = IPAdmin::Utils::print_short_timestamp(time);
    $tmpl_param{dir_fullname} = $req->dir_fullname;
    $tmpl_param{dir_phone}    = $req->dir_phone;
    $tmpl_param{dir_email}    = $req->dir_email;
    $tmpl_param{skill}        = $req->skill;
    $tmpl_param{area}         = $req->area->id;




    $tmpl_param{template}  = 'managerrequest/edit.tt';


    $c->stash(%tmpl_param);
}

sub process_edit : Private { 
    my ( $self, $c ) = @_;
    my $area      = $c->req->param('area');
    my $user      = $c->req->param('user');
    my $dir_name  = $c->req->param('dir_fullname');
    my $dir_phone = $c->req->param('dir_phone');
    my $dir_email = $c->req->param('dir_email');
    my $skill     = 1; #$c->req->param('skill');
    my $req       = $c->stash->{'object'};
    my $error;

    # check form
    $c->forward('check_manreq_form') || return 0; 

    $user and $req->user($user);
    my $ret = $req->update({
                        area          => $area,
                        dir_fullname  => $dir_name,
                        dir_phone     => $dir_phone,
                        dir_email     => $dir_email,
                        skill         => $skill, 
                        });
    if (! $ret ) {
    $c->stash->{message} = "Errore nella creazione della richiesta referente";
    return 0;
    } else {
    $c->stash->{message} = "La richiesta per il referente è stata modificata.";
    return 1;
    }
}

sub create : Chained('base') : PathPart('create') : Args() {
    my ( $self, $c, $parent ) = @_;
    my $id;
    my ($realm, $user) = IPAdmin::Utils::find_user($self,$c,$c->user->username);
    $c->stash( default_backref => $c->uri_for_action('userldap/view',[$user->username]) );

    if ( lc $c->req->method eq 'post' ) {
        if ( $c->req->param('discard') ) {
            $c->detach('/follow_backref');
        }
        my $done = $c->forward('process_create');
        if ($done) {
            $c->flash( message => $c->stash->{message} );
            $c->detach('/follow_backref');
        }
    }
    #set form defaults
    my %tmpl_param;
    my @users;
    if($realm eq "normal") {
            $c->flash( error_msg => "Spiacente, solo un utente strutturato può fare richiesta di diventare referente." );
            $c->stash( default_backref => $c->uri_for_action('iprequest/list') );
            $c->detach('/follow_backref');
    }
    #TODO ordinamento aree per nome dipartimento
    my @aree  = $c->model('IPAdminDB::Area')->search({},{join => 'department', prefetch => 'department', order_by => 'department.name'})->all;

    $tmpl_param{realm}     = $realm;
    $tmpl_param{user}      = $user;
    $tmpl_param{aree}      = \@aree;
    $tmpl_param{data}      = IPAdmin::Utils::print_short_timestamp(time);
    $tmpl_param{dir_fullname} = $c->req->param('dir_fullname');
    $tmpl_param{dir_phone}    = $c->req->param('dir_phone');
    $tmpl_param{dir_email}    = $c->req->param('dir_email');
    $tmpl_param{template}  = 'managerrequest/create.tt';
    $c->stash(%tmpl_param);
}

sub process_create : Private {
    my ( $self, $c ) = @_;
    my $area      = $c->req->param('area');
    my $user      = $c->req->param('user');
    my $dir_name  = $c->req->param('dir_fullname');
    my $dir_phone = $c->req->param('dir_phone');
    my $dir_email = $c->req->param('dir_email');

    my $error;

    # check form
    $c->forward('check_manreq_form') || return 0; 
 
    #prima di tutto controlla se per l'area in oggetto non esiste già un referente
    #in caso  va abortita l'attivazione della nuova richiesta
    my $result = $c->model('IPAdminDB::Area')->find($area);

    if(defined  $result->manager){
        $c->flash( message => "Non è stato possibile creare la richiesta. Esiste già un referente per il dipartimento di ".$result->department->name.
        " presso ".$result->building->name."." );
        $c->detach('/follow_backref');
    }

    #state == 0 non validata
    #state == 1 convalidata
    #state == 2 archiviata

    my $ret = $c->stash->{'resultset'}->create({
                        area          => $area,
                        dir_fullname  => $dir_name,
                        dir_phone     => $dir_phone,
                        dir_email     => $dir_email,
                        date          => time,
                        state         => $IPAdmin::NEW,
                        user          => $user,
                        skill         => 1,#$skill 
                        });
    if (! $ret ) {
    $c->stash->{message} = "Errore nella creazione della richiesta referente";
    return 0;
    } else {
    $c->stash->{message} = "La richiesta per il referente è stata creata.";
    return 1;
    }
}

sub check_manreq_form : Private {
    my ( $self, $c) = @_;
    my $schema = $c->stash->{'resultset'};
    my $name   = $c->req->param('dir_fullname');
    my $tel    = $c->req->param('dir_phone');
    my $email  = $c->req->param('dir_email'); 
    my %error;

    if ( $name eq '' ) {
        $error{dir_fullname} = "Indicare un nome del responsabile della struttura";
    }
    if ( $name !~ /^\w+[\s\w]+$/ ) {
        $error{dir_fullname} = "Il nome non può contenere caratteri speciali";
    }

    if ( $tel !~ /^\d+$/ ) {
        $error{dir_phone} = "Formato non valido";
    }
    if ( $email !~ /^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$/ ) {
        $error{dir_email} = "Formato non valido";
    }

    $c->stash(error => \%error) and return 0 if(scalar keys(%error));
    
    return 1;
}



sub activate : Chained('object') : PathPart('activate') : Args(0) {
    my ( $self, $c ) = @_;
    my $req = $c->stash->{'object'};
    $c->stash( default_backref => $c->uri_for_action( "managerrequest/list"));

 
     if ( lc $c->req->method eq 'post' ) {
        my $done = $c->forward('process_activate');
        $c->flash( message => $c->stash->{message} );
        $c->stash( default_backref =>
        $c->uri_for_action( "managerrequest/view",[$req->id] ) );
        $c->detach('/follow_backref');
    }
    else{
        $c->stash( template => 'generic_confirm.tt' );
    }
}


sub process_activate : Private {
    my ( $self, $c ) = @_;
    my $error;
    my $req  = $c->stash->{'object'};
    my $user = $c->stash->{'object'}->user;
    
    #prima di tutto controlla se per l'area in oggetto non esiste già un referente
    #in caso  va abortita l'attivazione della nuova richiesta
    if(defined  $req->area->manager){
        $c->flash( message => "Non è stato possibile autorizzare la richiesta. Esiste già un referente per il dipartimento di ".$req->area->department->name.
        " presso ".$req->area->building->name."." );
        $c->stash( default_backref =>
        $c->uri_for_action( "managerrequest/list" ) );
        $c->detach('/follow_backref');
    }

    #Aggiusta le date
    ##TODO se la richiestra è scaduta reimposta date

    #Cambia lo stato dell'managerrequest
    $req->state($IPAdmin::ACTIVE);
    $req->date_in(time);
    $req->date_out(time + 63113852);
    my $ret1 =$req->update;

    #aggiunge referente all'area
    $req->area->manager($req->user->id);
    $req->area->update;
    my $ret2;
     #Add new roles
     my $user_role_id = $c->model('IPAdminDB::Role')->search( { 'role' => "manager"} )->single;
     if ($user_role_id) {
       $ret2 = $c->model('IPAdminDB::UserRole')->update_or_create(
               {
                   user_id => $user->id,
                   role_id => $user_role_id->id,
               }
           );
     }


    if (! ($ret1 and $ret2) ) {
    $c->stash->{message} = "Errore nell'aggiornamento dell'assegnazione IP";
    return 0;
    } else {
    $c->stash->{message} = "La richiesta del referente è stata attivata. ".$user->fullname." è ora un referente.";
    }

}



=head2 delete

=cut

sub delete : Chained('object') : PathPart('delete') : Args(0) {
     my ( $self, $c ) = @_;
    my $req = $c->stash->{'object'};
    $c->stash( default_backref => $c->uri_for_action( "managerrequest/list" ));
    my $user = $req->user;
  
    if($req->state == $IPAdmin::ARCHIVED){
        $c->flash( message => 'Richiesta già archiviata.');
    $c->detach('/follow_backref');
    }


    if ( lc $c->req->method eq 'post' ) {
        #Archivia la richiesta
        $req->state($IPAdmin::ARCHIVED);
        $req->date_out(time);
        $req->update;
        #resetta referente dell'area in cui l'utente era referente
        $req->area->manager(undef);
        $req->area->update;

        #se era l'ultima area gestita, allora elimina il ruolo di manager
        if(defined($user->managed_area)){
        my $user_role_id = $c->model('IPAdminDB::Role')->search( { 'role' => "manager"} )->single;
        if ($user_role_id) {
        my $ret = $c->model('IPAdminDB::UserRole')->search(
               {
                   user_id => $user->id,
                   role_id => $user_role_id->id,
               }
           )->delete;
          }
        }
    $c->flash( message => 'Richiesta archiviata. '.$user->fullname." non è più un referente della struttra di "
        .$req->area->building->name." presso ".$req->area->department->name);
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
