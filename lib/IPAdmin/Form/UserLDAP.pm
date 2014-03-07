# Copyright 2013 by the IPAdmin Team

package IPAdmin::Form::UserLDAP;

use strict;
use warnings;
use HTML::FormHandler::Moose;

extends 'HTML::FormHandler::Model::DBIC';
 with 'IPAdmin::FormRenderTable';

has_field 'username' => (
    type  => 'Text', disabled => 1
);

has_field 'email' => ( type => 'Email', disabled => 1 );

has_field 'fullname' => (
    type  => 'Text',
    apply => [
        'Str',
        {
            check => sub { $_[0] =~ /\w/ },
            message => 'Invalid Name'
        },
    ]
);

has_field 'telephone' => (
    type  => 'Text',
    apply => [
        'Str',
        {
            check => sub { $_[0] =~ /\d+/ },
            message => 'Invalid Telephone Number'
        },
    ]
);

has_field 'fax' => (
    type  => 'Text',
    apply => [
        'Str',
        {
            check => sub { $_[0] =~ /\d+/ },
            message => 'Invalid Fax Number'
        },
    ]
);

has_field 'continue'  => ( type => 'Submit', value => 'Continue...' );

1;
