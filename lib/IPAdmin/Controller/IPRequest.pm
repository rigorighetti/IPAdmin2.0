# Copyright 2011 by the IPAdmin Team
#
# This library is free software. You can redistribute it and/or modify
# it under the same terms as Perl itself.
package IPAdmin::Controller::IPRequest;
use Moose;
use namespace::autoclean;
use Data::Dumper;
use IPAdmin::Utils qw(str_to_time);
use Email::Send;

with 'IPAdmin::ControllerRole::JQDatatable';


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

    my ($realm, $user) = IPAdmin::Utils::find_user($self,$c,$c->session->{user_id}); 
    !defined($user) and $c->detach('/access_denied');
    $c->stash(realm => $realm);

    if($realm  eq "ldap" ){
        #don'block if the user is the manager of that request
        return if(  defined $c->stash->{object}->area->manager and 
                    $c->stash->{object}->area->manager->id eq $user->id );
        #non bloccare se sei referente di servizio per questa richiesta
        return if( defined $c->stash->{object}->type->service_manager and 
            $c->stash->{object}->type->service_manager->id eq $user->id );
        return if( $c->stash->{object}->user->id eq $user->id );
        #block the action: an user can't see the reuqest of another user
        $c->detach('/access_denied');
    }

}



=head2 notify

=cut

sub notify : Chained('object') : PathPart('notify') : Args(0) {
   my ( $self, $c ) = @_;
   $c->stash( default_backref =>
                $c->uri_for_action( "iprequest/view",[$c->stash->{object}->id] ) );
   my $done = $c->forward('process_notify');
   $c->flash(message => "Email inviata correttamente") if($done);
   $c->detach('/follow_backref');
}

=head2 list
commentata in attesa di capire come fare.
L'utente deve vedere solo le sue. (23-04-14 implementata come tab per userldap)
Il referente le sue + quelle di cui è referente divise da tab. (28-04-14 implementata come tab per userldap)
L'amministratore vede tutte le richieste insieme (iprequest/list)

=cut


sub list : Chained('base') : PathPart('list') : Args(0) {
   my ( $self, $c ) = @_;

   # my @iprequest_table =  map +{
   #      id          => $_->id,
   #      date        => IPAdmin::Utils::print_short_timestamp($_->date),
   #      area        => $_->area,
   #      user        => $_->user,
   #      state       => $_->state,
   #      type        => $_->type->type,
   #      macaddress  => $_->macaddress,
   #      hostname    => $_->hostname,
   #      subnet      => $_->subnet,
   #      host        => $_->host,
   #      }, $c->stash->{resultset}->search({},
   #              {prefetch => [qw(type user ),{area => ['building','department']}],
   #               select   => [qw(id date type.type user macaddress user.username 
   #                  user.fullname area.department area.building
   #                   area.manager user.fullname
   #                   area.department  state host )]

   #              });

   # $c->stash( iprequest_table => \@iprequest_table );
   my %stats;
   $stats{nuove}       =  $c->model('IPAdminDB::IPRequest')->search({state => $IPAdmin::NEW })->count();
   $stats{validate}    =  $c->model('IPAdminDB::IPRequest')->search({state => $IPAdmin::PREACTIVE})->count();
   $stats{attivi}      =  $c->model('IPAdminDB::IPRequest')->search({state => $IPAdmin::ACTIVE })->count();
   $stats{archiviati}  =  $c->model('IPAdminDB::IPRequest')->search({state => $IPAdmin::ARCHIVED})->count();
   #$stats{client}      =  $c->model('IPAdminDB::IPRequest')->search({-and => 
   #                                                  [ state => $IPAdmin::ACTIVE,
   #                                                    -or     =>[ 'type.type' => 'Computer Fisso',
   #                                                                 'type.type' => 'Computer Portatile', 
   #                                                                 'type.type' => 'Stampante', 
   #                                                               ],
   #                                                               ]},
   #                                                    {prefetch => ['type']}
   #                                                               )->count();

    # Gestisce la grandezza dei pallini della legenda in base al numero a 2,3,4 o 5 cifre.
    my @stati = qw {nuove validate attivi archiviati}; 
    foreach (@stati) {
        if     ($stats{$_} < 100)       { $stats{"raggio_$_"} = 15;
                                          $stats{"posx_$_"}   = 27  if $_ eq "nuove" ; 
                                          $stats{"posx_$_"}   = 122 if $_ eq "validate";
                                          $stats{"posx_$_"}   = 262 if $_ eq "attivi"; 
                                          $stats{"posx_$_"}   = 362 if $_ eq "archiviati";
                                      }
        elsif  ($stats{$_} < 1000)      { $stats{"raggio_$_"} = 17.5;   
                                          $stats{"posx_$_"}   = 22.5  if $_ eq "nuove" ; 
                                          $stats{"posx_$_"}   = 117.5 if $_ eq "validate";
                                          $stats{"posx_$_"}   = 257.5 if $_ eq "attivi"; 
                                          $stats{"posx_$_"}   = 357.5 if $_ eq "archiviati";
                                      }
        elsif  ($stats{$_} < 10000)     { $stats{"raggio_$_"} = 20;   
                                          $stats{"posx_$_"}   = 19.5  if $_ eq "nuove" ; 
                                          $stats{"posx_$_"}   = 114.5 if $_ eq "validate";
                                          $stats{"posx_$_"}   = 253.5 if $_ eq "attivi"; 
                                          $stats{"posx_$_"}   = 354.5 if $_ eq "archiviati"; 
                                      }
        elsif  ($stats{$_} < 100000)    { $stats{"raggio_$_"} = 22.5;   
                                          $stats{"posx_$_"}   = 15    if $_ eq "nuove" ; 
                                          $stats{"posx_$_"}   = 110   if $_ eq "validate";
                                          $stats{"posx_$_"}   = 250   if $_ eq "attivi"; 
                                          $stats{"posx_$_"}   = 350   if $_ eq "archiviati";
                                      }
    
    }

   $c->stash(%stats);
   $c->stash( template        => 'iprequest/list.tt' );
}

