# Copyright 2013 by the Manoc Team
#
# This library is free software. You can redistribute it and/or modify
# it under the same terms as Perl itself.
 package IPAdmin::DB::Result::Alias;

use base qw(DBIx::Class);

__PACKAGE__->load_components(qw(PK::Auto Core));

__PACKAGE__->table('alias');
__PACKAGE__->add_columns(
    id => {
        data_type         => 'int',
        is_nullable       => 0,
        is_auto_increment => 1,
    },
    cname => {
        data_type         => 'varchar',
        size              => 255,
        is_nullable       => 0,
    },
    ip_request => {
        data_type      => 'int',
        is_nullable    => 0,
        is_foreign_key => 1,
    },
    state =>  {
        data_type      => 'int',
        size           => 1,
        is_nullable    => 0,
    },

);

__PACKAGE__->set_primary_key(qw(id));
__PACKAGE__->add_unique_constraint( [qw/cname/] );

__PACKAGE__->belongs_to( ip_request   => 'IPAdmin::DB::Result::IPRequest',
    { 'foreign.id' => 'self.ip_request' } 
);

=head1 NAME

IPAdmin:DB::Alias - A model object representing a person with access to the system.

=head1 DESCRIPTION

This is an object that represents a row in the 'users' table of your
application database.  It uses DBIx::Class (aka, DBIC) to do ORM.

=cut

1;
