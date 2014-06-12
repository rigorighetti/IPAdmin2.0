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

sub instruction : Path('view') Args(1) {
    my ( $self, $c, $page ) = @_;
    $c->stash( template => 'help/index.tt' );

    $c->stash(template => "help/$page.tt") if(defined $page);
}

=head1 AUTHOR

gabriele

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
