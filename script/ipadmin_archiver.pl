#!/usr/bin/perl
# -*- cperl -*-
use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";
use IPAdmin::Support;

package IPAdmin::Archiver;
use Moose;
use IPAdmin::Logger;
use IPAdmin::Utils;
use IPAdmin::Manoc;
use Data::Dumper;

#Mail requirements
use Email::Sender::Simple qw(sendmail);
use Email::Simple;
use Email::Simple::Creator;
use Email::Sender::Transport::SMTP;

extends 'IPAdmin::App';

our $NEW       = 0;
our $PREACTIVE = 1;
our $ACTIVE    = 2;
our $INACTIVE  = 3;
our $ARCHIVED  = 4;
our $A_WEEK    = 86400 * 7;

has 'manoc_schema' => (
    traits  => ['NoGetopt'],
    is      => 'ro',
    lazy    => 1,
    builder => '_build_manoc_schema'
);

has 'transport' => (
    traits  => ['NoGetopt'],
    is      => 'ro',
    lazy    => 1,
    builder => '_build_transport'
);
has 'dryrun' => (
    is       => 'rw',
    isa      => 'Bool',
    required => 0
);

has 'blocked_ip' => (
    traits  => ['NoGetopt'],
    is      => 'ro',
    lazy    => 1,
    builder => '_build_blocked_ip'
);

sub _build_blocked_ip {
    my $self = shift;
    return {};
}

sub _build_transport {
    my $self = shift;
    my $transport = Email::Sender::Transport::SMTP->new({
        host     => 'smtp.googlemail.com', 
        ssl      => 1, 
        port     => 465,
        timeout => 10,
        sasl_username => 'w3.staff@uniroma1.it', #'ipsapienza@uniroma1.it',
        sasl_password => 'C1t1c0rd',             #'grecia69',
    });
}



sub _build_manoc_schema {
    my $self = shift;

    my $config       = $self->config;
    my $connect_info = $config->{'Model::ManocDB'}->{connect_info};
    my $schema       = IPAdmin::Manoc->connect(@$connect_info);

    return $schema;
}

=head2 archive_new

Cancella le richieste rimaste non validate per più di $conf->{'archive_new'} giorni

=cut

sub archive_new {
    my ($self, $time) = @_;
    my $conf         = $self->config->{'Archiver'} 
    || $self->log->logdie("Could not find config file!") ;
    my $schema       = $self->schema;
    my $archive_new  = IPAdmin::Utils::str_to_seconds($conf->{'archive_new'}); 
    my $tot_archived = 0;

   if (! $archive_new) {
	$self->log->info("Archiver: soglia archive_new = 0: skipping.");
    #$self->report->add_error({ type   =>'archive',
    #message => 'archive_new = 0: skipping'});
	return;
    }
    my $archive_date = $time - $archive_new;
    
    $self->log->info("Archiviazione nuove richieste non validate dal giorno" .
		  IPAdmin::Utils::print_short_timestamp($archive_date));
    #$self->report->archive_date(IPAdmin::Utils::print_timestamp($archive_date));
       
    my $it = $schema->resultset('IPRequest')->search({
            'state'  => $NEW,
            'date'   => { '<', $archive_date },         
	});

    my @archived;
    while(my $i = $it->next){
       #TODO richiamare azione iprequest/delete
       #mandare email (ma già lo fa l'azione)
       $self->dryrun or $self->process_archive($i);

       push @archived, { 
                         id     => $i->id,
                         name   => $i->user->fullname,
                         mail   => $i->user->email, 
                       };
    }
    return \@archived;

}

sub process_prearchive {
    my ($self,$iprequest) = @_;
        my $subject;
        my $body; 
        my $cc;
       
        #mail
     if($iprequest->state eq $ACTIVE){
          my $ip = "151.100.".$iprequest->subnet->id.".".$iprequest->host;
          $subject = "Archiviazione Indirizzo IP: $ip";
 
          if(defined $iprequest->guest){
            #richiesta a tempo det che sta per scadere
            $body = <<EOF;
Gentile Utente,
La avvertiamo che tra una settimana la Sua richiesta di indirizzo IP $ip a tempo determinato scadrà.
EOF
            send_email($iprequest->guest->email, $iprequest->user->email,$subject,$body);
          }
          else{
            $body = <<EOF;
Gentile Utente,
il suo indirizzo IP $ip tra una settimana sarà bloccato in seguito ad una inattività di oltre 90 giorni
EOF
             send_email($iprequest->mail, undef,$subject,$body);
          }
      }
          
}



