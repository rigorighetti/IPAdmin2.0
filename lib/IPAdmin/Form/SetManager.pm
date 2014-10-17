# Copyright 2013 by the IPAdmin Team

package IPAdmin::Form::SetManager;

use strict;
use warnings;
use HTML::FormHandler::Moose;

extends 'HTML::FormHandler::Model::DBIC';
 with 'IPAdmin::FormRenderTable';


has_field 'area' => (
        type    => 'Select',
        label   => 'Seleziona Area',
        required     => 1
);

has_field 'manager' => (
        type    => 'Hidden',        
        label   => '',
        required     => 0
);



sub options_area {
    my $self = shift;
    return unless $self->schema;

    my $areas = $self->schema->resultset('Area')->search(
        {},
        {
            order_by => 'me.department',
            prefetch => ['building','department'],
        }
    );
    my @selections;
    while ( my $area = $areas->next ) {
        my $label =  $area->department->name . " (" . $area->building->name . ")";
        push @selections, { value => $area->id, label => $label };
    }
     
    return { label =>"---Scegli l\'area---", value => ""}, @selections;


}


 
has_field 'submit'  => ( type => 'Submit', value => 'Invia' );
has_field 'discard' => ( type => 'Submit', value => 'Annulla' );

sub update_model {
    my $self    = shift;
    my $row     = $self->values;
    my $area_id = $row->{'area'};
 
    my $manager_id = $self->item->manager->id;
    my $area_row = $self->schema->resultset('Area')->find($area_id);
    $area_row->set_column(manager => $manager_id);
    $area_row->update;

}




1;
