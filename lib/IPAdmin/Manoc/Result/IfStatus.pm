# Copyright 2011 by the Manoc Team
#
# This library is free software. You can redistribute it and/or modify
# it under the same terms as Perl itself.
package IPAdmin::Manoc::Result::IfStatus;
use base 'DBIx::Class';
use strict;
use warnings;

__PACKAGE__->load_components(qw/ Core/);
__PACKAGE__->table('if_status');

__PACKAGE__->add_columns(
    'device' => {
        data_type      => 'varchar',
        is_foreign_key => 1,
        is_nullable    => 0,
        size           => 15
    },
    'interface' => {
        data_type   => 'varchar',
        is_nullable => 0,
        size        => 64
    },
    'description' => {
        data_type     => 'varchar',
        size          => 128,
        is_nullable   => 1,
        default_value => 'NULL'
    },
    'up' => {
        data_type     => 'varchar',
        size          => 16,
        is_nullable   => 1,
        default_value => 'NULL'
    },
    'up_admin' => {
        data_type     => 'varchar',
        size          => 16,
        is_nullable   => 1,
        default_value => 'NULL'
    },
    'duplex' => {
        data_type     => 'varchar',
        size          => 16,
        is_nullable   => 1,
        default_value => 'NULL'
    },
    'duplex_admin' => {
        data_type     => 'varchar',
        size          => 16,
        is_nullable   => 1,
        default_value => 'NULL'
    },
    'speed' => {
        data_type     => 'varchar',
        size          => 16,
        is_nullable   => 1,
        default_value => 'NULL'
    },
    'stp_state' => {
        data_type     => 'varchar',
        size          => 16,
        is_nullable   => 1,
        default_value => 'NULL'
    },
    'cps_enable' => {
        data_type     => 'varchar',
        size          => 16,
        is_nullable   => 1,
        default_value => 'NULL'
    },
    'cps_status' => {
        data_type     => 'varchar',
        size          => 16,
        is_nullable   => 1,
        default_value => 'NULL'
    },
    'cps_count' => {
        data_type     => 'varchar',
        size          => 16,
        is_nullable   => 1,
        default_value => 'NULL'
    },
    'vlan' => {
        data_type     => 'int',
        is_nullable   => 1,
        default_value => 'NULL'
    },
);



__PACKAGE__->add_relationship(
    mat_entry =>
      'IPAdmin::Manoc::Result::Mat',
    { 
	'foreign.device' => 'self.device',
	'foreign.interface' => 'self.interface'
    },
    {
        accessor => 'single',
        join_type => 'LEFT',
	is_foreign_key_constraint => 0,
    },
   );

__PACKAGE__->belongs_to( device_info => 'IPAdmin::Manoc::Result::Device', 'device' );
__PACKAGE__->set_primary_key( 'device', 'interface' );

__PACKAGE__->resultset_class('IPAdmin::Manoc::ResultSet::IfStatus');

1;
