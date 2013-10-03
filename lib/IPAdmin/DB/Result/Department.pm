# Copyright 2013 by the Manoc Team
#
# This library is free software. You can redistribute it and/or modify
# it under the same terms as Perl itself.
package  IPAdmin::DB::Result::Department;
use base 'DBIx::Class';

__PACKAGE__->load_components(qw/PK::Auto Core/);

__PACKAGE__->table('department');
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

__PACKAGE__->belongs_to( building => 'IPAdmin::DB::Result::Building' );

1;

