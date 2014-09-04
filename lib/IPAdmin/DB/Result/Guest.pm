# Copyright 2013 by the Manoc Team
#
# This library is free software. You can redistribute it and/or modify
# it under the same terms as Perl itself.
package IPAdmin::DB::Result::Guest;

use base qw(DBIx::Class);

__PACKAGE__->load_components(qw(PK::Auto Core));

__PACKAGE__->table('guest');
__PACKAGE__->add_columns(
    id => {
        data_type         => 'int',
        is_nullable       => 0,
        is_auto_increment => 1,
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
    type => {
        data_type => 'varchar',
        size      => '255',
        is_nullable => 0
    },
    date_out => {
        data_type      => 'int',
        size           => 11,
        is_nullable    => 1
    },
);

__PACKAGE__->set_primary_key(qw(id));
__PACKAGE__->add_unique_constraint( [qw/fullname/] );

__PACKAGE__->has_one( iprequest => 'IPAdmin::DB::Result::IPRequest' );


=head1 NAME

IPAdmin:DB::TypeRequest - A model object representing a person with access to the system.

=head1 DESCRIPTION

This is an object that represents a row in the 'users' table of your
application database.  It uses DBIx::Class (aka, DBIC) to do ORM.

=cut

1;
