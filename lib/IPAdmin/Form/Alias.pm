# Copyright 2013 by the IPAdmin Team

package IPAdmin::Form::Alias;

use strict;
use warnings;
use HTML::FormHandler::Moose;

extends 'HTML::FormHandler::Model::DBIC';
 with 'IPAdmin::FormRenderTable';

has_field 'cname' => (
    type         => 'Text',
    label        => 'Alias',
    required     => 1
);

 
has 'def_ipreq' => (
    is       => 'rw',
    isa      => 'Int',
    required => 0,
);

has_field 'submit'  => ( type => 'Submit', value => 'Invia' );
has_field 'discard' => ( type => 'Submit', value => 'Annulla' );





1;