sub process_archive {
    my ($self,$iprequest) = @_;
        my $subject;
        my $body; 
        my $cc;
        #Archivia la richiesta
        $iprequest->state($ARCHIVED);
        $iprequest->update;
        #chiude l'ultima assegnazione
        my @assignements = $iprequest->map_assignement;

        foreach my $assignement (@assignements){
            if($assignement->state eq $ACTIVE){
                $assignement->update({
                        date_out => time,
                        state    => $ARCHIVED,
                     });
            }
        }
        #alias
        my @alias = $iprequest->map_alias;
        foreach my $alias (@alias){
            if($alias->state ne $ARCHIVED){
                $alias->update({
                        state    => $ARCHIVED,
                     });
            }
        }
        #mail
        if($iprequest->state eq $NEW){
          $subject = "Archiviazione Richiesta IP con Id ".$iprequest->id;
          $body = <<EOF;
Gentile Utente,
la sua richiesta IP è stata archiviata in quanto non è stata validata dal referente di rete.
EOF
          send_email($iprequest->mail, undef,$subject,$body);
        }

       if($iprequest->state eq $PREACTIVE){
        $subject = "Archiviazione Richiesta IP con Id ".$iprequest->id;
        $body = <<EOF;
Gentile Utente,
la sua richiesta IP è stata archiviata in quanto non è pervenuto il fax con la richiesta firmata.
EOF
        send_email($iprequest->mail, undef,$subject,$body);
       }

      if($iprequest->state eq $ACTIVE){
          my $ip = "151.100.".$iprequest->subnet->id.".".$iprequest->host;
          $subject = "Archiviazione Indirizzo IP: $ip";
 
          if(defined $iprequest->guest){
            $body = <<EOF;
Gentile Utente,
il suo indirizzo IP $ip è stato bloccato poiché sono scaduti i termini di utilizzo.
EOF
            send_email($iprequest->guest->email, $iprequest->user->email,$subject,$body);
          }
          else{
            $body = <<EOF;
Gentile Utente,
il suo indirizzo IP $ip è stato bloccato in seguito ad una inattività di oltre 90 giorni
EOF
             send_email($iprequest->mail, undef,$subject,$body);
          }
        #prepara la struttura dati con gli IP bloccati per poi compliare l'ACL
        my $vlan = $iprequest->subnet->vlan->id;
        defined $self->blocked_ip->{$vlan} or $self->blocked_ip->{$vlan} = [];
        push @{$self->blocked_ip->{$vlan}}, $ip;
      }
          
}


=head2 archive_pre

Cancella le richieste rimaste validate ma non attivate per più di $conf->{'archive_pre'} giorni

=cut

sub archive_pre {
    my ($self, $time) = @_;
    my $conf         = $self->config->{'Archiver'} || $self->log->logdie("Could not find config file!") ;
    my $schema       = $self->schema;
    my $archive_pre  = IPAdmin::Utils::str_to_seconds($conf->{'archive_pre'}); 
    my $tot_archived = 0;

   if (! $archive_pre) {
    $self->log->info("Archiver: soglia archive_pre = 0: skipping.");
    #$self->report->add_error({ type   =>'archive',
    #message => 'archive_pre = 0: skipping'});
    return;
    }
    my $archive_date = $time - $archive_pre;
    
    $self->log->info("Archiviazione richieste validate prima del " .
          IPAdmin::Utils::print_short_timestamp($archive_date));
    #$self->report->archive_date(IPAdmin::Utils::print_timestamp($archive_date));
       
    my $it = $schema->resultset('IPRequest')->search({
            'me.state'  => $PREACTIVE,
            'map_assignement.date_in' => { '<', $archive_date },
            'map_assignement.state'   => $ACTIVE,
            'subnet.archivable'       => 1,
            'type.archivable'         => 1,
        },
        {
            join => ['map_assignement', 'subnet', 'type'],
        });

    my @archived;
    while(my $i = $it->next){
       #TODO richiamare azione iprequest/delete
       #mandare email (ma già lo fa l'azione)
       $self->dryrun or $self->process_archive($i);

       push @archived, { 
                         id     => $i->id,
                         name   => $i->user->fullname,
                         fqdn   => $i->hostname.".".$i->area->department->domain,
                         mail   => $i->user->email, 
                         subnet => $i->subnet->id, 
                         host   => $i->host
                       };
    }
    return \@archived;
}

=head2  archive_active_manager

