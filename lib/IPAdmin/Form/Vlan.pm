# Copyright 2011 by the Manoc Team
#
# This library is free software. You can redistribute it and/or modify
# it under the same terms as Perl itself.
package IPAdmin::Form::Vlan;

use strict;
use warnings;
use HTML::FormHandler::Moose;

extends 'HTML::FormHandler::Model::DBIC';
with 'IPAdmin::FormRenderTable';

has_field 'id' => (
    type => 'Text',
    required => 1,
    label    => 'Vlan id',
    apply    => [
        'Str',
        {
            check => sub { $_[0] =~ /\d+/ },
            message => 'Invalid ID'
        },
    ]

    );

has_field 'description' => (
    type     => 'TextArea',
    required => 0,
    label    => 'Descrizione Vlan',
    apply    => [
        'Str',
        {
            check => sub {  length($_[0]) < 255 },
            message => 'Descrizione troppo lunga'
        },
    ]
);
 
has_field 'submit'  => ( type => 'Submit', value => 'Invia' );
has_field 'discard' => ( type => 'Submit', value => 'Annulla' );

1;
