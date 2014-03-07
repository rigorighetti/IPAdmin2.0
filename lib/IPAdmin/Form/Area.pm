# Copyright 2013 by the IPAdmin Team

package IPAdmin::Form::Area;

use strict;
use warnings;
use HTML::FormHandler::Moose;

extends 'HTML::FormHandler::Model::DBIC';
# with 'IPAdmin::FormRenderTable';

has_field 'building' => (
    type         => 'Select',
    label        => 'Building name',
    empty_select => '---Choose a Building---'
);

has_field 'department' => (
	type	=> 'Select',
	label	=> 'Department name',
	empty_select => '---Choose a Building---'
);

has_field 'manager' => (
	type 	=> 'Integer',
	label	=> 'Manager name'
);

#has_field 'manager' => (
#        type    => 'Select',
#       label   => 'Manager name',
#        empty_select => '---Choose a Manager---'
#);

has_field 'submit'  => ( type => 'Submit', value => 'Submit' );
has_field 'discard' => ( type => 'Submit', value => 'Discard' );


#sub options_building {
#    my $self = shift;
#   return unless $self->schema;
#
#    my $buildings = $self->schema->resultset('Building')->search(
#        {},
#        {
#            join     => 'map_area_dep',
#            prefetch => 'map_area_dep',
#            order_by => 'me.name'
#        }
#    );

# my @selections;
#    while ( my $building = $buildings->next ) {
#        my $label = "Building " . $building->name . " (" . $building->name . ")";
#        push @selections, { value => $building->id, label => $label };
#    }
#    return { label =>"---Choose a Building---", value => ""}, @selections;
#}


#    return map +{
 #       value => $_->id,
  #      label => "Building " . $_->name . " (" . $_->building->name . ")"
   #     },
    #    $buildings->all();
#}

1;