=cut

sub archive_active_manager {
  my ($self, $time) = @_;
  my $schema         = $self->schema;
  my @archived;
  my $warn_date    = $time + $A_WEEK; # una settimana nel futuro?

  $self->log->info("Archiviazione richieste referenti scadute oggi" );

  my $it = $schema->resultset('ManagerRequest')->search({
            'date_out' => { '<=', $time }, 
            'state'   => $ACTIVE,
            });

    while(my $i = $it->next){

      if(!$self->dryrun){
        $i->update({ state => $ARCHIVED });
        my $subject = "Archiviazione Richiesta Referente di Rete con Id ".$i->id;
        my $fullname = $i->user->fullname;
        my $body = <<EOF;
Gentile referente di rete $fullname,
la inforiamo che la sua nomina a Referente di Rete è scaduta in data odierna. Contattare gli amministratori di rete.
EOF
        send_email($i->user->email, undef,$subject,$body);

       }

      push @archived, { 
                         id     => $i->id,
                         name   => $i->user->fullname,
                         mail   => $i->user->email, 
                         department => $i->department->name,
                       };
    }
    return \@archived;
}


=head2 archive_active

Cancella le richieste attive mai viste da MaNOC o non connesse da 90 giorni:

=cut

sub archive_active {
    my ($self, $time) = @_;
    my $conf           = $self->config->{'Archiver'} 
    || $self->log->logdie("Could not find config file!") ;
    my $schema         = $self->schema;
    my $archive_active = IPAdmin::Utils::str_to_seconds($conf->{'archive_active'}); 
    my $tot_archived = 0;

   if (! $archive_active) {
    $self->log->info("Archiver: soglia archive_active = 0: skipping.");
    #$self->report->add_error({ type   =>'archive',
    #message => 'archive_active = 0: skipping'});
    return;
    }
    my $archive_date = $time - $archive_active;
    
    $self->log->info("Blocco IP scaduti inattivi dal " .
          IPAdmin::Utils::print_short_timestamp($archive_date));
    #$self->report->archive_date(IPAdmin::Utils::print_timestamp($archive_date));

    my $it = $schema->resultset('IPRequest')->search({
            'me.state' => $ACTIVE,
            'map_assignement.date_in' => { '<', $archive_date }, 
            'map_assignement.state'   => $ACTIVE,
            'subnet.archivable'     => 1,
            'type.archivable'       => 1,
            },
            {
            join => ['map_assignement','subnet', 'type']
            });

    #TODO CONNESSIONE MANOC
    #ARCHIVIA l'indirizzo IP se
    #1)non trova niente dentro manoc
    #2)o il lastseen di quell'IP e quel mac è > di $archive_active giorni
    my @archived;
    my @prearchived;
    my $result;
    #my $int = 0;
    while(my $i = $it->next){
        next if(!defined($i->subnet) or !defined($i->host));
        my $check_ip = "151.100.".$i->subnet->id.".".$i->host;
        my $check_mac= $i->macaddress;
        $result = $self->manoc_schema->resultset('Arp')->search({
                       ipaddr   => $check_ip, 
                       macaddr  => $check_mac,
                       lastseen => {">=", $archive_date} });
        
        if(!defined($result->first)){     
            my $domain = $i->area->department->domain || '';
            push @archived, { 
                         id     => $i->id,
                         fqdn   => $i->hostname.".".$domain,
                         name   => $i->user->fullname,
                         mail   => $i->user->email, 
                         subnet => $i->subnet->id, 
                         host   => $i->host
                       };
            $self->dryrun or $self->process_archive($i);
        }else{
          my $max_lastseen = $result->get_column('lastseen')->max;
          my $warn_date    = $archive_date + $A_WEEK; 
          if($max_lastseen > $archive_date and $max_lastseen <= $warn_date){
            #se l'ultima volta che si è visto l'ip in rete è nella settimana successiva alla data di scadenza archive_date
            #significa che tra sette giorni la richiesta scade 
            
            push @prearchived, { 
                         id     => $i->id,
                         fqdn   => $i->hostname.".".$i->area->department->domain,
                         name   => $i->user->fullname,
                         mail   => $i->user->email, 
                         subnet => $i->subnet->id, 
                         host   => $i->host
                       };
            $self->dryrun or $self->process_prearchive($i);
          }
        }
    }

    #Se è a tempo determinato e è scaduto archivia 
    #controlla solo su ipassignement.date_out e state==2

    $it = $schema->resultset('IPRequest')->search({
            'me.state' => $ACTIVE,
            'map_assignement.date_out' => { '>=', $time }, 
            'map_assignement.state'   => $ACTIVE,
            'subnet.archivable'     => 1, # li togliamo i controlli visto che sono,
            'type.archivable'       => 1, # per definizione, a tempo determinato?
            # guest is not null ?
            },
            {
            join => ['map_assignement','subnet', 'type']
            });
    while(my $i = $it->next){
    $self->dryrun or $self->process_archive($i);
    push @archived, { 
                         id     => $i->id,
                         name   => $i->user->fullname,
                         mail   => $i->user->email, 
                         subnet => $i->subnet->id, 
                         host   => $i->host
                       };
    }

    $it = $schema->resultset('IPRequest')->search({
            'me.state' => $ACTIVE,
            'map_assignement.date_out' => { -and => {'>=' => $time - $A_WEEK,
                                                      '<' => $time   }}, 
            'map_assignement.state'   => $ACTIVE,
            'subnet.archivable'     => 1, # li togliamo i controlli visto che sono,
            'type.archivable'       => 1, # per definizione, a tempo determinato?
            # guest is not null ?
            },
            {
            join => ['map_assignement','subnet', 'type']
            });
    while(my $i = $it->next){
    $self->dryrun or $self->process_prearchive($i);
    push @prearchived, { 
                         id     => $i->id,
                         name   => $i->user->fullname,
                         mail   => $i->user->email, 
                         subnet => $i->subnet->id, 
                         host   => $i->host
                       };
    }


    return (\@archived,\@prearchived);
}


