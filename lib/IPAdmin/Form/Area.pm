# Copyright 2013 by the IPAdmin Team

package IPAdmin::Form::Area;

use strict;
use warnings;
use HTML::FormHandler::Moose;

extends 'HTML::FormHandler::Model::DBIC';
 with 'IPAdmin::FormRenderTable';

has_field 'building' => (
    type         => 'Select',
    label        => 'Nome dell\'Edificio',
    empty_select => '---Edificio---',
    required     => 1
);

has_field 'department' => (
	type	=> 'Select',
	label	=> 'Nome della Struttura',
	empty_select => '---Struttura---',
        required     => 1
);
 
has_field 'submit'  => ( type => 'Submit', value => 'Invia' );
has_field 'discard' => ( type => 'Submit', value => 'Annulla' );



sub options_building {
    my $self = shift;
    return unless $self->schema;

    my $builds = $self->schema->resultset('Building')->search(
        {},
        {
            order_by => 'me.id',
        }
    );
    my @selections;
    while ( my $build = $builds->next ) {
        push @selections, { value => $build->id, label => $build->name};
    }
    return  @selections;
}



1;
