#!/usr/bin/perl
# -*- cperl -*-
use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

package IPAdmin::Importer;
use Moose;
use IPAdmin::Logger;
use Data::Dumper;
use DBI;
use IPAdmin::Utils;

extends 'IPAdmin::App';


has 'filename' => (
    is       => 'rw',
    isa      => 'Str',
    required => 1
);

has 'area_map' => (
    is   => 'rw',
    lazy => 1,
    builder => '_build_map',
    traits  => ['NoGetopt'],
  );

sub _build_map {
  my $self = shift;
  my ($sig,$desc,$old_id,$new_id,$i);
  my $map  = {};
  open FILE, "<", $self->filename or die $!;
  while (my $line = <FILE>) {
        ($old_id,$new_id) = $line =~ m /(\d+),(\d+)/;
        $self->log->debug($i.": ".$old_id." ".$new_id." .");
        $i += 1;
        $map->{$old_id} = $new_id;
      }
  return $map;
}

sub import {
    my $self = shift;

# #    my $conf = $self->config->{'Importer'};
#     my $i = 0;
  
#     $self->log->info("Inizio la migrazione...");

#       open FILE, "<", $self->filename or die $!;
#       while (my $line = <FILE>) {
#         ($codeA,$codeB,$combine,$win) = $line =~ m /([0-9A-Z]+),([0-9A-Z]+),(\d+),(\d+),/;

#         $self->log->debug($i.": ".$codeA." ".$codeB." ".$combine." ".$win." .");

#         $i += 1;
#         my $ret = $self->schema->resultset('Codes')->create(
#                    {
#                      codeA   => $codeA,
#                      codeB   => $codeB,
#                      combine => $combine,
#                      win     => $win,
#                      retired =>0,
#                    }
#            );   
#       }
#     $self->log->info("Import completed.".$i." rows added");
}


sub run {
    my ($self) = @_;
    my $time = time;

# Connect to the database
# See footnote 1
my $dbh = DBI->connect('DBI:mysql:database=prorete;hostname=151.100.4.23', 'root', '')
    or die "Couldn't open database: $DBI::errstr; stopped";

# Prepare the SQL query for execution
my $sth = $dbh->prepare(<<End_SQL) or die "Couldn't prepare statement: $DBI::errstr; stopped";
SELECT id_ref,email2_ref,nominativo1_ref,telefono1_ref,email1_ref,data_ref,corso_ref,struttura1_ref FROM s_referenti
End_SQL

# Execute the query
$sth->execute() or die "Couldn't execute statement: $DBI::errstr; stopped";

# Fetch each row and print it
while ( my ($id,$email,$nom1,$tel,$email_dir,$data,$corso,$struttura) = $sth->fetchrow_array() ) {
    my $user_ldap = $self->schema->resultset('UserLDAP')->search({email=>$email})->single;
    if(!defined $self->area_map->{$id}) {
       $self->log->error("Area (id $id) $struttura non trovata. ID referente $id");
       next;
    }
    defined($user_ldap) or $self->log->error("User ".$email." non trovato!");
    defined($user_ldap) or next;


    #trasforma data
    my $date_in = IPAdmin::Utils::eng_str_to_time($data);
    my $date_out = $date_in + '63113852'; #date_in + 2 anni

    if(!defined($self->schema->resultset('Area')->find($self->area_map->{$id}))){
        $self->log->error("Area ".$self->area_map->{$id}." non trovata nel nuovo IPAdmin");
        next;
    }


    $self->schema->resultset('ManagerRequest')->update_or_create({
        dir_fullname => $nom1,
        dir_email    => $email_dir,
        dir_phone    => $tel,
        date         => $date_in,
        date_in      => $date_in,
        date_out     => $date_out,
        skill        => $corso,
        state        => 2,
        area         => $self->area_map->{$id},
        user         => $user_ldap->id,
        });

    $self->schema->resultset('Area')->find($self->area_map->{$id})->update({manager => $user_ldap->id});

    $self->schema->resultset('UserRole')->update_or_create({user_id => $user_ldap->id,role_id => 3});
}


# Disconnect from the database
$dbh->disconnect();
  #  $self->import();
   
}

no Moose;

package main;

my $app = IPAdmin::Importer->new_with_options();
$app->run();

# Local Variables:
# mode: cperl
# indent-tabs-mode: nil
# cperl-indent-level: 4
# cperl-indent-parens-as-block: t
# End:
