# Copyright 2011 by the IPAdmin Team
#
# This library is free software. You can redistribute it and/or modify
# it under the same terms as Perl itself.
package IPAdmin::Controller::IPRequest;
use Moose;
use namespace::autoclean;
use Data::Dumper;
use IPAdmin::Utils qw(str_to_time);


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
L'amministratore vede tutte le richieste insieme (iprequest/list)
=cut

sub list : Chained('base') : PathPart('list') : Args(0) {
   my ( $self, $c ) = @_;

   my @iprequest_table =  map +{
        id          => $_->id,
        date        => IPAdmin::Utils::print_short_timestamp($_->date),
        area        => $_->area,
        user        => $_->user,
        state	    => $_->state,
	    type	    => $_->type->type,
	    macaddress	=> $_->macaddress,
	    hostname	=> $_->hostname,
        subnet      => $_->subnet,
        host        => $_->host,
	    }, $c->stash->{resultset}->search({});

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
            date_in     => $_->date_in  ? IPAdmin::Utils::print_short_timestamp($_->date_in) : '',
            date_out    => $_->date_out ? IPAdmin::Utils::print_short_timestamp($_->date_out) : '',
            state       => $_->state,
            },
            $req->map_assignement;

    #Creare lista degli alias per richiesta IP
    my @alias =  map +{
            id          => $_->id,
            #state       => $_->state,
            cname       => $_->cname,
            },
            $req->map_alias;


    $c->stash( data => IPAdmin::Utils::print_short_timestamp($req->date));
    $c->stash( assignement => \@assignement );
    $c->stash( alias => \@alias );
    $c->stash( template => 'iprequest/view.tt' );
}




=head2 edit

=cut

sub edit : Chained('object') : PathPart('edit') : Args(0) {
    my ( $self, $c ) = @_;     
    my $req = $c->stash->{object};
    #TODO recuperare i dati e lasciare solo alcuni campi modificabili

    my $id;
    $c->stash( default_backref => $c->uri_for_action('/iprequest/list') );
    my ($realm, $user) = IPAdmin::Utils::find_user($self,$c,$c->user->username);


    if ( lc $c->req->method eq 'post' ) {
        if ( $c->req->param('discard') ) {
            $c->detach('/follow_backref');
        }
        my $done = $c->forward('process_edit');
        if ($done) {
            $c->flash( message => $c->stash->{message} );
            $c->stash( default_backref =>
                $c->uri_for_action( "iprequest/list" ) );
            $c->detach('/follow_backref');
        }
    }
    #set form defaults
    my %tmpl_param;
    my @users;

    if($realm eq "normal") {
        @users =  $c->model('IPAdminDB::UserLDAP')->search({})->all;
        $tmpl_param{users} = \@users;
    }
    #ordinamento aree per nome dipartimento
    my @aree  = $c->model('IPAdminDB::Area')->search({},{join => 'department', prefetch => 'department', order_by => 'department.name'})->all;
    my @types = $c->model('IPAdminDB::TypeRequest')->search({},{order_by => 'type'})->all;    

    $tmpl_param{guest_type} = ["Studente laureando", "Dottorando", "Studente specializzando", "Borsista", 
                              "Assegnista di ricerca", "Collaboratore a contratto", "Profressore visitatore", 
                              "Professore a contratto", "Ospite"];
    $tmpl_param{realm}          = $realm;
    $tmpl_param{user}           = $user;
    $tmpl_param{fullname}       = $user->fullname;
    $tmpl_param{aree}           = \@aree;
    $tmpl_param{types}          = \@types;
    $tmpl_param{data}           = IPAdmin::Utils::print_short_timestamp(time);
    $tmpl_param{template}       = 'iprequest/edit.tt';
    $tmpl_param{subnets}        = $req->area->building->vlan->map_subnet;
    $tmpl_param{subnet_def}     = $req->subnet;
    $tmpl_param{host}           = $req->host;

    #user editable
    $tmpl_param{location}       = $c->req->param('location') || $req->location;
    $tmpl_param{mac}            = $c->req->param('mac') || $req->macaddress;
    $tmpl_param{hostname}       = $c->req->param('hostname') || $req->hostname;
    if(defined $req->guest){
        $tmpl_param{guest_fax}      = $c->req->param('guest_fax') || $req->guest->fax;
        $tmpl_param{guest_phone}    = $c->req->param('guest_phone') || $req->guest->telephone;
        #only root
        $tmpl_param{guest_date_out} = IPAdmin::Utils::print_short_timestamp($req->guest->date_out);
        #$tmpl_param{guste_type_def} =  ;
        $tmpl_param{guest_def} = $req->guest->type;

        $tmpl_param{guest_name}     = $req->guest->fullname;
        $tmpl_param{guest_mail}     = $req->guest->email;
    }
    $tmpl_param{type_def}       = $c->req->param('type') || $req->type->id;
    $tmpl_param{area_def}       = $req->area->id;

    $c->stash(user_def => $c->stash->{object}->user->id);

   

    if($realm eq "normal"){
        $c->req->param('area') and $tmpl_param{area_def} = $c->req->param('area');
        $c->req->param('type') and $tmpl_param{type_def} = $c->req->param('type');
        $c->req->param('guest_date_out') and $tmpl_param{guest_date_out} = $c->req->param('guest_date_out');
        $c->req->param('guest_name') and  $tmpl_param{guest_name} = $c->req->param('guest_name');
        $c->req->param('guest_mail') and $tmpl_param{guest_mail}  = $c->req->param('guest_mail');
        }

    my $det_time = defined($req->guest) ? 1 : 0;
    $tmpl_param{fixed}          = $c->req->param('fixed') || $det_time;
    $c->stash(%tmpl_param);
}

