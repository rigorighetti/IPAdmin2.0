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
    $c->response->redirect('managerrequest/list');
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

=head2 list
commentata in attesa di capire come fare.
L'utente deve vedere solo le sue. (23-04-14 implementata come tab per userldap)
Il referente le sue + quelle di cui è referente divise da tab. (28-04-14 implementata come tab per userldap)
L'amministratore vede tutte le richieste insieme
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
	    },  $c->stash->{resultset}->search({});
   
   $c->stash( request_table => \@managerrequest_table );
   $c->stash( template        => 'managerrequest/list.tt' );
}

=head2 view

=cut

sub view : Chained('object') : PathPart('view') : Args(0) {
    my ( $self, $c ) = @_;
    my $req = $c->stash->{object};

    #Creare lista di assegnazioni per richiesta IP
    my @assignement =  map +{
            id          => $_->id,
            date_in     => IPAdmin::Utils::print_short_timestamp($_->date_in),
            #date_out    => IPAdmin::Utils::print_short_timestamp($_->date_out),
            state       => $_->state,
            },
            $req->map_assignement;


    $c->stash( data => IPAdmin::Utils::print_short_timestamp($req->date));
    $c->stash( assignement => \@assignement );
    $c->stash( template => 'managerrequest/view.tt' );
}




=head2 edit

=cut

sub edit : Chained('object') : PathPart('edit') : Args(0) {
    my ( $self, $c ) = @_;     
    my $req = $c->stash->{object};
    #TODO recuperare i dati e lasciare solo alcuni campi modificabili



}


sub create : Chained('base') : PathPart('create') : Args() {
    my ( $self, $c, $parent ) = @_;
    my $id;
    $c->stash( default_backref => $c->uri_for_action('/managerrequest/list') );

    if ( lc $c->req->method eq 'post' ) {
        if ( $c->req->param('discard') ) {
            $c->detach('/follow_backref');
        }
        my $done = $c->forward('process_create');
        if ($done) {
            $c->flash( message => $c->stash->{message} );
            $c->stash( default_backref =>
                $c->uri_for_action( "managerrequest/list" ) );
            $c->detach('/follow_backref');
        }
    }
    #set form defaults
    my %tmpl_param;
    my ($realm, $user) = IPAdmin::Utils::find_user($self,$c,$c->user->username);

    if($realm eq "normal") {
        #se non è un utente ldap ci deve stare un campo select per l'utente ldap
    }
    #TODO ordinamento aree per nome dipartimento
    my @aree  = $c->model('IPAdminDB::Area')->search({})->all;


    $tmpl_param{realm}     = $realm;
    $tmpl_param{user}      = $user;
    $tmpl_param{aree}      = \@aree;
    $tmpl_param{user}      = $user;
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

    #state == 0 non validata
    #state == 1 convalidata
    #state == 2 archiviata

    my $ret = $c->stash->{'resultset'}->create({
                        area          => $area,
                        dir_fullname  => $dir_name,
                        dir_phone     => $dir_phone,
                        dir_email     => $dir_email,
                        date          => time,
                        state         => $IPAdmin::INACTIVE,
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
    #my $hostname = $c->req->param('hostname');
    #my $area = $c->req->param('area'); 
    #my $referente = $c->stash->{'resultset'}->search(

 #    if ( $mac eq '' ) {
 #     	$c->stash->{message} = "Campo Mac Address obbligatorio!";
 #     	return 0;
 #     }
 #    #controllo formato mac address (ancora non copre aa:bb:cc:dd:ee:ff) 
 #     if ( $mac !~ /([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}/ 
	# and $mac =~ /((aa|bb|cc|dd|ee|ff|00|11|22|33|44|55|66|77|88|99):){5}(aa|bb|cc|dd|ee|ff|00|11|22|33|44|55|66|77|88|99){2}/i ) {
 #     	$c->stash->{message} = "Errore nel formato del mac address! aa:aa:aa:aa:aa:aa";
 #     	return 0;
 #     }

 #     if ( $hostname eq '' ) {
	# $c->stash->{message} = "Campo Hostname obbligatorio!";
	# return 0;
 #     }

    # if ( $name !~ /^\w[\w-]*$/ ) {
    # $c->stash->{message} = "Invalid name";
    # return 0;
    # }

     # if ($schema->search({ macaddress => $mac})->count() > 0 ) {
     # $c->stash->{message} = "Mac Address già registrato!";
     # $c->log->error("duplicated $mac");
     # return 0;
     # }

    return 1;
}



sub activate : Chained('object') : PathPart('activate') : Args(0) {
    my ( $self, $c ) = @_;
    my $req = $c->stash->{'object'};
    $c->stash( default_backref => $c->uri_for_action('managerrequest/list') );

    if ( lc $c->req->method eq 'post' ) {
        if ( $c->req->param('discard') ) {
            $c->detach('/follow_backref');
        }
        my $done = $c->forward('process_activate');
        if ($done) {
            $c->flash( message => $c->stash->{message} );
            $c->stash( default_backref =>
                $c->uri_for_action( "managerrequest/list" ) );
            $c->detach('/follow_backref');
        }
    }

    #set form defaults
    my %tmpl_param;
    $tmpl_param{template}  = 'managerrequest/activate.tt';
    $tmpl_param{data}      = IPAdmin::Utils::print_short_timestamp($req->date);

    $c->stash(%tmpl_param);

}


sub process_activate : Private {
    my ( $self, $c ) = @_;
    my $error;

    #Cambia lo stato dell'managerrequest
    $c->stash->{object}->state($IPAdmin::ACTIVE);
    $c->stash->{object}->update;
    #Aggiorna la data dell'assegnamento 

    my $ret = $c->model('IPAdminDB::IPAssignement')->search({state=>$IPAdmin::ACTIVE})->update({
                        date_in     => time,
                        });

    if (! $ret ) {
    $c->stash->{message} = "Errore nell'aggiornamento dell'assegnazione IP";
    return 0;
    } else {
    $c->stash->{message} = "L'assegnazione' IP è stata attivata.";
    return 1;
    }
}



=head2 delete
il delete deve archiviare prima la richiesta e poi cancellarla. 
(quindi spostare la richiesta in ArchivedRequest). Successivamente elimina l'assegnazione IP
=cut

sub delete : Chained('object') : PathPart('delete') : Args(0) {
     my ( $self, $c ) = @_;
   my $managerrequest = $c->stash->{'object'};
   $c->stash( default_backref => $c->uri_for_action('managerrequest/list') );

  
    if ( lc $c->req->method eq 'post' ) {
        #Archivia la richiesta
        $managerrequest->state($IPAdmin::ARCHIVED);
        $managerrequest->update;
        #chiude l'ultima assegnazione
        my $ret = $c->model('IPAdminDB::IPAssignement')->search({state=>$IPAdmin::ACTIVE})->single;

        $ret->update({
                        date_out => time,
                        state    => $IPAdmin::INACTIVE,
                        });
       
         $c->flash( message => 'Richiesta IP archiviata.' );
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
