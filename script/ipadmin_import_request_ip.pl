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

# Prepare the SQL query for execution    --- and ip1 <> 101 and ip1 <> 100 and ip1 <> 102 and ip1 <> 54 and ip1 <> 73
my $sth = $dbh->prepare(<<End_SQL) or die "Couldn't prepare statement: $DBI::errstr; stopped";  
SELECT id,data,email1,tipo,apparato,ubicazione,macaddress,nomenodo,ip1,ip2,tempodet,td_posizu,td_cognom,td_telefo,td_email,td_datate,id_referente,convalida FROM s_ipadd where id in (46847,46854,46700,46833,46871,46863,46864,46865,46843,46815,46816,46866,46867,46861,46869,46881,46876,46677,46857,46789,46793,46814,46868,46794,46786,46800,46790,46859,46501,46862,46808,46897,46898,46900,46891,46887,46825,46829,46820,46764,46775,46792,46731,46795,46796,46797,46689,46757,46806,46807,46826,46805,46776,46745,46890,46892,46877,46838,46839,46804,46899) order by id 
End_SQL

# Execute the query
$sth->execute() or die "Couldn't execute statement: $DBI::errstr; stopped";

my $count      = 0;
my $countemail = 0;
my $countmac   = 0;
my $countref   = 0;
my $ecount     = 0;
my $countwifi  = 0;
my $countap    = 0;
my %AREA_ERR;
my %USER_ERR;
my %MAC_ERR;
my %BUG_ERR;
my %DUP_ERR;
my %ALIAS_ERR;
my @apmac = qw(00:16:46:6b:29:16 20:aa:4b:6e:3a:06 20:aa:4b:6e:3a:06 00:1c:58:8e:8a:5a 00:1c:58:8e:8a:86 00:1c:58:8e:8b:e0 00:1c:58:8e:8c:64 00:1c:58:8e:8c:68 00:1c:58:8e:8c:96 00:1c:58:8e:8d:06 00:1c:58:8e:8d:04 00:1c:58:8e:8d:14 00:1c:58:8e:8d:3c 00:1c:58:8e:8d:44 00:1c:58:8e:8d:62 00:1c:58:8e:8d:72 00:1c:58:df:a4:92 00:1d:45:23:b2:36 00:1d:a1:fe:ca:e0 00:1d:a1:fe:cb:5c 00:1d:a1:fe:cb:f6 00:1d:a1:ff:f1:ea 00:1e:be:27:4e:68 00:1f:ca:29:30:90 00:1f:ca:29:37:de 00:1d:70:95:04:00 00:1d:70:97:4c:52 00:1d:70:97:4e:72 00:22:90:1b:6c:b4 00:22:90:1b:6d:0a 00:22:90:1b:6d:1c 00:23:5e:02:df:f6 00:23:5e:04:6f:54 00:23:5e:04:99:8a 00:21:a0:d3:b5:d0 00:24:c4:9f:da:e4 00:26:0b:4d:2d:d8 00:26:0b:4d:2e:bc 00:26:0b:4d:2e:ea 00:26:0b:4d:2f:5c 00:26:0b:4d:56:bc 00:26:0b:4d:58:22 00:26:0b:4d:58:b2 00:26:0b:4d:59:38 00:26:0b:4d:59:ca 00:26:0b:4d:5a:c2 00:26:0b:4d:bb:86 00:24:c4:a2:de:6e 00:24:c4:a2:e9:9a 9c:af:ca:00:8c:da 68:ef:bd:10:6f:e2 68:ef:bd:40:45:f2 54:75:d0:97:57:36 54:75:d0:c8:a6:b2 54:75:d0:c8:a6:c6 54:75:d0:c8:a6:da 54:75:d0:c8:a7:22 54:75:d0:c8:a7:7a 54:75:d0:c8:a7:86 54:75:d0:c8:a8:6e 54:75:d0:c8:b3:e0 54:75:d0:c8:b4:54 54:75:d0:c8:b4:6e 54:75:d0:c8:b4:aa 54:75:d0:c8:b4:b6 c8:9c:1d:7c:f3:f0 40:55:39:94:ad:b8 e8:b7:48:98:2f:72 e8:b7:48:98:30:60 e8:b7:48:98:38:38 e8:b7:48:98:39:c6 e8:b7:48:98:3c:22 e8:b7:48:98:3c:2c e8:b7:48:98:3c:36 e8:b7:48:98:3c:86 e8:b7:48:98:3c:c8 f0:f7:55:26:08:38 50:57:a8:ea:62:6c 2c:54:2d:8a:f0:3e 2c:54:2d:8a:fa:1e 2c:54:2d:8a:fa:38 88:43:e1:78:2b:0d 88:43:e1:78:2f:af 88:43:e1:37:7f:2f 88:43:e1:78:2f:bc 88:43:e1:78:2f:cb 88:43:e1:78:2f:c0 88:43:e1:78:2f:e7 88:43:e1:37:7f:3c 88:43:e1:78:2f:a6 88:43:e1:78:2c:f8 88:43:e1:37:7f:44 88:43:e1:78:2d:54 f0:f7:55:df:b3:68 50:3d:e5:f0:d2:13 24:e9:b3:67:2a:9c 30:e4:db:f6:50:d7 c0:67:af:ca:9e:a0 c0:67:af:86:53:3b e4:c7:22:8a:28:6c e4:c7:22:8a:28:72 e4:c7:22:8a:28:8d 88:43:e1:78:2c:4b 88:43:e1:78:2c:ce 88:43:e1:78:2c:bb 00:16:46:6b:29:16 00:00:00:00:00:00 00:1c:58:8e:8b:b4 00:1c:58:8e:8b:f2 00:1c:58:8e:8c:56 00:1c:58:8e:8d:22 00:1c:58:8e:8d:78 00:1c:58:c9:d6:fe 00:1c:58:c9:d8:78 00:1d:a1:fe:cb:f2 00:1e:be:27:4d:3a 00:1d:70:94:fe:04 00:22:90:1b:ad:9e 00:22:90:1b:af:0c 00:23:5e:02:fc:e8 00:23:5e:04:ed:a2 00:21:a0:d2:ba:1e 00:07:7d:fb:04:7e 70:81:05:92:78:72 70:81:05:92:78:74 70:81:05:92:78:78 70:81:05:92:7a:1e 64:9e:f3:2a:6b:02 64:9e:f3:2a:6c:00 64:9e:f3:2a:6c:f6 64:9e:f3:2a:6d:18 28:94:0f:a8:a3:80 a4:93:4c:16:5d:86 88:43:e1:37:7a:85 88:43:e1:37:7b:ca 88:43:e1:37:7b:e0 88:43:e1:78:2f:84 88:43:e1:78:2f:af 88:43:e1:37:7f:2f 88:43:e1:78:2f:6a 88:43:e1:78:2f:bb 88:43:e1:78:2f:bf 88:43:e1:78:2f:dd 88:43:e1:78:2f:e7 88:43:e1:37:7f:3c 88:43:e1:78:2f:0c 88:43:e1:37:7e:ad 88:43:e1:78:2f:10 b0:fa:eb:b8:ce:af b0:fa:eb:b8:d5:d0 ac:f2:c5:f3:fb:50 e0:2f:6d:91:d9:c8 e0:2f:6d:17:dc:e8 f0:f7:55:df:b3:68 bc:16:65:6a:d4:0c bc:16:65:a8:7f:c2 50:57:a8:9e:a8:f4 50:57:a8:a1:cc:54 c0:67:af:ca:92:ed c0:67:af:86:4d:9c c0:67:af:86:52:fe c0:67:af:86:53:09 c0:67:af:86:53:43 e4:c7:22:8a:1d:cf e4:c7:22:8a:28:68 e4:c7:22:8a:28:72 e4:c7:22:8a:28:78 e4:c7:22:8a:28:7e e4:c7:22:8a:28:90 e4:c7:22:8a:28:f6 c0:67:af:86:53:00 78:da:6e:8d:f1:a5 78:da:6e:8d:f1:ce ac:f2:c5:93:f4:a2 ac:f2:c5:71:74:de ac:f2:c5:71:75:1b ac:f2:c5:93:f6:d3 ac:f2:c5:85:74:82 ac:f2:c5:94:15:75 ac:f2:c5:94:19:04 28:94:0f:c0:fe:31 e4:c7:22:8a:28:60 e4:c7:22:8a:28:70 e4:c7:22:8a:28:90 e4:c7:22:8a:28:f0 4c:00:82:1a:cc:0e 4c:00:82:1a:cd:d0 f8:72:ea:e4:b2:b6 f8:72:ea:e4:b2:d7 f8:72:ea:e4:b2:ed f8:72:ea:e4:b4:42 f8:72:ea:e4:b5:a6 f8:72:ea:e4:b5:b6 b0:fa:eb:3d:7c:a7 b0:fa:eb:3d:7c:f4 b0:fa:eb:3d:83:b9 bc:16:65:b6:07:ea bc:16:65:b6:08:c3 bc:16:65:b6:08:ea bc:16:65:b6:09:3f bc:16:65:b6:09:6b a4:93:4c:38:0c:48 a4:93:4c:46:81:88 a4:93:4c:46:81:66 a4:93:4c:38:0c:21 a4:93:4c:52:a7:06 a4:93:4c:52:a7:43 a4:93:4c:52:a7:9f a4:93:4c:38:0d:92 a4:93:4c:52:ac:01 a4:93:4c:52:ab:25 a4:93:4c:52:ac:77 a4:93:4c:38:0f:bd a4:93:4c:52:aa:2c a4:93:4c:38:0e:d1 a4:93:4c:52:aa:71 a4:93:4c:38:0f:94 a4:93:4c:52:aa:b6 a4:4c:11:eb:c8:d9 2c:54:2d:0d:ef:2e);

