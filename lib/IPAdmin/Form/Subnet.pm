# Copyright 2011 by the Manoc Team
#
# This library is free software. You can redistribute it and/or modify
# it under the same terms as Perl itself.
package IPAdmin::Form::Subnet;

use strict;
use warnings;
use HTML::FormHandler::Moose;

extends 'HTML::FormHandler::Model::DBIC';
with 'IPAdmin::FormRenderTable';

has_field 'id' => (
    type => 'Text',
    required => 1,
    label    => 'Subnet id',
    apply    => [
        'Str',
        {
            check => sub { $_[0] =~ /\d+/ },
            message => 'ID della subnet non valido'
        },
    ]

    );

has_field 'name' => (
    type     => 'Text',
    required => 1,
    label    => 'Subnet name',
    apply    => [
        'Str',
        {
            check => sub { $_[0] =~ /\w/ },
            message => 'Nome della subnet non valido'
        },
    ]
);

has_field 'vlan' => (
    type    => 'Select',
    label   => 'Seleziona Vlan',
    empty_select => '---Vlan---',
    required     => 1
);

has_field 'archivable' => (
    type  => 'Checkbox',
    label => 'IP archiviabili automaticamente'
);

 
has_field 'submit'  => ( type => 'Submit', value => 'Invia' );
has_field 'discard' => ( type => 'Submit', value => 'Annulla' );

sub options_vlan {
    my $self = shift;
    return unless $self->schema;

    my $vlans = $self->schema->resultset('Vlan')->search(
        {},
        {
            order_by => 'me.id',
        }
    );
    my @selections;
    while ( my $vlan = $vlans->next ) {
        push @selections, { value => $vlan->id, label => $vlan->id };
    }
     
    return  @selections;


}



1;
