# Copyright 2011 by the Manoc Team
#
# This library is free software. You can redistribute it and/or modify
# it under the same terms as Perl itself.
package IPAdmin::Manoc::Result::IfNotes;
use base 'DBIx::Class';
use strict;
use warnings;

__PACKAGE__->load_components(qw/ Core/);
__PACKAGE__->table('if_notes');

__PACKAGE__->add_columns(
    'device' => {
        data_type      => 'varchar',
        is_foreign_key => 1,
        is_nullable    => 0,
        size           => 15
    },
    'interface' => {
        data_type   => 'varchar',
        is_nullable => 0,
        size        => 64
    },
    'notes' => {
        data_type   => 'text',
        is_nullable => 0,

    },
);

__PACKAGE__->belongs_to( device => 'IPAdmin::Manoc::Result::Device' );
__PACKAGE__->set_primary_key( 'device', 'interface' );
1;

# __PACKAGE__->set_sql('unused',
# 		     q{
# 			 SELECT device AS d, interface AS i
# 			 FROM __TABLE__
# 			 WHERE device=?
# 			   AND (SELECT COUNT(interface)
# 			        FROM mat
# 			        WHERE device=d
# 			         AND interface=i
# 				 AND lastseen > ?) = 0
# 		     });