# Fetch each row and print it
while ( my ($id_old,$data,$email,$type,$subtype,$location,$mac,$hostname,$subnet,$host,$tempodet,$g_type,$g_fullname,$g_tel,$g_email,$g_date_out,$id,$stato) = $sth->fetchrow_array() ) {
    $count++;
    my $state = 2;
    #next if $stato == 0; #SEMBRA siano solo 32 secondo simone
    my $user_ldap = $self->schema->resultset('UserLDAP')->search({email=>$email})->single;
    
    # -- richieste con referente mancante -- 
    if( !defined $id ){
        $BUG_ERR{$id_old} = $id_old;
        next;
    }

    if(!defined($subnet) or $subnet eq ""){
	   $state = 0;    
    } 

    # -- richieste con Associazione Area-Referente mancante nel file -- 
    if(!defined $self->area_map->{$id_old}) {
       #$self->log->error("$countref - Area (id $id) non trovata. ID referente $id");
       $AREA_ERR{$id_old} = $id;
       $countref++;
       next;
    }

    # -- richieste con utente mancante nel nuovo db --
    if (!defined $user_ldap ){
      #$self->log->error("$countemail - User ".$email." non trovato!"); 
      $USER_ERR{$id_old} = $email;
      $countemail++;
      #next;
    }
    defined($user_ldap) or next;

    # -- richieste con mac address mancante --
    if (!defined $mac) {
        $MAC_ERR{$id_old} = $id." ".$subnet.".".$host;
        #$self->log->error("$countmac - Mac address mancante ".$subnet.".".$host); # richieste con utente mancante nel nuovo db --
      $countmac++;
      next;
    }

    
    #trasforma data
    my $date = IPAdmin::Utils::eng_str_to_time($data);
    my $date_out = IPAdmin::Utils::eng_str_to_time($g_date_out) if defined $g_date_out;
    #my $date_out = $date_in + '63113852'; #date_in + 2 anni

    
    # -- richieste con associazione area-referente mancante -- Controllo duplicato?
    if(!defined($self->schema->resultset('Area')->find($self->area_map->{$id_old}))){
        $AREA_ERR{$id_old} = $id;
        #$self->log->error("$countref - Area ".$self->area_map->{$id}." non trovata nel nuovo IPAdmin"); 
        $countref++;
        next;
    }

    #  -- gestione richieste Alias --
    if ($type eq 'ALIAS') {
    #    my $ipreq = $self->schema->resultset('IPRequest')->search({-and => 
    #                                                 [ subnet => $subnet,
    #                                                   host   => $host,]
    #                                                })->single;
    #    $hostname = $1 if $hostname =~ /(.*)\.uniroma1.it/i ;
    #    $self->schema->resultset('Alias')->create({
    #        cname       => $hostname,
    #        ip_request  => $ipreq->id,
    #        state       => $state,
    #        }) if defined $ipreq;
    #    $self->log->error($count." Alias di ".$subnet.".".$host);
    #    $self->log->error("Alias non aggiunto: IP non trovato") if(!defined $ipreq);
    #    $ALIAS_ERR{$id_old} = $id_old." ".$hostname;
    #    $count++;
        next;
    } #else { next; }

    #if ( defined $subnet and my $doppione = $self->schema->resultset('IPRequest')->search({-and => 
    #                                                 [ subnet => $subnet,
    #                                                   host   => $host,]
    #                                               })->single ) {
    #    $self->log->error("Esiste già una richiesta per questo IP ".$subnet." ".$host);
    #    $DUP_ERR{$id_old} = $subnet.".".$host;
    #    if($date > $doppione->date) {
    #      $doppione->delete;
    #      }  
    #  }


    my $guest = $self->schema->resultset('Guest')->search({email=>$g_email})->single;

    if($tempodet eq 1 and !defined $guest) {
     $guest = $self->schema->resultset('Guest')->create({
        email        => $g_email,
        fullname     => $g_fullname,
        telephone    => $g_tel,
        type         => $g_type,
        date_out     => $date_out,
        });
      defined($guest) or $self->log->error("Guest ".$email." non trovato!");
    }

    defined $location or $location = "sconosciuta";
    
    # -- richieste con tipo non definito --
    if (!defined $type) {
      #$count++;
      #$self->log->error($count."Alias di ".$subnet.".".$host) if $type eq 'ALIAS';
      $self->log->error($count."Tipo non definito per ".$subnet.".".$host) if !defined $type;
      next;
    }

    # -- gestione tipi di richieste --
    $type = 1 if $type eq 'SERVER';
    $type = 3 if $type eq 'CLIENT' and $subtype eq 1; # pc fisso
    $type = 4 if $type eq 'CLIENT' and $subtype eq 2; # pc portatile
    $type = 5 if $type eq 'CLIENT' and $subtype eq 3; # stampante
    $type = 9 if $type eq 'CLIENT' and $subtype eq 0; # altro
    $type = 2 if $type eq 'FIREWALL';
    $type = 10 if $hostname =~ /marcatempo/i;
    
    # -- Controllo che i nodi WAP siano di Sapienza Wifi o AP personali --
    if ( $type eq 'WAP') {
      #$countap++;
      foreach my $apmac (@apmac) {
        $type = 8 if $apmac eq lc($mac); 
      }
      $countwifi++ if $type eq 8;
      $type = 7 if $type eq 'WAP';
      $countap++ if $type eq 7; 
    }

    my $ipreq;
    if (defined $guest) {
      $ipreq = $self->schema->resultset('IPRequest')->create({
    #    area         => $self->area_map->{$id},
        area         => $self->area_map->{$id_old}, # per associazione id_richiesta-id_area
        user         => $user_ldap->id,  #Cercare id su base email
        location     => $location,
        date         => $date,
        state        => $state,
        type         => $type,
        macaddress   => $mac,
        subnet       => $subnet,
        host         => $host,
        hostname     => $hostname,
        guest        => $guest->id,
        });
    }
    else {
      $ipreq = $self->schema->resultset('IPRequest')->create({
    #    area         => $self->area_map->{$id},
        area         => $self->area_map->{$id_old}, # per associazione id_richiesta-id_area
        user         => $user_ldap->id,  #Cercare id su base email
        location     => $location,
        date         => $date,
        state        => $state,
        type         => $type,
        macaddress   => $mac,
        subnet       => $subnet,
        host         => $host,
        hostname     => $hostname,
        });
    }
    undef $guest;

    $self->schema->resultset('IPAssignement')->create({date_in => $date, state => 2, ip_request => $ipreq->id}) if $state eq 2;
   
    $self->log->info("Richiesta IP aggiunta".$ipreq->id) if defined $ipreq;
       
    $self->schema->resultset('UserRole')->update_or_create({user_id => $user_ldap->id,role_id => 2});
}



# Disconnect from the database
$dbh->disconnect();
  #  $self->import();

use Data::Dumper;
$self->log->info("AREA:".scalar(keys (%AREA_ERR)));
$self->log->info(Dumper(\%AREA_ERR));

$self->log->info("USER:".scalar(keys (%USER_ERR)));
$self->log->info(Dumper(\%USER_ERR));

$self->log->info("BUG:".scalar(keys (%BUG_ERR)));
#$self->log->info(Dumper(\%BUG_ERR));

$self->log->info("DUP:".scalar(keys (%DUP_ERR)));
#$self->log->info(Dumper(\%DUP_ERR));

$self->log->info("ALIAS:".scalar(keys (%ALIAS_ERR)));
$self->log->info(Dumper(\%ALIAS_ERR));

$self->log->info("MAC:".scalar(keys (%MAC_ERR)));
#$self->log->info(Dumper(\%MAC_ERR));

$self->log->info("Record totali: $count - SapienzaWifi: $countwifi di AP totali: $countap");
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