sub process_edit : Private {
    my ( $self, $c )   = @_;
    #user editable fields
    my $location       = $c->req->param('location');
    my $mac            = $c->req->param('mac');
    my $hostname       = $c->req->param('hostname');
    my $guest_fax      = $c->req->param('guest_fax');
    my $guest_phone    = $c->req->param('guest_phone');
    my $type           = $c->req->param('type');

    my $area;
    my $user;
    my $fixed;
    my $subnet; my $host;
    my $guest_type;
    my $guest_date_out;
    my $guest_name;
    my $guest_mail;
    if($c->stash->{realm} eq  "normal" ){
      #root editable fileds
      $area           = $c->req->param('area');
      $user           = $c->req->param('user');
      $fixed          = $c->req->param('fixed');
      $subnet         = $c->req->param('subnet');
      $host           = $c->req->param('host');
      $guest_type     = $c->req->param('guest_type');
      $guest_date_out = $c->req->param('guest_date_out');
      $guest_name     = $c->req->param('guest_name');
      $guest_mail     = $c->req->param('guest_mail');
    }
    my $error;

    # check form
    $c->forward('check_ipreq_form') || return 0; 
   
    #state == 0 non validata
    #state == 1 convalidata
    #state == 2 attiva
    #state == 3 bloccata
    #state == 4 archiviata
    my $ret;
    
    if($c->stash->{realm} eq  "normal" ){
        if(!$fixed) {
            $ret = $c->stash->{'object'}->update({
                                user        => $user,
                                location    => $location,
                                subnet      => $subnet,
                                host        => $host,
                                macaddress  => $mac,
                                hostname    => $hostname,
                                date        => time,
                                state       => $IPAdmin::NEW,
                                type        => $type,
                                   });
        } else{
            $ret = $c->stash->{'object'}->guest->update({
                fullname => $guest_name,
                email    => $guest_mail,
                telephone=> $guest_phone,
                type     => $guest_type,
                fax      => $guest_fax,
                date_out => $guest_date_out
                });
            $ret = $c->stash->{'object'}->update({
                            area        => $area,
                            user        => $user,
                            location    => $location,
                            subnet      => $subnet,
                            host        => $host,
                            macaddress  => $mac,
                            hostname    => $hostname,
                            type        => $type,
                            guest       => $ret->id,
                               });
        }
    } else{
    #se l'area non ha assegnato un referente allora abortisci tutto
    my $check_area = $c->stash->{object}->area->manager;
    if(!defined $check_area){
    $c->stash->{error_msg} = "Impossibile modificare la richiesta. In questo momento non esiste un referente per il dipartimento di ".$check_area->department->name.
            " presso ".$check_area->building->name.". Contattare l'amministratore di rete.";
    return 0;
    }

        #user edit
        $ret = $c->stash->{'object'}->update({
                                location    => $location,
                                macaddress  => $mac,
                                hostname    => $hostname,
                                type        => $type
                                });
        $c->stash->{'object'}->guest and 
                            $c->stash->{'object'}->guest->update({
                                              fax   => $guest_fax,
                                              telephone => $guest_phone,
                                              });            

    }
    if (! $ret ) {
    $c->stash->{error_msg} = "Errore nella creazione della richiesta IP";
    return 0;
    } else {
    $c->stash->{message} = "La richiesta IP è stata modificata.";
    return 1;
    }
}

sub create : Chained('base') : PathPart('create') : Args() {
    my ( $self, $c, $parent ) = @_;
    my $id;
    $c->stash( default_backref => $c->uri_for_action('/iprequest/list') );
    my ($realm, $user) = IPAdmin::Utils::find_user($self,$c,$c->user->username);


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
    my @users;

    if($realm eq "normal") {
        @users =  $c->model('IPAdminDB::UserLDAP')->search({})->all;
        $tmpl_param{users} = \@users;
    }
    #ordinamento aree per nome dipartimento
    my @aree  = $c->model('IPAdminDB::Area')->search({},{join => 'department', prefetch => 'department', order_by => 'department.name'})->all;
    my @types = $c->model('IPAdminDB::TypeRequest')->search({},{order_by => 'type'})->all;    

    $tmpl_param{guest_type}= ["Studente laureando", "Dottorando", "Studente specializzando", "Borsista", 
                              "Assegnista di ricerca", "Collaboratore a contratto", "Profressore visitatore", 
                              "Professore a contratto", "Ospite"];
    $tmpl_param{realm}     = $realm;
    $tmpl_param{user}      = $user;
    $tmpl_param{fullname}  = $user->fullname;
    $tmpl_param{aree}      = \@aree;
    $tmpl_param{types}     = \@types;
    $tmpl_param{data}      = IPAdmin::Utils::print_short_timestamp(time);
    $tmpl_param{template}  = 'iprequest/create.tt';
    $tmpl_param{location}  = $c->req->param('location') || '';
    $tmpl_param{mac}       = $c->req->param('mac') || '';
    $tmpl_param{hostname}  = $c->req->param('hostname') || '';
    $tmpl_param{area_def}  = $c->req->param('area') || '';
    $tmpl_param{type_def}  = $c->req->param('type') || '';
    #$tmpl_param{guest_def} = $c->req->param('guest_type');
    $tmpl_param{guest_date_out} = $c->req->param('guest_date_out');
    $tmpl_param{guest_name}  = $c->req->param('guest_name');
    $tmpl_param{guest_fax}   = $c->req->param('guest_fax');
    $tmpl_param{guest_phone} = $c->req->param('guest_phone');
    $tmpl_param{guest_mail}  = $c->req->param('guest_mail');
    $tmpl_param{fixed}  = $c->req->param('fixed');

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
    my $fixed     = $c->req->param('fixed');
    my $guest_type= $c->req->param('guest_type');
    my $guest_date_out = $c->req->param('guest_date_out');
    my $guest_name  = $c->req->param('guest_name');
    my $guest_fax   = $c->req->param('guest_fax');
    my $guest_phone = $c->req->param('guest_phone');
    my $guest_mail  = $c->req->param('guest_mail');

    $guest_date_out and $guest_date_out = str_to_time($guest_date_out);
    my $error;

    #se l'area non ha assegnato un referente allora abortisci tutto
    my $check_area = $c->model("IPAdminDB::Area")->find($area);

    # check form
    $c->forward('check_ipreq_form') || return 0; 

    if(!defined $check_area->manager){
    $c->stash->{error_msg} = "Impossibile creare la richiesta. Non è stato ancora assegnato un referente per il dipartimento di ".$check_area->department->name.
            " presso ".$check_area->building->name.". Contattare l'amministratore di rete.";
    return 0;
    }

    #state == 0 non validata
    #state == 1 convalidata
    #state == 2 attiva
    #state == 3 bloccata
    #state == 4 archiviata
    my $ret;
    if(!$fixed) {
    $ret = $c->stash->{'resultset'}->create({
                        area        => $area,
                        user        => $user,
                        location    => $location,
                        macaddress  => $mac,
                        hostname    => $hostname,
                        date        => time,
                        state       => $IPAdmin::NEW,
                        type        => $type,
                           });
    } else{
        $ret = $c->model("IPAdminDB::Guest")->create({
            fullname => $guest_name,
            email    => $guest_mail,
            telephone=> $guest_phone,
            type     => $guest_type,
            fax      => $guest_fax,
            date_out => $guest_date_out
            });
        $ret = $c->stash->{'resultset'}->create({
                        area        => $area,
                        user        => $user,
                        location    => $location,
                        macaddress  => $mac,
                        hostname    => $hostname,
                        date        => time,
                        state       => $IPAdmin::NEW,
                        type        => $type,
                        guest       => $ret->id,
                           });
    }

    if (! $ret ) {
    $c->stash->{error_msg} = "Errore nella creazione della richiesta IP";
    return 0;
    } else {
    $c->stash->{message} = "La richiesta IP è stata creata.";
    return 1;
    }
}

