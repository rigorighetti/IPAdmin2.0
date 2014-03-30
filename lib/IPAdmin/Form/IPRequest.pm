# Copyright 2013 by the IPAdmin Team

package IPAdmin::Form::IPRequest;

use strict;
use warnings;
use HTML::FormHandler::Moose;

extends 'HTML::FormHandler::Model::DBIC';
 with 'IPAdmin::FormRenderTable';

has_field 'username' => (
    type  => 'Text', disabled => 1
);

has_field 'department' => (
        type    => 'Select',
        label   => 'Struttura di riferimento',
        empty_select => '---Seleziona la struttura---',
        required     => 1
);

has_field 'building' => (
        type    => 'Select',
        label   => 'Edificio',
        empty_select => '---Seleziona l\'edificio---',
        required     => 1
);

has_field 'description' => ( type => 'TextArea' );
has_field 'address' => ( type => 'Text', required => 1 );

has_field 'submit'  => ( type => 'Submit', value => 'Submit' );
has_field 'discard' => ( type => 'Submit', value => 'Discard' );

1;
