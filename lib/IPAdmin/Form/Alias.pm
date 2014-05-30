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

has_field 'ip_request' => (
	type	=> 'Select',
	label	=> 'Indirizzo IP',
	empty_select => '---IP---',
        required     => 1
);
 
has 'def_ipreq' => (
    is       => 'rw',
    isa      => 'Int',
    required => 0,
);

has_field 'submit'  => ( type => 'Submit', value => 'Submit' );
has_field 'discard' => ( type => 'Submit', value => 'Discard' );



sub options_iprequest {
    my $self = shift;
    return unless $self->schema;

    my $ipreqs = $self->schema->resultset('IPRequest')->search(
        {},
        {
            order_by => 'me.id',
        }
    );
    my @selections;
    while ( my $ipreq = $ipreqs->next ) {
        push @selections, { value => $ipreq->id, label => $ipreq->hostname };
    }
    return  @selections;
}



1;
