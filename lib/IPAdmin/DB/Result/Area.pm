# Copyright 2013 by the Manoc Team
#
# This library is free software. You can redistribute it and/or modify
# it under the same terms as Perl itself.
package  IPAdmin::DB::Result::Area;
use base 'DBIx::Class';

__PACKAGE__->load_components(qw/PK::Auto Core/);

__PACKAGE__->table('area');
__PACKAGE__->add_columns(
             id => {
                   data_type         => 'int',
                   is_nullable       => 0,
                   is_auto_increment => 1,
                   },
			 building   => {
				      data_type      => 'int',
				      is_nullable    => 0,
				      is_foreign_key => 1,
				     },
			 department =>{
				      data_type      => 'int',
				      is_nullable    => 0,
				      is_foreign_key => 1,
				      },
			 manager   =>{
			              data_type      => 'int',
			          	  is_nullable    => 1,
				      	  is_foreign_key => 1,
				     }
			);

__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint( [ 'building', 'department' ] );

__PACKAGE__->belongs_to( building   => 'IPAdmin::DB::Result::Building' );
__PACKAGE__->belongs_to( department => 'IPAdmin::DB::Result::Department' );
__PACKAGE__->belongs_to( manager    => 'IPAdmin::DB::Result::UserLDAP', 'manager', {join_type => 'left'}  );

__PACKAGE__->has_many(  list_iprequest => 'IPAdmin::DB::Result::IPRequest' );

__PACKAGE__->has_many( filter_subnet => 'IPAdmin::DB::Result::FilterSubnet', 'area_id' );
__PACKAGE__->many_to_many( filtered => 'filter_subnet', 'subnet' );

1;

