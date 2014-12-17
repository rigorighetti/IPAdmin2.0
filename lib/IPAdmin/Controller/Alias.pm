# Copyright 2011 by the IPAdmin Team
#
# This library is free software. You can redistribute it and/or modify
# it under the same terms as Perl itself.
package IPAdmin::Controller::Alias;
use Moose;
use namespace::autoclean;
use IPAdmin::Form::Alias;
use Data::Dumper;
use Email::Send;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

IPAdmin::Controller::Alias - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index

=cut

sub index : Path : Args(0) {
    my ( $self, $c ) = @_;
    $c->response->redirect('alias/list');
    $c->detach();
}

=head2 base

=cut

sub base : Chained('/') : PathPart('alias') : CaptureArgs(0) {
    my ( $self, $c ) = @_;
    $c->stash( resultset => $c->model('IPAdminDB::Alias') );
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

=cut

sub list : Chained('base') : PathPart('list') : Args(0) {
    my ( $self, $c ) = @_;

    my $alias_schema = $c->stash->{resultset};

    my @alias_table = map +{
        id          => $_->id,
        cname       => $_->cname,
        ip          => "151.100.".$_->ip_request->subnet->id.".".$_->ip_request->host,
        iprequest   => $_->ip_request,
        hostname    => $_->ip_request->hostname,
        dominio     => $_->ip_request->area->department->domain,
        state       => $_->state,
        user        => $_->ip_request->user,
        }, $alias_schema->search({}, {prefetch => [{ip_request => [{area => 'department'},'user','subnet',]}]});

    $c->stash( alias_table => \@alias_table );
   # -- Costruzione dei contatori della legenda --
   my %stats;
   $stats{nuove}       =  $c->model('IPAdminDB::Alias')->search({state => $IPAdmin::NEW })->count();
   $stats{validate}    =  $c->model('IPAdminDB::Alias')->search({state => $IPAdmin::PREACTIVE})->count();
   $stats{attivi}      =  $c->model('IPAdminDB::Alias')->search({state => $IPAdmin::ACTIVE })->count();
   $stats{archiviati}  =  $c->model('IPAdminDB::Alias')->search({state => $IPAdmin::ARCHIVED})->count();

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
    $c->stash( template       => 'alias/list.tt' );
}

=head2 view

=cut

sub view : Chained('object') : PathPart('view') : Args(0) {
    my ( $self, $c ) = @_;

    $c->stash( template => 'alias/view.tt' );
}

=head2 edit

=cut

sub edit : Chained('object') : PathPart('edit') : Args(0) {
    my ( $self, $c ) = @_;      
    my $req = $c->stash->{'object'};
    my $def_br ; 
    my ($realm, $user) = IPAdmin::Utils::find_user($self,$c,$c->session->{user_id}); 
    !defined($user) and $c->detach('/access_denied');
    if($realm eq "normal"){
        $def_br = $c->uri_for_action('alias/list');
    } else {
        $def_br = $c->uri_for_action('userldap/view', [$user->username]);
    }

    if($req->state != $IPAdmin::NEW){
        $c->flash( message => 'Solo le richieste non ancora validate possono essere modificate.');
        $c->stash( default_backref => $def_br );
        $c->detach('/follow_backref');
    }

    $c->forward('save');
}

=head2 save

# Handle create and edit resources

=cut

 sub save : Private {
    my ( $self, $c ) = @_;   
    my $def_ipreq = $c->req->param('def_ipreq') || -1;
    my $item = $c->stash->{object}; 
    my ($realm, $user) = IPAdmin::Utils::find_user($self,$c,$c->session->{user_id}); 
    !defined($user) and $c->detach('/access_denied');
    
    $c->stash(user => $user);
    if(!defined $item){ 
        defined $def_ipreq ? $item = $c->stash->{resultset}->new_result( {ip_request => $def_ipreq} ) : $item = $c->stash->{resultset}->new_result( {} );
        delete $c->req->params->{'def_ipreq'} 
    }

     #set the default backref according to the action (create or edit)
    my $def_br = $c->uri_for('/alias/list');
    $def_br = $c->uri_for_action( 'alias/view', [ $c->stash->{object}->id ] )
         if ( defined( $c->stash->{object} ) );
     $c->stash( default_backref => $def_br );

    my $form = IPAdmin::Form::Alias->new( {item => $item, def_ipreq => $def_ipreq} );
     $c->stash( form => $form, template => 'alias/save.tt' );

     # the "process" call has all the saving logic,
     #   if it returns False, then a validation error happened

     if ( $c->req->param('discard') ) {
         $c->detach('/follow_backref');
     }
     return unless $form->process( params => $c->req->params);

     $c->flash( message => 'Success! Alias created.' );
     $def_br = $c->uri_for_action( 'alias/view', [ $item->id ] );
     $c->stash( default_backref => $def_br );
     $c->detach('/follow_backref');
 }

=head2 create

=cut

sub create : Chained('base') : PathPart('create') : Args(0) {
    my ( $self, $c ) = @_;
    my $id;
    my @my_ips;

    my $def_ipreq = $c->req->param('def_ipreq');
    my $ipreq = $c->model("IPAdminDB::IPRequest")->find($def_ipreq);
    
    my ($realm, $user) = IPAdmin::Utils::find_user($self,$c,$c->session->{user_id}); 
    !defined($user) and $c->detach('/access_denied');
    $c->stash( default_backref => $c->uri_for_action('userldap/view',[$user->username]) );
    $c->stash( default_backref => $c->uri_for_action('alias/list') ) if( $realm eq  "normal" );
    
    #Controlla che la richiesta sia attiva
    if(defined $ipreq and $ipreq->state ne $IPAdmin::ACTIVE ){
        $c->flash( error_msg => "Per creare una richiesta di Alias l'IP deve essere attivo (e la richiesta IP accettata)" );
        $c->detach('/follow_backref');
    }

    if (defined $def_ipreq and !defined($ipreq) ) {
        $c->flash( error_msg => "Indirizzo IP selezionato non valido" );
        $c->detach('/follow_backref');
    }

    if(!defined $def_ipreq){
        #TODO se non viene indicata la richiesta popolare my_ips 
        #con tutti gli IP in carico all'utente loggato ora
        #se è l'admin la lista di tutti gli IP
    }


    if ( lc $c->req->method eq 'post' ) {
        if ( $c->req->param('discard') ) {
            $c->detach('/follow_backref');
        }
        my $done = $c->forward('process_create');
        if ($done) {
            $c->flash( message => $c->stash->{message} );
            $c->stash( default_backref =>
                $c->uri_for_action( "alias/list" ) )if ( $realm eq  "normal" ); # da cambiare!
            $c->detach('/follow_backref');
        }
    }
    #set form defaults
    my %tmpl_param;
    my @users;

    if(defined $ipreq){
    $tmpl_param{ip}       ="151.100.".$ipreq->subnet->id.".".$ipreq->host;
    $tmpl_param{hostname} = $ipreq->hostname;
    $tmpl_param{dominio}  = $ipreq->area->department->domain;
    }
    $tmpl_param{alias}  = $c->req->param('alias');
    $c->stash(%tmpl_param);
}

sub process_create : Private {
    my ( $self, $c ) = @_;
    my $def_ipreq = $c->req->param('def_ipreq');
    my $alias = $c->req->param('alias');
    my ($realm, $user) = IPAdmin::Utils::find_user($self,$c,$c->session->{user_id}); 
    !defined($user) and $c->detach('/access_denied');

    my $ipreq = $c->model("IPAdminDB::IPRequest")->find($def_ipreq);

    my $error;

    # check form
    $c->forward('check_alias_form') || return 0; 

    #la richiesta ip deve essere attiva
    if ($ipreq->state ne $IPAdmin::ACTIVE) {
     $c->stash->{error_msg} = "Per poter definire un alias la richiesta IP deve essere attiva";
     return 0;
    }
    #l'utente che fa richiesta per l'alias deve aver assegnato l'ip
    if ($realm eq "ldap" and $user->id ne $ipreq->user->id) {
     $c->stash->{error_msg} = "Solo il responsabile di un indirizzo IP può definire un Alias su quel determinato IP";
     return 0;
    }    

    my $ret = $c->stash->{'resultset'}->create({
                        cname       => $alias,
                        ip_request  => $def_ipreq,
                        state       => $IPAdmin::NEW,
                       });
    
    if (! $ret ) {
    $c->stash->{error_msg} = "Errore nella creazione dell'Alias'";
    return 0;
    } else {
    $c->stash->{message} = "L'Alias è stato creato.";
    return 1;
    }
}

sub check_alias_form : Private {
    my ( $self, $c) = @_;
    my $schema  = $c->stash->{'resultset'};
    my $alias   = $c->req->param('alias');
    my $r       = $c->stash->{object};

    if ( $alias eq '' ) {
        $c->stash(error => {alias => "L'alias non può essere vuoto"});
        return 0;
    }

    if( $schema->search({cname => $alias})->single ){
        $c->stash(error => {alias => "Alias già esistente! Scegliere un altro nome"});
        return 0;
    }
    return 1;
}


=head2 delete

=cut

sub delete : Chained('object') : PathPart('delete') : Args(0) {
    my ( $self, $c ) = @_;
    my $alias = $c->stash->{'object'};
    my ($realm, $user) = IPAdmin::Utils::find_user($self,$c,$c->session->{user_id}); 
    !defined($user) and $c->detach('/access_denied');
    $c->stash( default_backref => $c->uri_for_action('userldap/view',[$user->username]) );
    $c->stash( default_backref => $c->uri_for_action('alias/list') ) if( $realm eq  "normal" );

  
    if ( lc $c->req->method eq 'post' ) {
        #Archivia la richiesta
        $alias->state($IPAdmin::ARCHIVED);
        $alias->update;

        #TODO: Cancella il CNAME dal DNS

         $c->flash( message => "L'alias non è più attivo." );
         $c->forward('process_notify');
         $c->detach('/follow_backref');
   }
   else {
       $c->stash( template => 'generic_delete.tt' );
   }
}

sub activate : Chained('object') : PathPart('activate') : Args(0) {
    my ( $self, $c ) = @_;
    my $req = $c->stash->{'object'};
    my ($realm, $user) = IPAdmin::Utils::find_user($self,$c,$c->session->{user_id}); 
    !defined($user) and $c->detach('/access_denied');
    $c->stash( default_backref => $c->uri_for_action('userldap/view',[$user->username]) );
    $c->stash( default_backref => $c->uri_for_action('alias/list') ) if( $realm eq  "normal" );
    if ( lc $c->req->method eq 'post' ) {
        if ( $c->req->param('discard') ) {
            $c->detach('/follow_backref');
        }
        my $done = $c->forward('process_activate');
        if ($done) {
            $c->flash( message => $c->stash->{message} );
            $c->forward('process_notify');
            $c->stash( default_backref =>
                $c->uri_for_action( "alias/list" ) ); # da cambiare!
            $c->detach('/follow_backref');
        }
    }
    else{
          $c->stash( template => 'generic_confirm.tt' );
    }
}


sub process_activate : Private {
    my ( $self, $c ) = @_;
    my $error;

    #Cambia lo stato dell'alias
    $c->stash->{object}->state($IPAdmin::ACTIVE);
    $c->stash->{object}->update;

    #TODO: Aggiornamento DNS
   
    my $ret = 1;
    if (! $ret ) {
    $c->stash->{message} = "Errore nell'aggiornamento dell'Alias";
    return 0;
    } else {
    $c->stash->{message} = "L'Alias è ora attivo.";
    return 1;
    }
}

=head2 print

=cut

sub print : Chained('object') : PathPart('print') : Args(0) {
    my ( $self, $c ) = @_;
    my $req = $c->stash->{object};


    $c->stash( template => 'alias/print.tt' );
}

=head2 notify

=cut

sub notify : Chained('object') : PathPart('notify') : Args(0) {
   my ( $self, $c ) = @_;
   $c->stash( default_backref =>
                $c->uri_for_action( "alias/view",[$c->stash->{object}->id] ) );
   $c->forward('process_notify');
   $c->detach('/follow_backref');
}

sub process_notify : Private {
    my ( $self, $c ) = @_;
    my $error;
    my $alias = $c->stash->{object};
    my $alias_id = $alias->id;
    my $alias_cname = $alias->cname;
    my $ipreq_id = $alias->ip_request->id;
    my $ipreq_subnet = $alias->ip_request->subnet->id;
    my $ipreq_host = $alias->ip_request->host;
    my $ipreq_hostname = $alias->ip_request->hostname;
    my $ipreq_domain = $alias->ip_request->area->department->domain;
    my $ret; #status invio messaggio con Mail::Sendmail
    my ($body, $to, $cc, $subject);
    my $url = $c->uri_for_action('/alias/view',[$alias->id]);

    #default: send email to user
    $to = $alias->ip_request->user->email;

    if ($alias->state == $IPAdmin::ACTIVE) {
        #A seguito di alias/activate, preparo il messaggio per l'utente: "Il tuo alias è attivo"
        $body = <<EOF;
Gentile Utente, 
l'alias $alias_cname.uniroma1.it è stato attivato sul nome a dominio $ipreq_hostname.$ipreq_domain.uniroma1.it (151.100.$ipreq_subnet.$ipreq_host). 
E' possibile visualizzare i dettagli seguendo il link: 
    $url
EOF
        $subject = "Richiesta Alias id: $alias_id attiva";
    } 
    elsif ($alias->state == $IPAdmin::ARCHIVED) {
        #A seguito di alias/delete, preparo il messaggio per l'utente: "Rinuncia dell'Alias relativa all'indirizzo IP terminata con successo"
        $body = <<EOF;
Gentile Utente,
l'Alias $alias_cname.uniroma1.it, relativo alla richiesta id: $ipreq_id, è stato archiviato.
    $url
EOF
        $subject = "Richiesta Alias id: ".$alias->id." archiviata";
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

    $c->forward( $c->view('Email') );

    if ( scalar( @{ $c->error } ) ) {
        $c->flash(error_msg => "Errore nell'invio dell'Email. ".Dumper($c->error));
        $c->error(0);
        return 0;
    } else {
        $c->stash(mail_message => "Email inviata correttamente a $to");
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
