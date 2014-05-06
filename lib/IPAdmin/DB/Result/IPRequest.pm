# Copyright 2013 by the Manoc Team
#
# This library is free software. You can redistribute it and/or modify
# it under the same terms as Perl itself.
package IPAdmin::DB::Result::IPRequest;

use base qw(DBIx::Class);

__PACKAGE__->load_components(qw(PK::Auto Core));

__PACKAGE__->table('iprequest');
__PACKAGE__->add_columns(
    id => {
        data_type         => 'int',
        is_nullable       => 0,
        is_auto_increment => 1,
    },
    area => {
        data_type      => 'int',
        is_nullable    => 0,
        is_foreign_key => 1,
    },
    user => {
        data_type      => 'int',
        is_nullable    => 0,
        is_foreign_key => 1,
    },
    location => {
        data_type   => 'varchar',
        size        => 255,
        is_nullable => 0
    },
    macaddress => {
        data_type   => 'varchar',
        size        => 255,
        is_nullable => 0
    },
    hostname => {
        data_type   => 'varchar',
        size        => 255,
        is_nullable => 0,
    },
    date => {
        data_type      => 'int',
        size           => 11,
        is_nullable    => 0
    },
    state =>  {
        data_type      => 'int',
        size           => 1,
	    is_nullable    => 0,
    },
    type =>   {
        data_type      => 'int',
        is_nullable    => 0,
        is_foreign_key => 1,
    },
    assignement => {
        data_type      => 'int',
        is_nullable    => 1,
        is_foreign_key => 0,
    },
);

__PACKAGE__->set_primary_key(qw(id));

__PACKAGE__->belongs_to( area   => 'IPAdmin::DB::Result::Area',
    { 'foreign.id' => 'self.area' } 
);
__PACKAGE__->belongs_to( assignement   => 'IPAdmin::DB::Result::IPAssignement' #,
#    { 'foreign.id' => 'self.assignement' } 
);
__PACKAGE__->belongs_to( user       => 'IPAdmin::DB::Result::UserLDAP' );
__PACKAGE__->belongs_to( type       => 'IPAdmin::DB::Result::TypeRequest' );


=head1 NAME

IPAdmin:DB::IPRequest - A model object representing a person with access to the system.

=head1 DESCRIPTION

This is an object that represents a row in the 'users' table of your
application database.  It uses DBIx::Class (aka, DBIC) to do ORM.

=cut

1;
