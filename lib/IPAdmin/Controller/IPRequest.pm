# Copyright 2011 by the IPAdmin Team
#
# This library is free software. You can redistribute it and/or modify
# it under the same terms as Perl itself.
package IPAdmin::Controller::IPRequest;
use Moose;
use namespace::autoclean;
use IPAdmin::Form::IPRequest;
use Data::Dumper;
use IPAdmin::Utils;


BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

IPAdmin::Controller::IPRequest - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index

=cut

sub index : Path : Args(0) {
    my ( $self, $c ) = @_;
    $c->response->redirect('iprequest/list');
    $c->detach();
}

=head2 base

=cut

sub base : Chained('/') : PathPart('iprequest') : CaptureArgs(0) {
    my ( $self, $c ) = @_;
    $c->stash( resultset => $c->model('IPAdminDB::IPRequest') );
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

   my @iprequest_table =  map +{
            id          => $_->id,
            date        => IPAdmin::Utils::print_short_timestamp($_->date),
            area        => $_->area,
            user        => $_->user,
            state	=> $_->state,
	    },
            $c->stash->{resultset}->search({});

   $c->stash( iprequest_table => \@iprequest_table );
   $c->stash( template        => 'iprequest/list.tt' );
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
    $c->stash( template => 'iprequest/view.tt' );
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
    $c->stash( default_backref => $c->uri_for_action('/iprequest/list') );

    if ( lc $c->req->method eq 'post' ) {
        if ( $c->req->param('discard') ) {
            $c->detach('/follow_backref');
        }
        my $done = $c->forward('process_create');
        if ($done) {
            $c->flash( message => $c->stash->{message} );
            $c->stash( default_backref =>
                $c->uri_for_action( "iprequest/list" ) );
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
    my @types = $c->model('IPAdminDB::TypeRequest')->search()->all;


    $tmpl_param{realm}     = $realm;
    $tmpl_param{user}      = $user;
    $tmpl_param{fullname}  = $user->fullname;
    $tmpl_param{aree}      = \@aree;
    $tmpl_param{types}     = \@types;
    $tmpl_param{data}      = IPAdmin::Utils::print_short_timestamp(time);
    $tmpl_param{template}  = 'iprequest/create.tt';


    $c->stash(%tmpl_param);
}

sub process_create : Private {
    my ( $self, $c ) = @_;
    my $area      = $c->req->param('area');
    my $user      = $c->req->param('user');
    my $location  = $c->req->param('location');
    my $mac       = $c->req->param('mac');
    my $type      = $c->req->param('type');
    my $hostname  = $c->req->param('hostname');
    my $error;

    # check form
    $c->forward('check_ipreq_form') || return 0; 

    #state == 0 non validata
    #state == 1 convalidata
    #state == 2 archiviata

    my $ret = $c->stash->{'resultset'}->create({
                        area        => $area,
                        user        => $user,
                        location    => $location,
                        macaddress  => $mac,
                        hostname    => $hostname,
                        date        => time,
                        state       => $IPAdmin::INACTIVE,
                        type        => $type,
                           });
    if (! $ret ) {
    $c->stash->{message} = "Errore nella creazione della richiesta IP";
    return 0;
    } else {
    $c->stash->{message} = "La richiesta IP è stata creata.";
    return 1;
    }
}

sub check_ipreq_form : Private {
    my ( $self, $c) = @_;
    my $schema = $c->stash->{'resultset'};
    my $mac = $c->req->param('mac');
    my $hostname = $c->req->param('hostname');
    #my $area = $c->req->param('area'); 
    #my $referente = $c->stash->{'resultset'}->search(

     if ( $mac eq '' ) {
     	$c->stash->{message} = "Campo Mac Address obbligatorio!";
     	return 0;
     }
    #controllo formato mac address (ancora non copre aa:bb:cc:dd:ee:ff) 
     if ( $mac !~ /([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}/ 
	||$mac =~ /((aa|bb|cc|dd|ee|ff|00|11|22|33|44|55|66|77|88|99):){5}(aa|bb|cc|dd|ee|ff|00|11|22|33|44|55|66|77|88|99){2}/i ) {
     	$c->stash->{message} = "Errore nel formato del mac address! aa:aa:aa:aa:aa:aa";
     	return 0;
     }

     if ( $hostname eq '' ) {
	$c->stash->{message} = "Campo Hostname obbligatorio!";
	return 0;
     }

    # if ( $name !~ /^\w[\w-]*$/ ) {
    # $c->stash->{message} = "Invalid name";
    # return 0;
    # }

     if ($schema->search({ macaddress => $mac})->count() > 0 ) {
     $c->stash->{message} = "Mac Address già registrato!";
     $c->log->error("duplicated $mac");
     return 0;
     }

    return 1;
}

sub validate : Chained('object') : PathPart('validate') : Args(0) {
    my ( $self, $c ) = @_;
    my $req = $c->stash->{'object'};
    $c->stash( default_backref => $c->uri_for_action('iprequest/list') );

    if ( lc $c->req->method eq 'post' ) {
        if ( $c->req->param('discard') ) {
            $c->detach('/follow_backref');
        }
        my $done = $c->forward('process_validate');
        if ($done) {
            $c->flash( message => $c->stash->{message} );
            $c->stash( default_backref =>
                $c->uri_for_action( "iprequest/list" ) );
            $c->detach('/follow_backref');
        }
    }


    #set form defaults
    my %tmpl_param;
    $tmpl_param{template}  = 'iprequest/validate.tt';
    $tmpl_param{data}      = IPAdmin::Utils::print_short_timestamp($req->date);
    #a regime deve proporre un indirizzo IP tra le subnet associate 
    #all'area
    #$tmpl_param{ipaddr}  = ?

    $c->stash(%tmpl_param);

}

sub process_validate : Private {
    my ( $self, $c ) = @_;
    #my $ipaddr       = '151.100.1.1'; # $c->req->param('ipaddr'); 
    my $subnet = '14'; # $c->req->param('subnet');
    my $host = '200'; # $c->req->param('host');
    my $error;   

    if (!defined $subnet) {
    $c->stash->{message} = "L'indirizzo IP è un campo obbligatorio";
    return 0;
    }
    #Cambia lo stato dell'iprequest
    $c->stash->{object}->state($IPAdmin::PREACTIVE);
    $c->stash->{object}->subnet($subnet);
    $c->stash->{object}->host($host);
    $c->stash->{object}->update; 
    #Crea l'assegnamento
    my $ret = $c->model('IPAdminDB::IPAssignement')->create({
                        state       => $IPAdmin::INACTIVE,
                        date_in     => time,
                        ip_request  => $c->stash->{'object'}->id,
			active 	    => '1',
                        });
    if (! $ret ) {
    $c->stash->{message} = "Errore nella creazione dell'assegnazione IP";
    return 0;
    } else {
    $c->stash->{message} = "L'assegnazione' IP è stata creata. Ora....simone completa";
    return 1;
    }
}


sub activate : Chained('object') : PathPart('activate') : Args(0) {
    my ( $self, $c ) = @_;
    my $req = $c->stash->{'object'};
    $c->stash( default_backref => $c->uri_for_action('iprequest/list') );

    if ( lc $c->req->method eq 'post' ) {
        if ( $c->req->param('discard') ) {
            $c->detach('/follow_backref');
        }
        my $done = $c->forward('process_activate');
        if ($done) {
            $c->flash( message => $c->stash->{message} );
            $c->stash( default_backref =>
                $c->uri_for_action( "iprequest/list" ) );
            $c->detach('/follow_backref');
        }
    }

    #set form defaults
    my %tmpl_param;
    $tmpl_param{template}  = 'iprequest/activate.tt';
    $tmpl_param{data}      = IPAdmin::Utils::print_short_timestamp($req->date);

    $c->stash(%tmpl_param);

}


sub process_activate : Private {
    my ( $self, $c ) = @_;
    my $error;

    #Cambia lo stato dell'iprequest
    $c->stash->{object}->state($IPAdmin::ACTIVE);
    $c->stash->{object}->update;
    #Cambia lo stato dell'assegnamento corrente
    my $ret = $c->model('IPAdminDB::IPAssignement')->search({active=>'1'})->update({
                        state       => $IPAdmin::ACTIVE,
                        date_in     => time,
                        #ip_request  => $c->stash->{'object'}->id,
                        });
    if (! $ret ) {
    $c->stash->{message} = "Errore nell'aggiornamento dell'assegnazione IP";
    return 0;
    } else {
    $c->stash->{message} = "L'assegnazione' IP è stata attivata. Ora....simone completa";
    return 1;
    }
}



=head2 delete
il delete deve archiviare prima la richiesta e poi cancellarla. 
(quindi spostare la richiesta in ArchivedRequest). Successivamente elimina l'assegnazione IP
=cut

sub delete : Chained('object') : PathPart('delete') : Args(0) {
     my ( $self, $c ) = @_;
   my $iprequest = $c->stash->{'object'};
   $c->stash( default_backref => $c->uri_for_action('iprequest/list') );

  
    if ( lc $c->req->method eq 'post' ) {
        #TODO invalidare ogni assegnazione associata alla richiesta

         $iprequest->state($IPAdmin::DELETED);
         $iprequest->update;
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
