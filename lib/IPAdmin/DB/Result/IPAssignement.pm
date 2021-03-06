# Copyright 2013 by the Manoc Team
#
# This library is free software. You can redistribute it and/or modify
# it under the same terms as Perl itself.
 package IPAdmin::DB::Result::IPAssignement;

use base qw(DBIx::Class);

__PACKAGE__->load_components(qw(PK::Auto Core));

__PACKAGE__->table('ipassignement');
__PACKAGE__->add_columns(
    id => {
        data_type         => 'int',
        is_nullable       => 0,
        is_auto_increment => 1,
    },
    date_in => {
        data_type      => 'int',
        size           => 11,
        is_nullable    => 0
    },
    date_out => {
        data_type      => 'int',
        size           => 11,
        is_nullable    => 1
    },
    state =>  {
        data_type      => 'int',
        size           => 1,
	    is_nullable    => 0,
    },
    ip_request => {
        data_type      => 'int',
        is_nullable    => 0,
        is_foreign_key => 1,
    },

);

__PACKAGE__->set_primary_key(qw(id));

__PACKAGE__->belongs_to( ip_request   => 'IPAdmin::DB::Result::IPRequest',
    { 'foreign.id' => 'self.ip_request' } 
);

=head1 NAME

IPAdmin:DB::IPAssignement - A model object representing a person with access to the system.

=head1 DESCRIPTION

This is an object that represents a row in the 'users' table of your
application database.  It uses DBIx::Class (aka, DBIC) to do ORM.

=cut

1;
