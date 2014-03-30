# Copyright 2011 by the IPAdmin Team
#
# This library is free software. You can redistribute it and/or modify
# it under the same terms as Perl itself.
package IPAdmin::Controller::IPRequest;
use Moose;
use namespace::autoclean;
use IPAdmin::Form::IPRequest;
use Data::Dumper;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

IPAdmin::Controller::IPRequest - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index

=cut

sub index : Path : Args(0) {
    my ( $self, $c ) = @_;
    $c->response->redirect('iprequest/list');
    $c->detach();
}

=head2 base

=cut

sub base : Chained('/') : PathPart('iprequest') : CaptureArgs(0) {
    my ( $self, $c ) = @_;
    $c->stash( resultset => $c->model('IPAdminDB::IPRequest') );
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

#=head2 list
# commentata in attesa di capire come fare 
#=cut
#
#sub list : Chained('base') : PathPart('list') : Args(0) {
#    my ( $self, $c ) = @_;
#
#    my $build_schema = $c->stash->{resultset};
#
#    my @iprequest_table = $build_schema->search({});
#
#    $c->stash( iprequest_table => \@iprequest_table );
#    $c->stash( template       => 'iprequest/list.tt' );
#}
#
=head2 view

=cut

sub view : Chained('object') : PathPart('view') : Args(0) {
    my ( $self, $c ) = @_;

    $c->stash( template => 'iprequest/view.tt' );
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
     my $user =  $c->model('IPAdminDB::UserLDAP')->search( { username => $c->user->username } )->single;
     my $item = $c->stash->{object};

     #set the default backref according to the action (create or edit)
     my $def_br;# = $c->uri_for('/iprequest/list');
     $def_br = $c->uri_for_action( 'iprequest/view', [ $c->stash->{object}->id ] )
         if ( defined( $c->stash->{object} ) );
     $c->stash( default_backref => $def_br );

     my $form = IPAdmin::Form::IPRequest->new( );
     $c->stash( form => $form, template => 'iprequest/save.tt' );

     # the "process" call has all the saving logic,
     #   if it returns False, then a validation error happened

     if ( $c->req->param('discard') ) {
         $c->detach('/follow_backref');
     }
     return unless $form->process( params => $c->req->params, 
        defaults => {username => $c->user->fullname} );

     $c->flash( message => 'Success! IPRequest created.' );
     $def_br = $c->uri_for_action( 'iprequest/view', [ $item->id ] );
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

#sub delete : Chained('object') : PathPart('delete') : Args(0) {
#    my ( $self, $c ) = @_;
#    my $iprequest = $c->stash->{'object'};
#    my $id       = $iprequest->id;
#    $c->stash( default_backref => $c->uri_for_action('iprequest/list') );
#
#    if ( lc $c->req->method eq 'post' ) {
##        if ( $c->model('IPAdminDB::Rack')->search( { iprequest => $id } )->count ) {
##            $c->flash( error_msg => 'IPRequest is not empty. Cannot be deleted.' );
##            $c->stash( default_backref => $c->uri_for_action( 'iprequest/view', [$id] ) );
##            $c->detach('/follow_backref');
##        }
#
#        #$iprequest->delete;
#    my ( $self, $c ) = @_;
#    my $device = $c->stash->{'object'};
#    my $id     = $device->id;
#    my ( $e, $it );
#
#    $c->stash( default_backref => $c->uri_for_action('device/list') );
#    if ( lc $c->req->method eq 'post' ) {
#        $c->model('IPAdminDB')->schema->txn_do(
#            sub {
#
#                # transaction....
#                # 1) create a new deletedevice d2
#                # 2) move mat for $device to archivedmat for d2
#                # 3) $device->delete
#                my $del_device = $c->model('IPAdminDB::DeletedIPRequest')->create(
#                    {
#                        ipaddr    => $id,
#                        name      => $device->name,
#                        model     => $device->model,
#                        vendor    => $device->vendor,
#                        timestamp => time()
#                    }
#                );
#
#                $it = $c->model('ManocDB::Mat')->search(
#                    { device => $id, },
#                    {
#                        select => [
#                            'macaddr', 'vlan',
#                            { 'min' => 'firstseen' }, { 'max' => 'lastseen' },
#                        ],
#                        group_by => [qw(macaddr vlan)],
#                        as       => [ 'macaddr', 'vlan', 'min_firstseen', 'max_lastseen' ]
#                    }
#                );
#
#                while ( $e = $it->next ) {
#                    $del_device->add_to_mat_assocs(
#                        {
#                            macaddr   => $e->macaddr,
#                            firstseen => $e->get_column('min_firstseen'),
#                            lastseen  => $e->get_column('max_lastseen'),
#                            vlan      => $e->vlan
#                        }
#                    );
#                }
#                $device->delete;
#            }
#          }
#        );
#        if ($@) {
#            $c->flash( error_msg => 'Commit error: ' . $@ );
#            $c->detach('/error/index');
#        }
#
#        $c->flash( message => 'Richiesta IP archiviata.' );
#        $c->detach('/follow_backref');
#    }
#    else {
#        $c->stash( template => 'generic_delete.tt' );
#    }
#}

=head1 AUTHOR

Rigo

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
