# Copyright 2011 by the Manoc Team
#
# This library is free software. You can redistribute it and/or modify
# it under the same terms as Perl itself.

package IPAdmin::Utils;

use strict;
use warnings;

use Carp qw( croak carp);
use Exporter 'import';
our @EXPORT_OK = qw(
    find_user str_to_time str_to_seconds
);
use DateTime::Format::Strptime;

use POSIX qw(strftime);

sub print_timestamp {
    my $timestamp = shift @_;
    defined($timestamp) || croak "Missing timestamp";
    my @timestamp = localtime($timestamp);
    return strftime( "%d/%m/%Y %H:%M:%S", @timestamp );
}

sub print_short_timestamp {
    my $timestamp = shift @_;
    defined($timestamp) || croak "Missing timestamp";
    my @timestamp = localtime($timestamp);
    return strftime( "%d/%m/%Y", @timestamp );
}
sub find_user {
  my ( $self, $c, $username ) = @_;
  my $user;
  $username = lc($username);
  if($c->user_in_realm( "normal" )){
  	$user = $c->model('IPAdminDB::User')->search( { username => $username } )->single;
  	return ("normal",$user);
  }
  else {
    $user = $c->model('IPAdminDB::UserLDAP')->search( { username => $username } )->single;
    return ("ldap",$user);
  }
}    

sub str_to_time {
  my $date = shift;
  my $strp = DateTime::Format::Strptime->new(
     pattern => '%d/%m/%Y',
     time_zone => 'local',
  );

  $strp->parse_datetime("$date")->epoch;
}

sub str_to_seconds {
    my ($str) = @_;

    return unless defined $str;

    return $str if $str =~ m/^[-+]?\d+$/;

    my %map = (
        's' => 1,
        'm' => 60,
        'h' => 3600,
        'd' => 86400,
        'w' => 604800,
        'M' => 2592000,
        'y' => 31536000
    );
    my ( $num, $m ) = $str =~ m/^([+-]?\d+)([smhdwMy])$/;

    ( defined($num) && defined($m) ) or
        carp "couldn't parse '$str'. Possible invalid syntax";

    return $num * $map{$m};
}