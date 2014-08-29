 # Copyright 2013 by the Manoc Team
#
# This library is free software. You can redistribute it and/or modify
# it under the same terms as Perl itself.
package IPAdmin::DB::Result::UserLDAP;

use base qw(DBIx::Class);

__PACKAGE__->load_components(qw(PK::Auto Core));

__PACKAGE__->table('users_ldap');
__PACKAGE__->add_columns(
    id => {
        data_type         => 'int',
        is_nullable       => 0,
        is_auto_increment => 1,
    },
    username => {
        data_type   => 'varchar',
        size        => 255,
        is_nullable => 0
    },
    email => {
        data_type   => 'varchar',
        size        => 255,
        is_nullable => 0
	},
    fullname => {
        data_type   => 'varchar',
        size        => 255,
        is_nullable => 0 
    },
    fax => {
         data_type => 'varchar',
         size      => '255',
         is_nullable => 1
    },
    telephone => {
        data_type => 'varchar',
        size      => '255',
        is_nullable => 0
    },
    active => {
        data_type     => 'int',
        size          => 1,
        is_nullable   => 0,
        default_value => 1,
    },

            );
__PACKAGE__->set_primary_key(qw(id));
__PACKAGE__->add_unique_constraint( ['username'] );

__PACKAGE__->has_many( map_user_role => 'IPAdmin::DB::Result::UserRole', 'user_id' );
__PACKAGE__->many_to_many( roles => 'map_user_role', 'role' );

__PACKAGE__->has_many(map_user_ipreq => 'IPAdmin::DB::Result::IPRequest','user' , { cascade_delete => 0 });

__PACKAGE__->has_many(managed_area => 'IPAdmin::DB::Result::Area', 'manager', { cascade_delete => 0 } );

__PACKAGE__->has_many(is_manager => 'IPAdmin::DB::Result::Area', 'manager', { cascade_delete => 0, join_type => 'left' } );

=head1 NAME

IPAdmin:DB::UserLDAP - A model object representing a person with access to the system.

=head1 DESCRIPTION

This is an object that represents a row in the 'users' table of your
application database.  It uses DBIx::Class (aka, DBIC) to do ORM.

=cut

1;
