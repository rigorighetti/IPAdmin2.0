# Copyright 2013 by the IPAdmin Team

package IPAdmin::Controller::Department;
use Moose;
use namespace::autoclean;
use IPAdmin::Form::Department;
use Data::Dumper;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

IPAdmin::Controller::Building - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index

=cut

sub index : Path : Args(0) {
	my ( $self, $c ) = @_;
	$c->response->redirect('department/list');
	$c->detach();
}

=head2 base

=cut

sub base : Chained('/') : PathPart('department') : CaptureArgs(0) {
	my ( $self, $c ) = @_;
	$c->stash( resultset => $c->model('IPAdminDB::Department') );
}

=head2 object

=cut

sub object : Chained('base') : PathPart('id') : CaptureArgs(1) {
	my ( $self, $c, $id ) = @_;
	
	$c->stash( object => $c->stash->{resultset}->find($id) );

	if ( !$c->stash->{object} ) {
		$c->stash( error_msg => "Object $id not found!" );
		$c-detach('/error/index');
	}
}

=head2 list

=cut

sub list : Chained('base') : PathPart('list') : Args(0) {
	my ( $self, $c ) = @_;
	
	my $build_schema = $c->stash->{resultset};

#        my @department_table = $build_schema->all;

	my @department_table = map +{
	        id      => $_->id,
	        name    => $_->name,
	        description    => $_->description,
	        domain  => $_->domain,
		n_build => $_->buildings->count()
	        },
	        $build_schema->search({},
        	                      {prefetch => 'map_area_build'});

	$c->stash( department_table => \@department_table );
	$c->stash( template	    => 'department/list.tt' );
}

=head2 view

=cut

sub view : Chained('object') : PathPart('view') : Args(0) {
	my ( $self, $c ) = @_;

	$c->stash( template => 'department/view.tt' );
}

=head2 edit

=cut

sub edit : Chained('object') : PathPart('edit') : Args(0) {
	my ( $self, $c ) = @_;
	$c->forward('save');
}

=head2 save

Handle create and edit resources

=cut

sub save : Private {
	my ( $self, $c ) = @_;
	my $item = $c->stash->{object} ||
		$c->stash->{resultset}->new_result( {} );

	#set the default backref according to the action (create or edit)
    	my $def_br = $c->uri_for('/department/list');
    	$def_br = $c->uri_for_action( 'department/view', [ $c->stash->{object}->id ] )
    	    if ( defined( $c->stash->{object} ) );
    	$c->stash( default_backref => $def_br );
	
    	my $form = IPAdmin::Form::Department->new( item => $item );
    	$c->stash( form => $form, template => 'department/save.tt' );
	
	# the "process" call has all the saving logic,
	#   if it returns False, then a validation error happened
		
	if ( $c->req->param('discard') ) {
	    $c->detach('/follow_backref');
	}
	return unless $form->process( params => $c->req->params );

	$c->flash( message => 'Success! Department created.' );
    	$def_br = $c->uri_for_action( 'department/view', [ $item->id ] );
    	$c->stash( default_backref => $def_br );
    	$c->detach('/follow_backref');
}

=head2 create

=cut

sub create : Chained('base') : PathPart('create') : Args(0) {
	my ( $self, $c ) = @_;
	$c->forward('save');
}

=head2 delete

=cut

sub delete : Chained('object') : PathPart('delete') : Args(0) {
    my ( $self, $c ) = @_;
    my $department = $c->stash->{'object'};
    my $id         = $department->id;
    my $name       = $department->name;
    $c->stash( default_backref => $c->uri_for_action('department/list') );

    if ( lc $c->req->method eq 'post' ) {
#    	if ( $c->model('IPAdmin::Rack')->search( { department => $id } )->count ) {
#            $c->flash( error_msg => 'Department is not empty. Cannot be deleted.' );
#            $c->stash( default_backref => $c->uri_for_action( 'department/view', [$id] ) );
#            $c->detach('/follow_backref');
#        }

        $department->delete;

        $c->flash( message => 'Success!!  ' . $name . ' successful deleted.' );
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
