# Copyright 2013 by the Manoc Team
#
# This library is free software. You can redistribute it and/or modify
# it under the same terms as Perl itself.
package IPAdmin::DB::Result::User;

use base qw(DBIx::Class);

__PACKAGE__->load_components(qw(PK::Auto EncodedColumn Core));

__PACKAGE__->table('users');
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
    password => {
        data_type           => 'CHAR',
        size                => 22,
        encode_column       => 1,
        encode_class        => 'Digest',
        encode_args         => { algorithm => 'MD5', format => 'base64' },
        encode_check_method => 'check_password',
    },
    fullname => {
        data_type   => 'varchar',
        size        => 255,
        is_nullable => 1
    },
    email => {
        data_type   => 'varchar',
        size        => 255,
        is_nullable => 1
    },
    address => {
        data_type => 'varchar',
        size      => '255',
        is_nullable => 1
    },
    fax => {
         data_type => 'varchar',
         size      => '255',
         is_nullable => 1
    },
    telephone => {
        data_type => 'varchar',
        size      => '255',
        is_nullable => 1
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

__PACKAGE__->might_have(  managed_area => 'IPAdmin::DB::Result::Area',
                          'manager', { cascade_delete => 0 }
);
=head1 NAME

IPAdmin:DB::User - A model object representing a person with access to the system.

=head1 DESCRIPTION

This is an object that represents a row in the 'users' table of your
application database.  It uses DBIx::Class (aka, DBIC) to do ORM.

=cut

1;