sub check_ipreq_form : Private {
    my ( $self, $c) = @_;
    my $schema         = $c->stash->{'resultset'};
    my $area           = $c->req->param('area');
    my $user           = $c->req->param('user');
    my $location       = $c->req->param('location');
    my $mac            = $c->req->param('mac');
    my $type           = $c->req->param('type');
    my $hostname       = $c->req->param('hostname');
    my $subnet         = $c->req->param('subnet');
    my $host           = $c->req->param('host');
    my $fixed          = $c->req->param('fixed');
    my $guest_type     = $c->req->param('guest_type');
    my $guest_date_out = $c->req->param('guest_date_out');
    my $guest_name     = $c->req->param('guest_name');
    my $guest_fax      = $c->req->param('guest_fax');
    my $guest_phone    = $c->req->param('guest_phone');
    my $guest_mail     = $c->req->param('guest_mail');

    if ( $area eq '' and !defined($c->stash->{object}) ) {
        $c->stash->{error_msg} = "Selezionare una struttura!";
        return 0;
    }
    if ( $mac eq '' ) {
     	$c->stash->{error_msg} = "Campo Mac Address obbligatorio!";
     	return 0;
     }
    #controllo formato mac address (ancora non copre aa:bb:cc:dd:ee:ff) 
    if ( $mac !~ /([0-9a-f]{2}:){5}[0-9a-f]{2}/i ) {
     	$c->stash->{error_msg} = "Errore nel formato del mac address! aa:aa:aa:aa:aa:aa";
     	return 0;
     }

    if ( $hostname eq '' ) {
	$c->stash->{error_msg} = "Campo Hostname obbligatorio!";
	return 0;
     }    

    if ( $host ne '' and $subnet ne '' and 
        $schema->search({subnet=> $subnet, host => $host})->count ) {
        $c->stash->{error_msg} = "Indirizzo IP già assegnato!";
        return 0;
     }

    # if ($schema->search({ macaddress => $mac})->count() > 0 ) {
    #  $c->stash->{error_msg} = "Mac Address già registrato!";
    #  $c->log->error("Duplicated $mac");
    #  return 0;
    # }

    if($fixed){
        if ( $guest_type eq '' ) {
         $c->stash->{error_msg} = "Posizione dell'utente obbligatoria!";
        return 0;
        }
        if ( $guest_phone eq '' ) {
         $c->stash->{error_msg} = "Telefono dell'utente obbligatorio!";
        return 0;
        }
        if ( $guest_mail eq '' ) {
         $c->stash->{error_msg} = "Email dell'utente obbligatoria!";
        return 0;
        }
        if ( $guest_name eq '' ) {
         $c->stash->{error_msg} = "Nome completo dell'utente obbligatorio!";
        return 0;
        }
        if ( $guest_date_out eq '' ) {
        $c->stash->{error_msg} = "Indicare una data di scadenza!";
        return 0;
        }
    }


    return 1;
}

