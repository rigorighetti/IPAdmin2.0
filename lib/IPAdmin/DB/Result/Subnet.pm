# Copyright 2013 by the Manoc Team
#
# This library is free software. You can redistribute it and/or modify
# it under the same terms as Perl itself.
package  IPAdmin::DB::Result::Subnet;
use base 'DBIx::Class';

__PACKAGE__->load_components(qw/Core/);

__PACKAGE__->table('subnet');
__PACKAGE__->add_columns(
    id => {
        data_type         => 'int',
        is_nullable       => 0,
    },
    name => {
        data_type   => 'varchar',
        size        => '128',
        is_nullable => 0,
    },
    vlan => {
        data_type      => 'int',
        is_nullable    => 0,
        is_foreign_key => 1,
    },
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to( vlan => 'IPAdmin::DB::Result::Vlan' );
__PACKAGE__->has_many( map_iprequest   => 'IPAdmin::DB::Result::IPRequest','subnet', { cascade_delete => 0 });

1;

