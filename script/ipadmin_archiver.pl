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

use Data::Dumper;

extends 'IPAdmin::App';

our $NEW       = 0;
our $PREACTIVE = 1;
our $ACTIVE    = 2;
our $INACTIVE  = 3;
our $ARCHIVED  = 4;


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
       push @archived, {$i->user->fullname, $i->user->email};
    }
    return \@archived;

}

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
       push @archived, {$i->user->fullname, $i->user->email, $i->subnet->id, $i->host};
    }
    return \@archived;
}

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
    #mes    sage => 'archive_active = 0: skipping'});
    return;
    }
    my $archive_date = $time - $archive_active;
    
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
    #2)il lastseen di quell'IP e quel mac è > di 90 giorni


    #TODO se è a tempo determinato e è scaduto archivia 
    #controlla solo su ipassignement.date_out e state==2

    my @archived;
    while(my $i = $it->next){
       #TODO richiamare azione iprequest/unactivate
       #mandare email (ma già lo fa l'azione)
       push @archived, {$i->user->fullname, $i->user->email, $i->subnet->id, $i->host};
    }
    return \@archived;
}

sub run {
    my ($self) = @_;
    my $time = time;

    my @archived_new = $self->archive_new($time);
    my @archived_preactive = $self->archive_pre($time);
    my @archived_active = $self->archive_active($time);

    print Dumper(\@archived_new);
    print Dumper(\@archived_preactive);
    print Dumper(\@archived_active);

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
