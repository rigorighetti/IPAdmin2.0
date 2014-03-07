# Copyright 2013 by the IPAdmin Team

package IPAdmin::Form::Building;

use strict;
use warnings;
use HTML::FormHandler::Moose;

extends 'HTML::FormHandler::Model::DBIC';
# with 'IPAdmin::FormRenderTable';

has_field 'name' => (
	type	 => 'Text',
	required => 1,
	apply	 => [
		'Str',
		{
			check => sub { $_[0] =~ /\w/ },
			messagge => 'Invalid Name'
		},
	]
);

has_field 'description' => ( type => 'TextArea' );
has_field 'address' => ( type => 'TextArea', required => 1 );

has_field 'submit'  => ( type => 'Submit', value => 'Submit' );
has_field 'discard' => ( type => 'Submit', value => 'Discard' );

1;