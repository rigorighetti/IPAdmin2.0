# Copyright 2011 by the Manoc Team
#
# This library is free software. You can redistribute it and/or modify
# it under the same terms as Perl itself.
package IPAdmin::Form::User;

use strict;
use warnings;
use HTML::FormHandler::Moose;

extends 'HTML::FormHandler::Model::DBIC';
with 'IPAdmin::FormRenderTable';

has_field 'username' => (
    type     => 'Text',
    label    => 'Username',
    required => 1,
    apply    => [
        'Str',
        {
            check => sub { $_[0] =~ /^\w[\w-]*$/ },
            message => 'Invalid Username'
        },
    ]
);

has_field 'password' => (
    type      => 'Password',
    required  => 1,
    minlength => 6,
);

has_field 'conf_password' => (
    type     => 'PasswordConf',
    required => 1,
    label    => 'Confirm Password',
);

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
 
has_field 'submit'  => ( type => 'Submit', value => 'Invia' );
has_field 'discard' => ( type => 'Submit', value => 'Annulla' );

1;
