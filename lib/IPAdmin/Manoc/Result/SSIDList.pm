# Copyright 2011 by the Manoc Team
#
# This library is free software. You can redistribute it and/or modify
# it under the same terms as Perl itself.
package IPAdmin::Manoc::Result::SSIDList;
use base 'DBIx::Class';
use strict;
use warnings;

__PACKAGE__->load_components(qw/ Core/);
__PACKAGE__->table('ssid_list');

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
    'ssid' => {
        data_type   => 'varchar',
        size        => 128,
        is_nullable => 0,
    },
    'broadcast' => {
        data_type     => 'int',
        is_nullable   => 1,
        default_value => 'NULL'
    },
    'channel' => {
        data_type     => 'int',
        is_nullable   => 1,
        default_value => 'NULL'
    },
);

__PACKAGE__->belongs_to( device_info => 'IPAdmin::Manoc::Result::Device', 'device' );
__PACKAGE__->set_primary_key( 'device', 'interface', 'ssid' );

1;
