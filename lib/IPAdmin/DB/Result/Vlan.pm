# Copyright 2013 by the Manoc Team
#
# This library is free software. You can redistribute it and/or modify
# it under the same terms as Perl itself.
package  IPAdmin::DB::Result::Vlan;
use base 'DBIx::Class';

__PACKAGE__->load_components(qw/Core/);

__PACKAGE__->table('vlan');
__PACKAGE__->add_columns(
    id => {
        data_type         => 'int',
        is_nullable       => 0,
    },
    description => {
        data_type => 'varchar',
        size        => '128',
        is_nullable => 1,
    },
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->has_many( map_subnet   => 'IPAdmin::DB::Result::Subnet','vlan', {cascade_delete => 0});

__PACKAGE__->has_many(
    building => 'IPAdmin::DB::Result::Building',
    'vlan',
  );


1;

