# Copyright 2013 by the IPAdmin Team

package IPAdmin::Form::UserLDAP;

use strict;
use warnings;
use HTML::FormHandler::Moose;

extends 'HTML::FormHandler::Model::DBIC';
 with 'IPAdmin::FormRenderTable';

has_field 'username' => (
    type  => 'Text',label =>'Username', disabled => 1
);

has_field 'email' => ( type => 'Email',label =>'Email', disabled => 1 );

has_field 'fullname' => (
    type  => 'Text',
    label => 'Nome Completo',
    apply => [
        'Str',
        {
            check => sub { $_[0] =~ /\w/ },
            message => 'Invalid Name'
        },
    ],
    required => 1,
);

has_field 'telephone' => (
    type  => 'Text',
    label => 'Telefono',
    apply => [
        'Str',
        {
            check => sub { $_[0] =~ /\d+/ },
            message => 'Invalid Telephone Number'
        },
    ],
    required => 1,
);

has_field 'fax' => (
    type  => 'Text',
    label => 'Fax',
    apply => [
        'Str',
        {
            check => sub { $_[0] =~ /\d+/ },
            message => 'Invalid Fax Number'
        },
    ],
    required => 0,
);

has_field 'continue'  => ( type => 'Submit', value => 'Continue...' );

1;
