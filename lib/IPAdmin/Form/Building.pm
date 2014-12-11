# Copyright 2013 by the IPAdmin Team

package IPAdmin::Form::Building;

use strict;
use warnings;
use HTML::FormHandler::Moose;

extends 'HTML::FormHandler::Model::DBIC';
 with 'IPAdmin::FormRenderTable';

has_field 'name' => (
	type	 => 'Text',
	required => 1,
    label    => 'Nome',
	apply	 => [
		'Str',
		{
			check => sub { $_[0] =~ /\w/ },
			messagge => 'Immettere un nome valido (senza caratteri speciali)'
		},
	]
);

has_field 'description' => (
    type     => 'TextArea',
    required => 1,
    label    => 'Descrizione Edificio',
    apply    => [
        'Str',
        {
            check => sub {  length($_[0]) < 255 },
            message => 'Descrizione troppo lunga'
        },
    ]
);

has_field 'address' => ( type => 'Text', 
                         required => 1,
                         label    => 'Indirizzo',
 );


has_field 'vlan' => (
	type	=> 'Select',
	label	=> 'Vlan',
	empty_select => '---Vlan---',
    required     => 0
);

has_field 'submit'  => ( type => 'Submit', value => 'Submit' );
has_field 'discard' => ( type => 'Submit', value => 'Discard' );

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