sub validate : Chained('object') : PathPart('validate') : Args(0) {
    my ( $self, $c ) = @_;
    my $req = $c->stash->{'object'};

    $c->stash( default_backref => $c->uri_for_action('/iprequest/list') );

    if ( lc $c->req->method eq 'post' ) {
        if ( $c->req->param('discard') ) {
            $c->detach('/follow_backref');
        }
        my $done = $c->forward('process_validate');
        if ($done) {
            $c->flash( message => $c->stash->{message} );
            $c->stash( default_backref =>
                $c->uri_for_action( "/iprequest/list" ) );
            $c->detach('/follow_backref');
        }
    }


    #set form defaults
    my %tmpl_param;

    $tmpl_param{data}      = IPAdmin::Utils::print_short_timestamp($req->date);
    #a regime deve proporre un indirizzo IP tra le subnet associate 
    #all'area
    my $vlan = $req->area->building->vlan;
    my $subnets; 
    defined $vlan and $subnets = $vlan->map_subnet;

    if(!defined $subnets){
        $c->flash( message => "Nessuna subnet associata alla vlan $vlan!" );
        return;
    }

    my @availables;
    while(my $subnet = $subnets->next) {
        my ($free_ip, $used_ip);
        my $sub_id = $subnet->id;
        foreach $free_ip (6..247){
            $used_ip = $c->model("IPAdminDB::IPRequest")->search({-and => 
                                                     [ subnet => $sub_id,
                                                       host   => $free_ip,
                                                       -or     =>[ state => $IPAdmin::PREACTIVE,
                                                                   state => $IPAdmin::ACTIVE,
                                                                   state => $IPAdmin::INACTIVE,                
                                                                 ]
                                                     ]},
                                                    )->single;
            last unless defined $used_ip;
        }

        #TODO spostare tutto in una funzione
        #TODO logica degli ip
        if (defined $used_ip ) {
            $c->flash( message => "Non ci sono IP disponibili per la subnet 151.100.$subnet->id.0.
                                   Contattare ipsapienza\@uniroma1.it" );
            #TODO redirigere su userldap/<utente>/view
            $c->stash( default_backref =>
                $c->uri_for_action( "/iprequest/list" ) );
            $c->detach('/follow_backref');
        }

        my $proposed_ip = "151.100.".$subnet->id.".$free_ip";
        push @availables, $proposed_ip;
    }

    $tmpl_param{proposed_ip} = \@availables;
    $tmpl_param{template}  = 'iprequest/validate.tt';
    $c->stash(%tmpl_param);

}

sub process_validate : Private {
    my ( $self, $c ) = @_;
    my $ipaddr       = $c->req->param('ipaddr');
    my $error;
    
    unless ($ipaddr) {
    $c->stash->{message} = "L'indirizzo IP è un campo obbligatorio";
    return 0;
    }
    #Stati IPRequest
    #state == 0 non validata
    #state == 1 convalidata
    #state == 2 attiva
    #state == 3 bloccata
    #state == 4 archiviata

    #stati IPAssignement 
    #state == 2 attiva
    #state == 4 archiviata

    #cambiare stato alla ip_request
    #segnare subnet e host in ip_request
    #creare assegnamento
    $ipaddr =~ m/151\.100\.(\d+)\.(\d+)/;
    my ($sub,$host) = ($1,$2);

    $c->stash->{'object'}->state($IPAdmin::PREACTIVE);
    $c->stash->{'object'}->subnet($sub);
    $c->stash->{'object'}->host($host);
    $c->stash->{'object'}->update;

    my $ret = $c->model('IPAdminDB::IPAssignement')->create({
                        state       => $IPAdmin::ACTIVE,
                        date_in     => time,
                        ip_request  => $c->stash->{'object'}->id,
                        });



    if (! $ret ) {
    $c->stash->{message} = "Errore nella creazione dell'assegnazione IP";
    return 0;
    } else {
    $c->stash->{message} = "L'assegnazione' IP è stata creata.";
    return 1;
    }
}

sub unactivate : Chained('object') : PathPart('unactivate') : Args(0) {
 my ( $self, $c ) = @_;
 my $iprequest = $c->stash->{'object'};

 
 if ( lc $c->req->method eq 'post' ) {
     #TODO invalidare ogni assegnazione associata alla richiesta

        $iprequest->state($IPAdmin::INACTIVE);
        $iprequest->update;
        #invalida la vecchia assegnazione IP
        my $ret = $c->model('IPAdminDB::IPAssignement')->search({-and =>
                                                     [ ip_request => $iprequest->id, state=>$IPAdmin::ACTIVE ]})->single;
        $ret->update({
                        date_out => time,
                        state    => $IPAdmin::ARCHIVED,
                        });
        #crea la nuova assegnazione (riattivabile dall'utente entro tot giorni)
        $c->model('IPAdminDB::IPAssignement')->create({
                        date_in     => time,
                        state       => $IPAdmin::ACTIVE,
                        ip_request  => $c->stash->{'object'}->id,
                        });

        $c->flash( message => 'Richiesta IP invalidata.' );
        $c->detach('/follow_backref');
   }
   else {
       $c->stash( template => 'iprequest/unactivate.tt' );
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

    #Aggiorna la data dell'assegnamento 
    my $ret = $c->model('IPAdminDB::IPAssignement')->search({state=>$IPAdmin::ACTIVE})->single;
    $ret->update({
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
   my $iprequest = $c->stash->{'object'};
   $c->stash( default_backref => $c->uri_for_action('iprequest/list') );

  
    if ( lc $c->req->method eq 'post' ) {
        #Archivia la richiesta
        $iprequest->state($IPAdmin::ARCHIVED);
        $iprequest->update;
        #chiude l'ultima assegnazione
        my $ret = $c->model('IPAdminDB::IPAssignement')->search({-and =>
        	  [ ip_request => $iprequest->id, state=>$IPAdmin::ACTIVE ]})->single;

        defined $ret and $ret->update({
                        date_out => time,
                        state    => $IPAdmin::ARCHIVED,
                     });
       
         $c->flash( message => 'Richiesta IP archiviata.' );
         $c->detach('/follow_backref');
   }
   else {
       $c->stash( template => 'generic_delete.tt' );
   }
}


=head2 notify
invia una notifica via email all'utente per i processi di convalida, attivazione, scadenza e rinuncia.
=cut

sub process_notify : Private {
    my ( $self, $c ) = @_;
    my $error;
    my $iprequest = $c->stash->{object};
    my $ret; #status invio messaggio con Mail::Sendmail

    if ($iprequest->state == $IPAdmin::NEW) {
        #A seguito di iprequest/create, preparo il messaggio per il referente di rete: "C'è una nuova richiesta da validare"
    }
    elsif ($iprequest->state == $IPAdmin::PREACTIVE) {
        #A seguito di iprequest/validate, preparo il messaggio per l'utente: "La tua richiesta è stata validata: stampa, firma ed invia il modulo via fax (o caricamento pdf?)"
    }
    elsif ($iprequest->state == $IPAdmin::ACTIVE) {
        #A seguito di iprequest/activate, preparo il messaggio per l'utente: "Il tuo IP è attivo"
    } 
    elsif ($iprequest->state == $IPAdmin::INACTIVE) {
        #A seguito di iprequest/unactivate, preparo il messaggio per l'utente: "Il tuo IP è stato bloccato. Hai X giorni di tempo per riattivarlo o verrà assegnato a qualcun altro"
    }
    elsif ($iprequest->state == $IPAdmin::ARCHIVED) {
        #A seguito di iprequest/delete, preparo il messaggio per l'utente: "Rinuncia dell'indirizzo IP terminata con successo"
    }
    else { #perchè hai richiamato questo metodo?
    }

    if (! $ret ) {
    $c->stash->{message} = "Errore nell'invio del messaggio.";
    return 0;
    } else {
    $c->stash->{message} = "Messaggio inviato correttamente.";
    return 1;
    }
}


=head2 dnsupdate
invia un update al dns aggiungendo o rimuovendo un record a seconda dello stato della richiesta
=cut

sub process_dnsupdate : Private {
    my ( $self, $c ) = @_;
    my $error;
    my $iprequest = $c->stash->{object};
    my $ret; #status invio update con Net::DNS

    if ($iprequest->state == $IPAdmin::ACTIVE) {
        #A seguito di iprequest/activate, invio update per aggiungere il record A nella zona corretta
    } 
    elsif ($iprequest->state == $IPAdmin::ARCHIVED) {
        #A seguito di iprequest/delete, invio update per rimuovere il record A dalla zona corretta, e gli eventuali CNAME da qualsiasi zona
    }
    else { #perchè hai richiamato questo metodo?
    }

    if (! $ret ) {
    $c->stash->{message} = "Errore nell'invio dell'update.";
    return 0;
    } else {
    $c->stash->{message} = "Update inviato correttamente.";
    return 1;
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
