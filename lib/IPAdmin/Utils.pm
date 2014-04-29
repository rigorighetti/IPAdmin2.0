# Copyright 2011 by the Manoc Team
#
# This library is free software. You can redistribute it and/or modify
# it under the same terms as Perl itself.

package IPAdmin::Utils;

use strict;
use warnings;

use Carp qw( croak );
use Exporter 'import';
our @EXPORT_OK = qw(
    find_user
);

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
