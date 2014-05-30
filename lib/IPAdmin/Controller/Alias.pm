# Copyright 2011 by the IPAdmin Team
#
# This library is free software. You can redistribute it and/or modify
# it under the same terms as Perl itself.
package IPAdmin::Controller::Alias;
use Moose;
use namespace::autoclean;
use IPAdmin::Form::Alias;
use Data::Dumper;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

IPAdmin::Controller::Alias - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index

=cut

sub index : Path : Args(0) {
    my ( $self, $c ) = @_;
    $c->response->redirect('alias/list');
    $c->detach();
}

=head2 base

=cut

sub base : Chained('/') : PathPart('alias') : CaptureArgs(0) {
    my ( $self, $c ) = @_;
    $c->stash( resultset => $c->model('IPAdminDB::Alias') );
}

=head2 object

=cut

sub object : Chained('base') : PathPart('id') : CaptureArgs(1) {
    my ( $self, $c, $id ) = @_;

    $c->stash( object => $c->stash->{resultset}->find($id) );

    if ( !$c->stash->{object} ) {
        $c->stash( error_msg => "Object $id not found!" );
        $c->detach('/error/index');
    }
}

=head2 list

=cut

sub list : Chained('base') : PathPart('list') : Args(0) {
    my ( $self, $c ) = @_;

    my $build_schema = $c->stash->{resultset};

    my @alias_table = $build_schema->all;

    $c->stash( alias_table => \@alias_table );
    $c->stash( template       => 'alias/list.tt' );
}

=head2 view

=cut

sub view : Chained('object') : PathPart('view') : Args(0) {
    my ( $self, $c ) = @_;

    $c->stash( template => 'alias/view.tt' );
}

=head2 edit

=cut

sub edit : Chained('object') : PathPart('edit') : Args(0) {
    my ( $self, $c ) = @_;     
    $c->forward('save');
}

=head2 save

# Handle create and edit resources

=cut

 sub save : Private {
    my ( $self, $c ) = @_;   
    my $def_ipreq = $c->req->param('def_ipreq') || -1;
    my $item = $c->stash->{object}; 

    if(!defined $item){ 
        defined $def_ipreq ? $item = $c->stash->{resultset}->new_result( {ip_request => $def_ipreq} ) : $item = $c->stash->{resultset}->new_result( {} );
        delete $c->req->params->{'def_ipreq'} 
    }

     #set the default backref according to the action (create or edit)
    my $def_br = $c->uri_for('/alias/list');
    $def_br = $c->uri_for_action( 'alias/view', [ $c->stash->{object}->id ] )
         if ( defined( $c->stash->{object} ) );
     $c->stash( default_backref => $def_br );

    my $form = IPAdmin::Form::Alias->new( {item => $item, def_ipreq => $def_ipreq} );
     $c->stash( form => $form, template => 'alias/save.tt' );

     # the "process" call has all the saving logic,
     #   if it returns False, then a validation error happened

     if ( $c->req->param('discard') ) {
         $c->detach('/follow_backref');
     }
     return unless $form->process( params => $c->req->params);

     $c->flash( message => 'Success! Alias created.' );
     $def_br = $c->uri_for_action( 'alias/view', [ $item->id ] );
     $c->stash( default_backref => $def_br );
     $c->detach('/follow_backref');
 }

=head2 create

=cut

sub create : Chained('base') : PathPart('create') : Args(0) {
     my ( $self, $c) = @_;
     $c->forward('save');
 }

=head2 delete

=cut

sub delete : Chained('object') : PathPart('delete') : Args(0) {
    my ( $self, $c ) = @_;
    my $alias = $c->stash->{'object'};
    my $id       = $alias->id;

    $c->stash( default_backref => $c->uri_for_action('alias/list') );

    if ( lc $c->req->method eq 'post' ) {
#        if ( $c->model('IPAdminDB::Rack')->search( { building => $id } )->count ) {
#            $c->flash( error_msg => 'Building is not empty. Cannot be deleted.' );
#            $c->stash( default_backref => $c->uri_for_action( 'building/view', [$id] ) );
#            $c->detach('/follow_backref');
#        }

        $alias->delete;

        $c->flash( message => 'Success!!  ' . $id . ' successful deleted.' );
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
