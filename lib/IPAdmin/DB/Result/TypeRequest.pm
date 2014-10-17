# Copyright 2013 by the Manoc Team
#
# This library is free software. You can redistribute it and/or modify
# it under the same terms as Perl itself.
package IPAdmin::DB::Result::TypeRequest;

use base qw(DBIx::Class);

__PACKAGE__->load_components(qw(PK::Auto Core));

__PACKAGE__->table('typerequest');
__PACKAGE__->add_columns(
    id => {
        data_type         => 'int',
        is_nullable       => 0,
        is_auto_increment => 1,
    },
    type => {
        data_type   => 'varchar',
        size        => 255,
        is_nullable => 0
    },
    description => {
        data_type   => 'text',
        is_nullable => 1
    },
    archivable => {
        data_type      => 'int',
        is_nullable    => 0,
        default        => 1,
    },
    service_manager => {
        data_type      => 'int',
        is_nullable    => 1,
        is_foreign_key => 1,
    },
);

__PACKAGE__->set_primary_key(qw(id));

__PACKAGE__->has_many( request => 'IPAdmin::DB::Result::IPRequest', { cascade_delete => 0 } );

__PACKAGE__->belongs_to( service_manager => 'IPAdmin::DB::Result::UserLDAP', 'service_manager', { cascade_delete => 0 } );


=head1 NAME

IPAdmin:DB::TypeRequest - A model object representing a person with access to the system.

=head1 DESCRIPTION

This is an object that represents a row in the 'users' table of your
application database.  It uses DBIx::Class (aka, DBIC) to do ORM.

=cut

1;
