# Copyright 2011 by the Manoc Team
#
# This library is free software. You can redistribute it and/or modify
# it under the same terms as Perl itself.
package IPAdmin::DB::Result::FilterSubnet;

use base qw(DBIx::Class);

__PACKAGE__->load_components(qw/PK::Auto Core/);

__PACKAGE__->table('filter_subnet');
__PACKAGE__->add_columns(
    area_id => {
        data_type      => 'int',
        is_foreign_key => 1,
        is_nullable    => 0,
    },
    subnet_id => {
        data_type      => 'int',
        is_foreign_key => 1,
        is_nullable    => 0,
    }
);

__PACKAGE__->set_primary_key(qw/area_id subnet_id/);

__PACKAGE__->belongs_to( area => 'IPAdmin::DB::Result::Area', 'area_id' );
__PACKAGE__->belongs_to( subnet => 'IPAdmin::DB::Result::Subnet', 'subnet_id' );

=head1 NAME

IPAdmin::DB::Result::UserRole - A model object representing the JOIN between Users and
Roles.

=head1 DESCRIPTION

This is an object that represents a row in the 'user_roles' table of your
application database.  It uses DBIx::Class (aka, DBIC) to do ORM.

=cut

1;
