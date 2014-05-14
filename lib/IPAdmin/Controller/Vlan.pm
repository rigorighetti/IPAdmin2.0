# Copyright 2011 by the Manoc Team
#
# This library is free software. You can redistribute it and/or modify
# it under the same terms as Perl itself.
package IPAdmin::Controller::Vlan;
use Moose;
use namespace::autoclean;
use IPAdmin::Form::Vlan;
use Data::Dumper;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

IPAdmin::Controller::Vlan - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index

=cut

sub index : Path : Args(0) {
    my ( $self, $c ) = @_;

    $c->response->redirect('/vlan/list');
    $c->detach();
}

=head2 base

=cut

sub base : Chained('/') : PathPart('vlan') : CaptureArgs(0) {
    my ( $self, $c ) = @_;
    $c->stash( resultset => $c->model('IPAdminDB::Vlan') );
}

=head2 object

=cut

sub object : Chained('base') : PathPart('id') : CaptureArgs(1) {

    # $id = primary key
    my ( $self, $c, $id ) = @_;

    $c->stash( object => $c->stash->{resultset}->find($id) );

    if ( !$c->stash->{object} ) {
        $c->stash( error_msg => "Object $id not found!" );
        $c->detach('/error/index');
    }
}

=head2 view

=cut

sub view : Chained('object') : PathPart('view') : Args(0) {
    my ( $self, $c ) = @_;
    #Set template parameters
    $c->stash( template => 'vlan/view.tt');
}

=head2 list

=cut

sub list : Chained('base') : PathPart('list') : Args(0) {
    my ( $self, $c ) = @_;
    my $schema    = $c->stash->{resultset};
    my @vlan_list = $schema->search({});
   
    $c->stash(
        vlan_list => \@vlan_list,
        template  => 'vlan/list.tt'
    );
}

=head2 edit

=cut

sub edit : Chained('object') : PathPart('edit') : Args(0) {
    my ( $self, $c ) = @_;     
    $c->forward('save');
}
=head2 create

=cut

sub create : Chained('base') : PathPart('create') : Args(0) {
     my ( $self, $c ) = @_;
     $c->forward('save');
 }

=head2 save

# Handle create and edit resources

=cut

 sub save : Private {
     my ( $self, $c ) = @_;
     my $item = $c->stash->{object} ||
         $c->stash->{resultset}->new_result( {} );

     #set the default backref according to the action (create or edit)
     my $def_br = $c->uri_for('/vlan/list');
     $def_br = $c->uri_for_action( 'vlan/view', [ $c->stash->{object}->id ] )
         if ( defined( $c->stash->{object} ) );
     $c->stash( default_backref => $def_br );

     my $form = IPAdmin::Form::Vlan->new( item => $item );
     $c->stash( form => $form, template => 'vlan/save.tt' );

     # the "process" call has all the saving logic,
     #   if it returns False, then a validation error happened

     if ( $c->req->param('discard') ) {
         $c->detach('/follow_backref');
     }
     return unless $form->process( params => $c->req->params );

     $c->flash( message => 'Vlan creata' );
     $def_br = $c->uri_for_action( 'vlan/view', [ $item->id ] );
     $c->stash( default_backref => $def_br );
     $c->stash( template => 'vlan/save.tt');
     $c->detach('/follow_backref');
 }

=head2 delete

=cut

sub delete : Chained('object') : PathPart('delete') : Args(0) {
    my ( $self, $c ) = @_;
    my $vlan  = $c->stash->{'object'};
    my $id       = $vlan ->id;
        $c->stash( default_backref => $c->uri_for_action('vlan/list') );

    if ( lc $c->req->method eq 'post' ) {
        $vlan->delete;

        $c->flash( message => 'Vlan  ' . $id . ' correttamente cancellata.' );
        $c->detach('/follow_backref');
    }
    else {
        $c->stash( template => 'generic_delete.tt' );
    }
}

=head1 AUTHOR

Rigo

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
