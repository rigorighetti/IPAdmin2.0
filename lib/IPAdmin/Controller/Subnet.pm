# Copyright 2011 by the Manoc Team
#
# This library is free software. You can redistribute it and/or modify
# it under the same terms as Perl itself.
package IPAdmin::Controller::Subnet;
use Moose;
use namespace::autoclean;
use IPAdmin::Form::Subnet;
use Data::Dumper;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

IPAdmin::Controller::Subnet - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index

=cut

sub index : Path : Args(0) {
    my ( $self, $c ) = @_;

    $c->response->redirect('/subnet/list');
    $c->detach();
}

=head2 base

=cut

sub base : Chained('/') : PathPart('subnet') : CaptureArgs(0) {
    my ( $self, $c ) = @_;
    $c->stash( resultset => $c->model('IPAdminDB::Subnet') );
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
    $c->stash( template => 'subnet/view.tt');
}

=head2 list

=cut

sub list : Chained('base') : PathPart('list') : Args(0) {
    my ( $self, $c ) = @_;
    my $schema    = $c->stash->{resultset};
    my @subnet_list = $schema->search({}, {prefetch => 'vlan'});
   
    $c->stash(
        subnet_list => \@subnet_list,
        template  => 'subnet/list.tt'
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
     my $def_br = $c->uri_for('/subnet/list');
     $def_br = $c->uri_for_action( 'subnet/view', [ $c->stash->{object}->id ] )
         if ( defined( $c->stash->{object} ) );
     $c->stash( default_backref => $def_br );

     my $form = IPAdmin::Form::Subnet->new( item => $item );
     $c->stash( form => $form, template => 'subnet/save.tt' );

     # the "process" call has all the saving logic,
     #   if it returns False, then a validation error happened

     if ( $c->req->param('discard') ) {
         $c->detach('/follow_backref');
     }
     return unless $form->process( params => $c->req->params );

     $c->flash( message => 'Subnet creata' );
     $def_br = $c->uri_for_action( 'subnet/view', [ $item->id ] );
     $c->stash( default_backref => $def_br );
     $c->stash( template => 'subnet/save.tt');
     $c->detach('/follow_backref');
 }

=head2 delete

=cut

sub delete : Chained('object') : PathPart('delete') : Args(0) {
    my ( $self, $c ) = @_;
    my $subnet  = $c->stash->{'object'};
    my $id       = $subnet ->id;
    my $name     = $subnet ->name;
    $c->stash( default_backref => $c->uri_for_action('subnet/list') );

    if ( lc $c->req->method eq 'post' ) {
        $subnet->delete;

        $c->flash( message => 'Subnet  ' . $id . ' correttamente cancellata.' );
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