=head2 view

=cut

sub view : Chained('object') : PathPart('view') : Args(0) {
    my ( $self, $c ) = @_;
    my $req = $c->stash->{object};

    if($c->user_in_realm( "normal" )){
       $c->stash(realm => "normal");
    }else {
       $c->stash(realm => "ldap");
    }
   
    #Creare lista di assegnazioni per richiesta IP
    my @assignement =  map +{
            id          => $_->id,
            date_in     => $_->date_in  ? IPAdmin::Utils::print_short_timestamp($_->date_in) : '',
            date_out    => $_->date_out ? IPAdmin::Utils::print_short_timestamp($_->date_out) : '',
            state       => $_->state,
            },
            $req->map_assignement;

    my @aliases = $req->map_alias;

    $c->stash( manoc_link  => $c->config->{'Link'}->{'manoc'} );
    $c->stash( data        => IPAdmin::Utils::print_short_timestamp($req->date));
    $c->stash( assignement => \@assignement );
    $c->stash( aliases     => \@aliases );
    $c->stash( template    => 'iprequest/view.tt' );
}


=head2 view

=cut

sub print : Chained('object') : PathPart('print') : Args(0) {
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
    $c->stash( template => 'iprequest/print.tt' );
}

=head2 edit

=cut

sub edit : Chained('object') : PathPart('edit') : Args(0) {
    my ( $self, $c ) = @_;     
    my $req = $c->stash->{object};
    #TODO recuperare i dati e lasciare solo alcuni campi modificabili

    my $id;

    my ($realm, $user) = IPAdmin::Utils::find_user($self,$c,$c->session->{user_id}); 
    !defined($user) and $c->detach('/access_denied');
    $c->stash( default_backref => $c->uri_for_action('userldap/view',[$user->username]) );
    $c->stash( default_backref => $c->uri_for_action('iprequest/list') ) if( $realm eq  "normal" );

    if ( lc $c->req->method eq 'post' ) {
        if ( $c->req->param('discard') ) {
            $c->detach('/follow_backref');
        }
        my $done = $c->forward('process_edit');
        if ($done) {
            $c->flash( message => $c->stash->{message} );
            $c->detach('/follow_backref');
        }
    }
    #set form defaults
    my %tmpl_param;
    my @users;

    if($realm eq "normal") {
        @users =  $c->model('IPAdminDB::UserLDAP')->search({},{order_by => 'username'})->all;
        $tmpl_param{users} = \@users;
    }
    #ordinamento aree per nome dipartimento
    my @aree  = $c->model('IPAdminDB::Area')->search({},{prefetch => ['department','building','manager'], order_by => 'department.name'})->all;
    my @types = $c->model('IPAdminDB::TypeRequest')->search({},{order_by => 'type'})->all;    

    $tmpl_param{guest_type} = ["Studente laureando", "Dottorando", "Studente specializzando", "Borsista", 
                              "Assegnista di ricerca", "Collaboratore a contratto", "Profressore visitatore", 
                              "Professore a contratto", "Ospite"];
    $tmpl_param{realm}          = $realm;
    $tmpl_param{user}           = $req->user;
    $tmpl_param{fullname}       = $req->user->fullname;
    $tmpl_param{aree}           = \@aree;
    $tmpl_param{types}          = \@types;
    $tmpl_param{data}           = IPAdmin::Utils::print_short_timestamp(time);
    $tmpl_param{template}       = 'iprequest/edit.tt';
    $tmpl_param{subnets}        = $req->area->building->vlan->map_subnet;
    $tmpl_param{subnet_def}     = $req->subnet;
    $tmpl_param{host}           = $req->host;
    $tmpl_param{notes}          = $req->notes;

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
    defined($req->area) and $tmpl_param{area_def}       = $req->area->id;
    (defined($req->area) and defined($req->area->department)) and $tmpl_param{dom_def}    = $req->area->department->domain;

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
    my $notes          = $c->req->param('notes');

    my $area;
    my $user;
    my $fixed;
    my $subnet; my $host;
    my $guest_type;
    my $guest_date_out;
    my $guest_name;
    my $guest_mail;
    if($c->stash->{realm} eq  "normal" ){
      #root editable fields
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

    #sanitize input 
    $hostname =~ s/\s+//mxgo;
    $subnet ||= $c->stash->{'object'}->subnet;
    defined($subnet) and $subnet = $subnet->id;
    $host   ||= $c->stash->{'object'}->host;


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
                                #state       => $IPAdmin::NEW,
                                type        => $type,
                                notes       => $notes,
                                   });
        } else{
            $ret = $c->stash->{'object'}->guest->update({
                fullname => $guest_name,
                email    => $guest_mail,
                telephone=> $guest_phone,
                type     => $guest_type,
                fax      => $guest_fax,
                date_out => $guest_date_out,
                });
            $ret = $c->stash->{'object'}->update({
                            location    => $location,
                            subnet      => $subnet,
                            host        => $host,
                            macaddress  => $mac,
                            hostname    => $hostname,
                            type        => $type,
                            guest       => $ret->id,
                            notes       => $notes,
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
                                type        => $type,
                                notes       => $notes,
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
    my ($realm, $user) = IPAdmin::Utils::find_user($self,$c,$c->session->{user_id}); 
    !defined($user) and $c->detach('/access_denied');
    $c->stash( default_backref => $c->uri_for_action('userldap/view',[$user->username]) );
    $c->stash( default_backref => $c->uri_for_action('iprequest/list') ) if( $realm eq  "normal" );


    if ( lc $c->req->method eq 'post' ) {
        if ( $c->req->param('discard') ) {
            $c->detach('/follow_backref');
        }
        my $done = $c->forward('process_create');
        if ($done) {
            my $msg = $c->stash->{message} ;
            $c->forward('process_notify');
            $c->flash(message => $msg." ".$c->stash->{mail_message});
            $c->detach('/follow_backref');
        }
    }
    #set form defaults
    my %tmpl_param;
    my @users;

    if($realm eq "normal") {
        @users =  $c->model('IPAdminDB::UserLDAP')->search({},{order_by => 'username'})->all;
        $tmpl_param{users} = \@users;
    }
    #ordinamento aree per nome dipartimento
    my @aree  = $c->model('IPAdminDB::Area')->search({},{prefetch => ['department','building','manager'], order_by => 'department.name'})->all;
    my @types = $c->model('IPAdminDB::TypeRequest')->search({},{order_by => 'type'})->all;    

    $tmpl_param{guest_type}= ["Studente laureando", "Dottorando", "Studente specializzando", "Borsista", 
                              "Assegnista di ricerca", "Collaboratore a contratto", "Profressore visitatore", 
                              "Professore a contratto", "Ospite"];
    $tmpl_param{realm}          = $realm;
    $tmpl_param{user}           = $user;
    $tmpl_param{fullname}       = $user->fullname;
    $tmpl_param{aree}           = \@aree;
    $tmpl_param{types}          = \@types;
    $tmpl_param{data}           = IPAdmin::Utils::print_short_timestamp(time);
    $tmpl_param{template}       = 'iprequest/create.tt';
    $tmpl_param{location}       = $c->req->param('location') || '';
    $tmpl_param{mac}            = $c->req->param('mac') || '';
    $tmpl_param{hostname}       = $c->req->param('hostname') || '';
    $tmpl_param{area_def}       = $c->req->param('area') || '';
    $tmpl_param{type_def}       = $c->req->param('type') || '';
    $tmpl_param{guest_def}      = $c->req->param('guest_type');
    $tmpl_param{guest_date_out} = $c->req->param('guest_date_out');
    $tmpl_param{guest_name}     = $c->req->param('guest_name');
    $tmpl_param{guest_fax}      = $c->req->param('guest_fax');
    $tmpl_param{guest_phone}    = $c->req->param('guest_phone');
    $tmpl_param{guest_mail}     = $c->req->param('guest_mail');
    $tmpl_param{fixed}          = $c->req->param('fixed');
    $tmpl_param{notes}          = $c->req->param('notes');
    $tmpl_param{user_def}       = $c->req->param('user');

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
    my $notes     = $c->req->param('notes');
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

    #sanitize hostname 
    $hostname =~ s/\s+//mxgo;

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
                        notes       => $notes,
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
                        notes       => $notes,
                           });
    }

    if (! $ret ) {
    $c->stash->{error_msg} = "Errore nella creazione della richiesta IP";
    return 0;
    } else {
    $c->stash(object => $ret);
    $c->stash->{message} = "La richiesta IP è stata creata ed è ora in attesa di approvazione da parte del referente.";
    return 1;
    }
}

