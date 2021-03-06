# Copyright 2013 by the IPAdmin Team

package IPAdmin::Form::Department;

use strict;
use warnings;
use HTML::FormHandler::Moose;

extends 'HTML::FormHandler::Model::DBIC';
 with 'IPAdmin::FormRenderTable';

has_field 'name' => (
	type	 => 'Text',
	required => 1,
	label    => 'Nome Dipartimento',
	apply	 => [
		'Str',
		{
			check => sub { $_[0] =~ /\w/ },
			messagge => 'Nome non valido'
		},
	]
);

has_field 'description' => (
    type     => 'TextArea',
    required => 0,
    label    => 'Descrizione',
    apply    => [
        'Str',
        {
            check => sub {  length($_[0]) < 255 },
            message => 'Descrizione troppo lunga'
        },
    ]
);

has_field 'domain' => ( type => 'Text',label => 'Dominio DNS', required => 0 );
 
has_field 'submit'  => ( type => 'Submit', value => 'Invia' );
has_field 'discard' => ( type => 'Submit', value => 'Annulla' );

1;
