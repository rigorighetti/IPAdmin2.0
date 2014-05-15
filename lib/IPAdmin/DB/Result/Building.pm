# Copyright 2013 by the Manoc Team
#
# This library is free software. You can redistribute it and/or modify
# it under the same terms as Perl itself.
package  IPAdmin::DB::Result::Building;
use base 'DBIx::Class';

__PACKAGE__->load_components(qw/PK::Auto Core/);

__PACKAGE__->table('building');
__PACKAGE__->add_columns(
    id => {
        data_type         => 'int',
        is_nullable       => 0,
        is_auto_increment => 1,
    },
    name => {
        data_type => 'varchar',
        size      => '32',
    },
    description => {
        data_type => 'varchar',
        size      => '255',
        is_nullable       => 1,
    },
    address => {
        data_type => 'varchar',
        size      => '255',
    },
    vlan => {
        data_type      => 'int',
        is_nullable    => 1,
        is_foreign_key => 1,
    },
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint( [qw/name/] );


__PACKAGE__->has_many(map_area_dep => 'IPAdmin::DB::Result::Area','building' );
__PACKAGE__->many_to_many( departments => 'map_area_dep', 'department' );

__PACKAGE__->belongs_to( vlan => 'IPAdmin::DB::Result::Vlan' );



1;