sub check_ipreq_form : Private {
    my ( $self, $c) = @_;
    my $schema         = $c->stash->{'resultset'};
    my $area           = $c->req->param('area') || '';
    my $user           = $c->req->param('user') || '';
    my $location       = $c->req->param('location') || '';
    my $mac            = $c->req->param('mac') || '';
    my $type           = $c->req->param('type') || '';
    my $hostname       = $c->req->param('hostname') || '';
    my $subnet         = $c->req->param('subnet') || '';
    my $host           = $c->req->param('host') || '';
    my $fixed          = $c->req->param('fixed') || '';
    my $guest_type     = $c->req->param('guest_type') || '';
    my $guest_date_out = $c->req->param('guest_date_out') || '';
    my $guest_name     = $c->req->param('guest_name') || '';
    my $guest_fax      = $c->req->param('guest_fax') || '';
    my $guest_phone    = $c->req->param('guest_phone') || '';
    my $guest_mail     = $c->req->param('guest_mail') || '';
    my $confirm        = $c->req->param('confirm') || '';


    if ( $user eq '' ) {
        $c->stash->{error_msg} = "Selezionare un utente";
        return 0;
    }
    if ( $area eq '' ) {
        $c->stash->{error_msg} = "Selezionare una struttura";
        return 0;
    }
    if ( $mac eq '' ) {
     	$c->stash->{error_msg} = "Campo Mac Address obbligatorio";
     	return 0;
     }
    #controllo formato mac address (ancora non copre aa:bb:cc:dd:ee:ff) 
    if ( $mac !~ /([0-9a-f]{2}:){5}[0-9a-f]{2}/i ) {
     	$c->stash->{error_msg} = "Errore nel formato del mac address! aa:aa:aa:aa:aa:aa";
     	return 0;
     }

    if ( $hostname eq '' ) {
	   $c->stash->{error_msg} = "Campo Hostname obbligatorio";
	   return 0;
     }    
    if ( $type eq '' ) {
        $c->stash->{error_msg} = "Tipo di apparato obbligatorio";
        return 0;
     }  
    if ( $confirm eq '' ) {
        $c->stash->{error_msg} = "Devi prima aver letto ed accettato le norme";
        return 0;
    } 

    if ( $host ne '' and $subnet ne '' ) {
        if(!find_subnet($c,$area,$subnet)){
          $c->stash->{error_msg} = "La subnet scelta non è tra quelle disponibili in questo dipartimento";
          return 0;     
        }
        if(defined $c->stash->{object} and $c->stash->{object}->subnet->id ne $subnet
                                       and $c->stash->{object}->host ne $host ){ 
          #edit action
          if($schema->search({subnet=> $subnet, host => $host, state => {-not => $IPAdmin::ARCHIVED}})->count > 0){
            #l'indirizzo editato a mano è già in uso
            $c->stash->{error_msg} = "Indirizzo IP già assegnato";
            return 0;
        }
      }
    }
    if($host eq '' or $subnet eq ''){
      if($c->stash->{'object'} and $c->stash->{'object'}->state eq $IPAdmin::PREACTIVE){
        $c->stash->{error_msg} = "Subnet e Host devono essere assegnate!";
        return 0; 
      }
    }

    # if ($schema->search({ macaddress => $mac})->count() > 0 ) {
    #  $c->stash->{error_msg} = "Mac Address già registrato!";
    #  $c->log->error("Duplicated $mac");
    #  return 0;
    # }

    if($fixed ne ''){
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

sub find_subnet : Private {
    my ( $c , $area, $subnet_id )  = @_;
    my ($e,$it);

    my $ret = $c->model("IPAdminDB::Area")->find($area);
    my @subnets = $ret->building->vlan->map_subnet;

    foreach my $s (@subnets){
     $subnet_id eq $s->id and return 1;            
    }
    return 0;
}

sub validate : Chained('object') : PathPart('validate') : Args(0) {
    my ( $self, $c ) = @_;
    my $req = $c->stash->{'object'};
    my $error_flag = 0;

    my ($realm, $user) = IPAdmin::Utils::find_user($self,$c,$c->session->{user_id}); 
    !defined($user) and $c->detach('/access_denied');
    $c->stash( default_backref => $c->uri_for_action('userldap/view',[$user->username]) );
    $c->stash( default_backref => $c->uri_for_action('iprequest/list') ) if( $realm eq  "normal" );

    my ($id_manager, $id_ser_manager);
    defined $req->area->manager and $id_manager = $req->area->manager->id;
    defined $req->type->service_manager and $id_manager = $req->type->service_manager->id;

    if($realm  eq "ldap" ){
       #se l'utente non è referente blocca tutto
       #qui devo solo controllare che l'utente non stiamo validando la propria richiesta
       #senza essere referente (di area o di servizio)
       $c->detach('/access_denied') 
            if($user->id ne $id_manager and $user->id ne $id_ser_manager);
    }


    if ( lc $c->req->method eq 'post' ) {
        if ( $c->req->param('discard') ) {
            $c->detach('/follow_backref');
        }
        my $done = $c->forward('process_validate');
        if ($done) {
            $c->flash( message => $c->stash->{message} );
            $c->forward('process_notify');
            $c->detach('/follow_backref');
        }
    }

    #set form defaults
    my %tmpl_param;

    $tmpl_param{data}      = IPAdmin::Utils::print_short_timestamp($req->date);
    #a regime deve proporre un indirizzo IP tra le subnet associate 
    #all'area
    my $vlan   = $req->area->building->vlan->id;
    my %filter = map {$_->id =>1}  $req->area->filtered;
    my @subnets = $req->area->filtered->all; 

    if(! scalar(@subnets)){
        $c->flash( message => "Nessuna subnet associato al dipartimento di ".
                        $req->area->department->name." presso ".$req->area->building->name );
        return;
    }

    my ($free_ip, $used_ip);
    my @availables;
    foreach my $subnet (@subnets){
    	$used_ip = undef;
        my $sub_id = $subnet->id;
        
       #next if($filter{$sub_id});
        foreach my $ip (6..247){
	        $used_ip = $c->model("IPAdminDB::IPRequest")->search({-and => 
                                                     [ subnet => $sub_id,
                                                       host   => $ip,
                                                       -or     =>[ state => $IPAdmin::PREACTIVE,
                                                                   state => $IPAdmin::ACTIVE,
                                                                   state => $IPAdmin::INACTIVE,                
                                                                 ]
                                                     ]},
                                                    )->single;
	       $free_ip = $ip;
	       last unless defined $used_ip;
	   }

        #TODO spostare tutto in una funzione
        #TODO logica degli ip
        if (defined $used_ip ) {
            $c->flash( message => "Gli IP dispobibili a questa struttura sono terminati.
                                   Contattare ipsapienza\@uniroma1.it" );
            #TODO redirigere su userldap/<utente>/view
            $c->stash( default_backref =>
                $c->uri_for_action( "/iprequest/list" ) );
            $c->detach('/follow_backref');
        }

        my $proposed_ip = "151.100.".$subnet->id.".".$free_ip;
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

# sub unactivate : Chained('object') : PathPart('unactivate') : Args(0) {
#  my ( $self, $c ) = @_;
#  my $iprequest = $c->stash->{'object'};

#     my ($realm, $user) = IPAdmin::Utils::find_user($self,$c,$c->user->username);
#     $c->stash( default_backref => $c->uri_for_action('userldap/view',[$user->username]) );
#     $c->stash( default_backref => $c->uri_for_action('iprequest/list') ) if( $realm eq  "normal" );
#  if ( lc $c->req->method eq 'post' ) {
#      #TODO invalidare ogni assegnazione associata alla richiesta

#         $iprequest->state($IPAdmin::INACTIVE);
#         $iprequest->update;
#         #invalida la vecchia assegnazione IP
#         my $ret = $c->model('IPAdminDB::IPAssignement')->search({-and =>
#                                                      [ ip_request => $iprequest->id, state=>$IPAdmin::ACTIVE ]})->single;
#         $ret->update({
#                         date_out => time,
#                         state    => $IPAdmin::ARCHIVED,
#                         });
#         #crea la nuova assegnazione (riattivabile dall'utente entro tot giorni)
#         $c->model('IPAdminDB::IPAssignement')->create({
#                         date_in     => time,
#                         state       => $IPAdmin::ACTIVE,
#                         ip_request  => $c->stash->{'object'}->id,
#                         });
#         $c->forward('process_notify');
#         $c->flash( message => 'Richiesta IP invalidata.' );
#         $c->detach('/follow_backref');
#    }
#    else {
#        $c->stash( template => 'iprequest/unactivate.tt' );
#    }
# }


sub activate : Chained('object') : PathPart('activate') : Args(0) {
    my ( $self, $c ) = @_;
    my $req = $c->stash->{'object'};
    my ($realm, $user) = IPAdmin::Utils::find_user($self,$c,$c->session->{user_id}); 
    !defined($user) and $c->detach('/access_denied');
    $c->stash( default_backref => $c->uri_for_action('userldap/view',[$user->username]) );
    $c->stash( default_backref => $c->uri_for_action('iprequest/list') ) if( $realm eq  "normal" );

    if ( lc $c->req->method eq 'post' ) {
        if ( $c->req->param('discard') ) {
            $c->detach('/follow_backref');
        }
        my $done = $c->forward('process_activate');
        if ($done) {
            $c->flash( message => $c->stash->{message} );
            $c->forward('process_notify');
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
    $ret->update({date_in     => time});

    if(defined($c->stash->{object}->guest)){
        my $date_out = $c->stash->{object}->guest->date_out;
        $ret->update({date_out => $date_out});
    }
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
    my ($realm, $user) = IPAdmin::Utils::find_user($self,$c,$c->session->{user_id});
    if(defined $user){
    $c->stash( default_backref => $c->uri_for_action('userldap/view',[$user->username]) );
    $c->stash( default_backref => $c->uri_for_action('iprequest/list') ) if( $realm eq  "normal" );
    }
  
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
        #archive all associated aliases
        my @aliases = $c->model('IPAdminDB::Alias')->search({-and =>
            [ ip_request => $iprequest->id, state=>$IPAdmin::ACTIVE ]});
        foreach my $alias (@aliases){
          $alias->update({state => $IPAdmin::ARCHIVED});
        }

         $c->forward('process_notify');
         $c->flash( message => 'Richiesta IP archiviata. '. $c->stash->{mail_message} );

         $c->detach('/follow_backref');
   }
   else {
       $c->stash( template => '/iprequest/generic_delete.tt' );
   }
}


=head2 notify
invia una notifica via email all'utente per i processi di convalida, attivazione, scadenza e rinuncia.
=cut

sub process_notify : Private {
    my ( $self, $c ) = @_;
    my $error;
    my $ipreq = $c->stash->{object};
    my $ret; #status invio messaggio con Mail::Sendmail
    my ($body, $to, $cc, $subject);
    my $url = $c->uri_for_action('/iprequest/view',[$ipreq->id]);

    #default: send email to user
    $to = $ipreq->user->email;

    if ($ipreq->state == $IPAdmin::NEW) {
        #A seguito di ipreq/create, preparo il messaggio per il referente
        #di rete: "C'è una nuova richiesta da validare"
        $body = <<EOF;
Gentile referente, 
c'è una nuova richiesta IP che richiede il suo intervento: 
    $url
EOF
	if(defined $ipreq->area->manager){
        $to = $ipreq->area->manager->email;
        if (defined $ipreq->type->service_manager) {
            $to = $c->stash->{object}->type->service_manager->email;
        }
	}
	else{
 	  $c->stash( error_msg => 'Impossibile inviare una mail al referente perché Non è stato ancora nominato un referente per quest\'area');
  	  $c->detach('/follow_backref');	 
	}
	$subject = "Nuova richiesta di indirizzo IP id: ".$ipreq->id
    }
    elsif ($ipreq->state == $IPAdmin::PREACTIVE) {
        #A seguito di ipreq/validate, preparo il messaggio per l'utente: "La tua richiesta è stata validata: stampa, firma ed invia il modulo via fax (o caricamento pdf?)"
        $body = <<EOF;
Gentile Utente, 
la sua richiesta è stata validata. 
Per procedere all'attivazione del nuovo indirizzo IP deve seguire il link, stampare e firmare il modulo, ed infine inviarlo via fax al 23837: 
    $url
EOF
        $subject = "Richiesta di indirizzo IP id: ".$ipreq->id." convalidata";

    }
    elsif ($ipreq->state == $IPAdmin::ACTIVE) {
        #A seguito di ipreq/activate, preparo il messaggio per l'utente: "Il tuo IP è attivo"
        #Se la richiesta è a tempo determinato invia anche un'email all'ospite
        my $ip = "151.100.".$ipreq->subnet->id.".".$ipreq->host;
        $body = <<EOF;
Gentile Utente, 
il suo indirizzo IP $ip è stato attivato.
E' ora possibile configurare la scheda di rete del dispositivo con i dati presenti nel modulo: 
    $url
EOF
        $subject = "Richiesta di indirizzo IP id: ".$ipreq->id." attiva";
        #Se il richiedente è a tempo determinato invia un'email anche al guest (ma come fa a vedere il modulo? Forse l'email non serve...)
        #if ($ipreq->guest) {
        #    $cc = $ipreq->guest->email;
        #}
    } 
    elsif ($ipreq->state == $IPAdmin::INACTIVE) {
        #A seguito di ipreq/unactivate, preparo il messaggio per l'utente: "Il tuo IP è stato bloccato. Hai X giorni di tempo per riattivarlo o verrà assegnato a qualcun altro"
        my $ip = "151.100.".$ipreq->subnet->id.".".$ipreq->host;
        $body = <<EOF;
Gentile Utente,
il suo indirizzo IP $ip è stato bloccato in seguito ad una richiesta di rinuncia di indirizzo IP o all'inattività di oltre 90 giorni.
E' possibile riattivare l'indirizzo IP, entro 7 giorni dalla ricezione di questa email, seguendo il link ed utilizzando il pulsante "Riattiva":
    $url
EOF
        $subject = "Richiesta di indirizzo IP id: ".$ipreq->id." scaduta";
        if ($ipreq->guest) {
            $cc = $ipreq->guest->email;
        }
    }
    elsif ($ipreq->state == $IPAdmin::ARCHIVED) {
        #A seguito di ipreq/delete, preparo il messaggio per l'utente: "Rinuncia dell'indirizzo IP terminata con successo"
	  my $ip;
    defined $ipreq->subnet and $ip = "151.100.".$ipreq->subnet->id.".".$ipreq->host;
        $body = <<EOF;
Gentile Utente,
La sua richiesta di indirizzo IP è stata archiviata.
    $url
EOF
        $subject = "Richiesta di indirizzo IP $ip con id: ".$ipreq->id." archiviata";
    }
    else { #perchè hai richiamato questo metodo?
    }


    my $email = {
            from    => 'ipsapienza@uniroma1.it',
            to      => $to,
            cc      => $cc,
            subject => $subject,
            body    => $body,
        };

    $c->stash(email => $email);

    #$c->log->debug(Dumper($email));
    $c->forward( $c->view('Email') );

    if ( scalar( @{ $c->error } ) ) {
        $c->flash(error_msg => "Errore nell'invio dell'Email. ".Dumper($c->error));
        $c->error(0);
        return 0;
    } else {
        $c->flash(mail_message => "Email inviata correttamente a $to");
        return 1;
    }
}


=head2 dnsupdate
invia un update al dns aggiungendo o rimuovendo un record a seconda dello stato della richiesta
=cut

sub dnsupdate : Chained('object') : PathPart('dnsupdate') : Args(0) {
     my ( $self, $c ) = @_;
    my $iprequest = $c->stash->{'object'};
    my ($realm, $user) = IPAdmin::Utils::find_user($self,$c,$c->session->{user_id});
    if(defined $user){
    $c->stash( default_backref => $c->uri_for_action('userldap/view',[$user->username]) );
    $c->stash( default_backref => $c->uri_for_action('iprequest/list') ) if( $realm eq  "normal" );
    }
  
    if ( lc $c->req->method eq 'post' ) {
      
        if ($iprequest->state == $IPAdmin::ACTIVE) {
            #A seguito di iprequest/activate, invio update per aggiungere il record A nella zona corretta
        } 
        elsif ($iprequest->state == $IPAdmin::ARCHIVED) {
            #A seguito di iprequest/delete, invio update per rimuovere il record A dalla zona corretta, e gli eventuali CNAME da qualsiasi zona
        }
        else { #perchè hai richiamato questo metodo?
        }
 
       
         $c->forward('process_notify');
         $c->flash( message => 'Update inviato correttamente.');

         $c->detach('/follow_backref');
   }
   else {
       $c->stash( template => 'generic_confirm.tt' );
   }
}


=head2 list_js

=cut

sub list_js :Chained('base') :PathPart('list/js') :Args(0) {
    my ($self, $c) = @_;

    my @col_names = qw(id state date type user building department 
                       manager macaddress hostname domain subnet host);

    $c->stash(col_names => \@col_names);
    my @col_searchable = qw(  me.id me.state me.date type.type user.fullname building.name department.name 
                            manager.fullname me.macaddress me.hostname department.domain subnet.id host);
    $c->stash(col_searchable => \@col_searchable);

    $c->stash(resultset_search_opt =>
                {prefetch => ['type','user','subnet',{area => ['building','department', 'manager']}]}
               );

    $c->stash(col_formatters => {
        id => sub {
            my ($c, $rs)= @_;
            return '<a id="click_ref" href="' .
              $c->uri_for_action('/iprequest/view',  [ $rs->id ]) .
                '">' . $rs->id . '</a>';
        },
        state => sub {
            my ($c, $rs)= @_;
            my $label;
            $rs->state eq 0 and $label = "Nuova";
            $rs->state eq 1 and $label = "Convalidata";
            $rs->state eq 2 and $label = "Attiva";
            $rs->state eq 3 and $label = "Pre-Arch.";
            $rs->state eq 4 and $label = "Archiviata";
            return $label;
        },
        date => sub {
            my ($c, $rs)= @_;
            return IPAdmin::Utils::print_short_timestamp($rs->date),
        },
        type => sub {
            my ($c, $rs)= @_;
            return $rs->type->type;
        },
        user => sub {
            my ($c, $rs)= @_;
            return '<a href="' .
              $c->uri_for_action('/userldap/view',  [ $rs->user->username ]) .
                '">' . $rs->user->fullname . '</a>';
        },
        building => sub {
            my ($c, $rs)= @_;
            return '<a href="' .
              $c->uri_for_action('/building/view',  [ $rs->area->building->id ]) .
                '">' .$rs->area->building->name. '</a>';
        },
        department => sub {
            my ($c, $rs)= @_;
            return '<a href="' .                
            $c->uri_for_action('/department/view',  [ $rs->area->department->id ]) .
            '">' .$rs->area->department->name. '</a>';
        },        
        manager => sub {
            my ($c, $rs)= @_;
            defined $rs->area->manager and return $rs->area->manager->fullname;
        },
        macaddress => sub {
            my ($c, $rs)= @_;
            return $rs->macaddress;
        },
        subnet => sub {
            my ($c, $rs)= @_;
            defined($rs->subnet) and return $rs->subnet->id;
            return '';
        },
        host => sub {
            my ($c, $rs)= @_;
            defined($rs->host) and return $rs->host; 
            return '';
        },
        domain => sub {
            my ($c, $rs)= @_;
            defined($rs->area->department->domain) and 
                return $rs->area->department->domain;
            return '';
        },
        hostname => sub {
            my ($c, $rs)= @_;
            defined($rs->hostname) and 
                return $rs->hostname;
            return '';
        },


    });
    
    $c->stash(ip_search => 1) if($c->request->param('sSearch') =~ m/(\d+)\.(\d*)/g);
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
