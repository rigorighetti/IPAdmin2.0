# Copyright 2011 by the Manoc Team
#
# This library is free software. You can redistribute it and/or modify
# it under the same terms as Perl itself.
package IPAdmin::Manoc::ResultSet::Arp;

use base 'DBIx::Class::ResultSet';
use strict;
use warnings;

sub search_conflicts {
    my $self = shift;

    $self->search(
        { archived => '0' },
        {
            select   => [ 'ipaddr', { count => { distinct => 'macaddr' } } ],
            as       => [ 'ipaddr', 'count' ],
            group_by => ['ipaddr'],
            having => { 'COUNT(DISTINCT(macaddr))' => { '>', 1 } },
        }
    );
}

sub search_multihomed {
    my $self = shift;

    $self->search(
        { archived => '0' },
        {
            select   => [ 'macaddr', { count => { distinct => 'ipaddr' } } ],
            as       => [ 'macaddr', 'count' ],
            group_by => ['macaddr'],
            having => { 'COUNT(DISTINCT(ipaddr))' => { '>', 1 } },
        }
    );
}

1;
