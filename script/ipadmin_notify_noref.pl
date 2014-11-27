#!/usr/bin/perl
# -*- cperl -*-
use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";
use IPAdmin::Support;

package IPAdmin::EmailSender;
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

use DBI;

extends 'IPAdmin::App';


has 'transport' => (
    traits  => ['NoGetopt'],
    is      => 'ro',
    lazy    => 1,
    builder => '_build_transport'
);

sub _build_transport {
    my $self = shift;
    my $transport = Email::Sender::Transport::SMTP->new({
        host     => 'smtp.googlemail.com', 
        ssl      => 1, 
        port     => 465,
        timeout => 10,
        sasl_username => 'ipsapienza@uniroma1.it',  
        sasl_password => 'grecia69', 
    });
}





has 'prorete_query' => (
    traits  => ['NoGetopt'],
    is      => 'ro',
    lazy    => 1,
    builder => '_build_prorete_query'
);

sub _build_prorete_query {
    my $self = shift;
    my $dbh = DBI->connect('DBI:mysql:database=prorete;hostname=151.100.4.23', 'root', '')
    or die "Couldn't open database: $DBI::errstr; stopped";

    # Prepare the SQL query for execution
    my $sth = $dbh->prepare(<<End_SQL) or die "Couldn't prepare statement: $DBI::errstr; stopped";
SELECT id,data,email1,tipo,apparato,ubicazione,macaddress,nomenodo,ip1,ip2,tempodet,td_posizu,td_cognom,td_telefo,td_email,td_datate,id_referente,convalida FROM s_ipadd where email1 LIKE '%\@uniroma1.it' and id_referente is null and ip1 is not null and ip1 <> 101 and ip1 <> 100 and ip1 <> 102 and ip1 <> 54 and ip1 <> 73
End_SQL

    $sth->execute() or die "Couldn't execute statement: $DBI::errstr; stopped";

    return $sth;
}

has 'bug_err' => (
    traits  => ['NoGetopt'],
    is      => 'ro',
    lazy    => 1,
    builder => '_build_bug_err'
);

sub _build_bug_err{
  return {};
}

has 'recipients' => (
    traits  => ['NoGetopt'],
    is      => 'ro',
    lazy    => 1,
    builder => '_build_recipients'
);

sub _build_recipients{
  return {};
}

=head2 notify_ref


=cut

sub notify_ref {
    my $self = shift;
    my $conf         = $self->config->{'Archiver'} 
    || $self->log->logdie("Could not find config file!") ;
    my $schema       = $self->schema;
    my $count = 0;
    while ( my ($id_old,$data,$email,$type,$subtype,$location,$mac,$hostname,$subnet,$host,$tempodet,
            $g_type,$g_fullname,$g_tel,$g_email,$g_date_out,$id,$stato) = $self->prorete_query->fetchrow_array() ) {
      if( !defined $id ){
        $count++;
        $self->bug_err->{$id_old} = "151.100.".$subnet.".".$host." - ".$email;
        my $subject = "Comunicazione";
        # Testo dell'email (eliminare $email prima di mandare le email agli utenti)
        my $body = <<EOF;
Gentile Utente, 
ci risulta registrata negli archivi degli indirizzi IP, un richiesta a suo nome relativa all'indirizzo 151.100.$subnet.$host effettuata in data $data, nella quale non e' presente il referente di rete.
La preghiamo di segnalarci - rispondendo a questa email entro il 26/10/2014 - il nominativo del referente.
In assenza di tale comunicazione provvederemo al blocco dell'indirizzo IP e all'archiviazione della sua richiesta.

Cordiali saluti,
Centro Infosapienza - Settore Reti 
tel. 06 4991 3111 (int. 23111)
EOF
        $self->recipients->{$email} = "151.100.".$subnet.".".$host;
        my $to = $email;

        sleep(1);

        $self->log->info("$count - $email - 151.100.$subnet.$host - $id_old");

        $self->debug or $self->send_email($email, undef,$subject,$body);
        
        if($count == 1){ 
          $self->debug and $self->send_email('s.italiano@cineca.it', undef,$subject,$body);
        }
      }
    }
	$self->log->info("Trovati $count errori");
}

sub send_email {
    my ($self,$to,$cc,$subject,$body) = @_;
 
    my $email = Email::Simple->create(
    header =>  [ 
      To      => $to,
      From    => 'ipsapienza@uniroma1.it',
      Subject => $subject,
      Cc      => $cc,
    ],
    body   =>  $body,
  );

  my $result = sendmail($email, { transport => $self->transport });
}

sub run {
    my ($self) = @_;
    my $time = time;

   $self->notify_ref;
   if($self->debug){
    $self->log->debug(Dumper($self->recipients));
   }
}




no Moose;

package main;

my $app = IPAdmin::EmailSender->new_with_options();
$app->run();

# Local Variables:
# mode: cperl
# indent-tabs-mode: nil
# cperl-indent-level: 4
# cperl-indent-parens-as-block: t
# End:
