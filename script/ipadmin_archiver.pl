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
our $A_WEEK    = 3600 * 7;

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


sub _build_transport {
    my $self = shift;
    my $transport = Email::Sender::Transport::SMTP->new({
        host     => 'smtp.googlemail.com', 
        ssl      => 1, 
        port     => 465,
        timeout => 10,
        sasl_username => 'w3.staff@uniroma1.it',
        sasl_password => 'C1t1c0rd',
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

sub process_archive {
    my ($self,$iprequest) = @_;

        #Archivia la richiesta
        $iprequest->state($IPAdmin::ARCHIVED);
        $iprequest->update;
        #chiude l'ultima assegnazione
        foreach my $assignement (@{$iprequest->map_assignement}){
            if($assignement->state eq $IPAdmin::ACTIVE){
                $assignement->update({
                        date_out => time,
                        state    => $IPAdmin::ARCHIVED,
                     });
            }
        }
        #TODO alias?
        foreach my $alias (@{$iprequest->map_alias}){
            if($alias->state ne $IPAdmin::ARCHIVED){
                $alias->update({
                        state    => $IPAdmin::ARCHIVED,
                     });
            }
        }
        #TODO mail
        my $ip = "151.100.".$iprequest->subnet->id.".".$iprequest->host;
        my $subject = "Archiviazione Indirizzo IP: $ip";
        my $body; 
 
        if(defined $iprequest->guest){
            $body = <<EOF;
Gentile Utente,
il suo indirizzo IP $ip è stato bloccato poiché sono scaduti i termini di utilizzo.
EOF
            send_email($iprequest->guest->email, $iprequest->user->email,
                            $subject,$body);
            return;
        }

        $body = <<EOF;
Gentile Utente,
il suo indirizzo IP $ip è stato bloccato in seguito ad una inattività di oltre 90 giorni
EOF
        send_email($iprequest->mail, undef,$subject,$body);
       
        #TODO blocca indirizzo su centrostella

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
        },
        {
            join => ['map_assignement', 'subnet'],
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
                         subnet => $i->subnet->id, 
                         host   => $i->host
                       };
    }
    return \@archived;
}

=head2 archive_active

Cancella le richieste di:

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
    my $warn_date    = $time - $A_WEEK;
    
    $self->log->info("Blocco IP scaduti inattivi dal " .
          IPAdmin::Utils::print_short_timestamp($archive_date));
    #$self->report->archive_date(IPAdmin::Utils::print_timestamp($archive_date));

    #TODO AVVISA CHI TRA 7 GIORNI SCADE IP

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
    #2)o il lastseen di quell'IP e quel mac è > di 90 giorni
    my @archived;
    while(my $i = $it->next){
        next if(!defined($i->subnet) or !defined($i->host));
        my $check_ip = "151.100.".$i->subnet->id.".".$i->host;
        my $check_mac= $i->macaddress;
        my $result = $self->manoc_schema->resultset('Arp')->search({
                       ipaddr   => $check_ip, 
                       macaddr  => $check_mac,
                       lastseen => {">", $archive_date} })->single;
        if(!defined ($result)){     
            push @archived, { 
                         id     => $i->id,
                         name   => $i->user->fullname,
                         mail   => $i->user->email, 
                         subnet => $i->subnet->id, 
                         host   => $i->host
                       };
            $self->dryrun or $self->process_archive($i);
        }
    }

    #Se è a tempo determinato e è scaduto archivia 
    #controlla solo su ipassignement.date_out e state==2

    $it = $schema->resultset('IPRequest')->search({
            'me.state' => $ACTIVE,
            'map_assignement.date_out' => { '>=', $time }, 
            'map_assignement.state'   => $ACTIVE,
            'subnet.archivable'     => 1,
            'type.archivable'       => 1,
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
    return \@archived;
}

sub run {
    my ($self) = @_;
    my $time = time;

    my @archived_new       = $self->archive_new($time);
    my @archived_preactive = $self->archive_pre($time);
    my @archived_active    = $self->archive_active($time);

    #send_admin_email(\@archived_new,\@archived_preactive,\@archived_active);

    print Dumper(\@archived_new);
    print Dumper(\@archived_preactive);
    print Dumper(\@archived_active);

    my $body = <<EOF;
bla bla bla
EOF
    $self->send_email('sapienzanet@uniroma1.it',undef,'IPAdmin Archiver',$body);
}

sub send_email {
    my ($self,$to,$cc,$subject,$body) = @_;
 
    my $email = Email::Simple->create(
    header =>  [ 
      To      => $to,
      From    => 'sapienzanet@uniroma1.it',
      Subject => $subject,
      Cc      => $cc,
    ],
    body   =>  $body,
  );

  my $result = sendmail($email, { transport => $self->transport });
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
