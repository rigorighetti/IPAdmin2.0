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
    },
    address => {
        data_type => 'varchar',
        size      => '255',
    },
    fax => {
        data_type => 'varchar',
        size      => '255',
    },
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint( [qw/name/] );

__PACKAGE__->has_many(
    department => 'IPAdmin::DB::Result::Department',
    'building', { cascade_delete => 0 }
);

1;