sub prepare_blocked_mail {
    my ( $self, $archived_new, $archived_preactive, $archived_active) = @_;
    my $link = $self->config->{'Link'}->{'ipadmin'};

    my $body = "RICHIESTE NON VALIDATE SCADUTE:\n";
    foreach my $i (@{$archived_new}){
        $body .= sprintf("http://%s/iprequest/id/%s/view \t%20s\t%20s\n", $link, $i->{id},$i->{name},$i->{mail});
    };

    $body .= "\nRICHIESTE VALIDATE MA NON ATTIVATE:\n";
    foreach my $i (@{$archived_preactive}){
        $body .= sprintf("Id:%3s\t151.100.%s.%s\t%25s\t%20s\t%20s\n", $i->{id},$i->{subnet},
                                                    $i->{host},$i->{fqdn},$i->{name},$i->{mail});
    };

    $body .= "\nRICHIESTE ATTIVE SCADUTE:\n";
    foreach my $i (@{$archived_active}){
        $body .= sprintf("Id:%3s\t151.100.%s.%s\t%25s\t%20s\t%20s\n", $i->{id},$i->{subnet},
                                        $i->{host},$i->{fqdn},$i->{name},$i->{mail});
    };

    return $body; 
}


sub send_email {
    my ($self,$to,$cc,$subject,$body) = @_;
 
    my $email = Email::Simple->create(
    header =>  [ 
      To      => 'e.liguori@cineca.it',
      From    => 'w3.staff@uniroma1.it',
      Subject => $subject,
      Cc      => 's.italiano@cineca.it',
    ],
    body   =>  $body,
  );

  my $result = sendmail($email, { transport => $self->transport });
}

sub run {
    my ($self) = @_;
    my $time = time;

    my $archived_new       = $self->archive_new($time);
    my $archived_preactive = $self->archive_pre($time);
    my ($archived_active,$prearchived) = $self->archive_active($time);

    my $archived_active_man = $self->archive_active_manager($time);


   print "Nuove Scadute: ".Dumper($archived_new);
   print "Convalid. Scadute ".Dumper($archived_preactive);
   print "Attive Scadute: ". Dumper($archived_active);
   print "Scadute tra sette giorni: ".Dumper($prearchived);
   print "Richieste Ref Scadute: ".Dumper($archived_active_man);

   my $body = $self->prepare_blocked_mail($archived_new, $archived_preactive, $archived_active);
   $self->send_email('e.liguori@cineca.it',undef,
              'Elenco IP Scaduti '.IPAdmin::Utils::print_short_timestamp(time),$body);
  
    # TODO prepara ACL partendo da $self->blocked_ip
}




no Moose;

package main;

my $app = IPAdmin::Archiver->new_with_options();
$app->run();

# Local Variables:
# mode: cperl
# indent-tabs-mode: nil
# cperl-indent-level: 4
# cperl-indent-parens-as-block: t
# End:
