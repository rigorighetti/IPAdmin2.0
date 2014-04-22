# Copyright 2013 by the IPAdmin Team

package IPAdmin::Form::Area;

use strict;
use warnings;
use HTML::FormHandler::Moose;

extends 'HTML::FormHandler::Model::DBIC';
 with 'IPAdmin::FormRenderTable';

has_field 'building' => (
    type         => 'Select',
    label        => 'Building name',
    empty_select => '---Edificio---',
    required     => 1
);

has_field 'department' => (
	type	=> 'Select',
	label	=> 'Department name',
	empty_select => '---Struttura---',
        required     => 1
);

#has_field 'manager' => (
#        type    => 'Select',
#       label   => 'Manager name',
#        empty_select => '---Choose a Manager---'
#);

has_field 'submit'  => ( type => 'Submit', value => 'Submit' );
has_field 'discard' => ( type => 'Submit', value => 'Discard' );

1;
