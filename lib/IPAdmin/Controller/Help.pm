# Copyright 2011 by the IPAdmin Team
#
# This library is free software. You can redistribute it and/or modify
# it under the same terms as Perl itself.
package IPAdmin::Controller::Help;
use strict;
use warnings;

use Data::Dumper;
use Moose;
use namespace::autoclean;

#use IPAdmin::Utils qw(str2seconds ip2int);

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

IPAdmin::Controller::Help - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index

=cut
sub index : Path : Args(0) {
    my ( $self, $c ) = @_;
    $c->stash( default_backref => $c->uri_for_action('/help/instruction') );
    $c->detach('/follow_backref');
}

sub instruction : Path('view') Args(0) {
    my ( $self, $c ) = @_;
    $c->stash( template => 'help/index.tt' );
    my $page = $c->req->param("page");
    $c->stash(template => "help/$page.tt") if(defined $page);
    my ($realm, $user) = IPAdmin::Utils::find_user($self,$c,$c->session->{user_id}); 
    !defined($user) and $c->detach('/access_denied');

    if($realm eq "normal"){
        $c->stash(visible => 1);
	return;
    } else {
    my @managed_area = $user->managed_area;
    scalar(@managed_area) and $c->stash(ref_visible => 1);
    my @managed_services = $user->managed_services;
    scalar(@managed_services) and $c->stash(ref_visible => 1);
    }
}

=head1 AUTHOR

gabriele

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
