# Copyright 2013 by the IPAdmin Team

package IPAdmin::Form::TypeRequest;

use strict;
use warnings;
use HTML::FormHandler::Moose;

extends 'HTML::FormHandler::Model::DBIC';
 with 'IPAdmin::FormRenderTable';

has_field 'type' => (
	type	 => 'Text',
	required => 1,
    label => 'Nome',
	apply	 => [
		'Str',
		{
			check => sub { $_[0] =~ /\w/ },
			messagge => 'Invalid Name'
		},
	]
);

has_field 'description' => ( type => 'TextArea',
                             label => 'Descrizione',
 );

has_field 'archivable' => (
    type  => 'Checkbox',
    label => 'Tipi di richiesta archiviabili'
);

has_field 'service_manager' => (
	type		 => 'Select',
	label		 => 'Referente del servizio (opzionale)',
	empty_select => '---Nessun referente---',
    required     => 0,
);

sub options_service_manager {
    my $self = shift;
    return unless $self->schema;

    my $users = $self->schema->resultset('UserLDAP')->search(
        {},
        {
            order_by => 'me.fullname',
        }
    );
    my @selections;
    while ( my $user = $users->next ) {
        push @selections, { value => $user->id, label => $user->fullname." (".$user->email.")" };
    }
     
    return  @selections;

}

has_field 'submit'  => ( type => 'Submit', value => 'Invia' );
has_field 'discard' => ( type => 'Submit', value => 'Annulla' );

1;
