# Copyright 2011 by the IPAdmin Team
#
# This library is free software. You can redistribute it and/or modify
# it under the same terms as Perl itself.
package IPAdmin::Controller::Area;
use Moose;
use namespace::autoclean;
use IPAdmin::Form::Area;
use Data::Dumper;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

IPAdmin::Controller::Area - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index

=cut

sub index : Path : Args(0) {
    my ( $self, $c ) = @_;
    $c->response->redirect('area/list');
    $c->detach();
}

=head2 base

=cut

sub base : Chained('/') : PathPart('area') : CaptureArgs(0) {
    my ( $self, $c ) = @_;
    $c->stash( resultset => $c->model('IPAdminDB::Area') );
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

    my @area_table = $build_schema->search({},{prefetch => [{building => {vlan => 'map_subnet'}},'manager', 'department',{filter_subnet=> 'area'}]});
    my %subnet;
    foreach my $area (@area_table){
       my @filtered = $area->filtered->all;
       $subnet{$area->id}  =  \@filtered;
    }

    $c->stash( area_table => \@area_table );
    $c->stash( filtered => \%subnet );

    $c->stash( template       => 'area/list.tt' );
}

=head2 view

=cut

sub view : Chained('object') : PathPart('view') : Args(0) {
    my ( $self, $c ) = @_;
    my %filtered   = map {$_->id => 1} $c->stash->{'object'}->filtered->all;
    $c->stash( filtered    => \%filtered);

    $c->stash( template => 'area/view.tt' );
}

=head2 edit

=cut

sub edit : Chained('object') : PathPart('edit') : Args(0) {
    my ( $self, $c ) = @_;     

    my $id;
    my ($realm, $user) = IPAdmin::Utils::find_user($self,$c,$c->session->{user_id}); 
    !defined($user) and $c->detach('/access_denied');
    $c->stash( default_backref => $c->uri_for_action('area/view',[$c->stash->{'object'}->id]) );

    if ( lc $c->req->method eq 'post' ) {
        if ( $c->req->param('discard') ) {
            $c->detach('/follow_backref');
        }
        my $done = $c->forward('process_edit');
        if ($done) {
            $c->flash( message => $c->stash->{message} );
            $c->detach('/follow_backref');
        }
    }
    #set form defaults
    my %filtered   = map {$_->id => 1} $c->stash->{'object'}->filtered->all;



    my @subnets    = $c->stash->{'object'}->building->vlan->map_subnet;        
    my @building   = $c->model('IPAdminDB::Building')->search({},{order_by => 'name'}) ;
    my @department = $c->model('IPAdminDB::Department')->search({}) ;

    $c->stash( subnets    => \@subnets );
    $c->stash( department => \@department );
    $c->stash( building   => \@building );
    
    my @managers;
    my $id_dep  = $c->stash->{'object'}->department->id;
    my @man_req = $c->model('IPAdminDB::ManagerRequest')->search(department => $id_dep); 
    my $bit_map = {};
    foreach my $req ( @man_req ) {
        next unless(defined($req->user));
        next if($bit_map->{$req->user->id});
        push @managers, { value => $req->user->id, label => $req->user->fullname};
        $bit_map->{$req->user->id} = 1;
    }
    $c->stash( managers   => \@managers );


    $c->stash( filtered   => \%filtered);
    $c->stash( template   => 'area/edit.tt' );

}

sub process_edit : Private {
    my ( $self, $c )   = @_;
    #user editable fields
    my $id_build       = $c->req->param('building');
    my $id_dep         = $c->req->param('department');
    my $area           = $c->stash->{'object'};
    my $id_man         = $c->req->param('manager') || undef;
    my @subnets        = $area->building->vlan->map_subnet;

    # check form
    #$c->forward('check_edit_form') || return 0; 
    $c->model('IPAdminDB::FilterSubnet')->search({area_id => $area->id})->delete;

    foreach my $subnet (@subnets){
        if($c->req->param($subnet->id)){
            $c->model('IPAdminDB::FilterSubnet')->update_or_create({
                     area_id   => $area->id,
                     subnet_id => $subnet->id
                    });
        }
    }       

    my $ret = $area->update(
        {
            building    => $id_build,
            department  => $id_dep,
            manager     => $id_man, 
        }
        );


    if (! $ret ) {
    $c->stash->{error_msg} = "Errore nella modifica dell\'Area";
    return 0;
    } else {
    $c->stash->{message} = "Area modificata con successo.";
    return 1;
    }
}




=head2 save

# Handle create and edit resources

=cut

 sub save : Private {
    my ( $self, $c ) = @_;   
    my $def_build = $c->req->param('def_build') || -1;
    my $item = $c->stash->{object}; 


    if(!defined $item){ 
        defined $def_build ? $item = $c->stash->{resultset}->new_result( {building => $def_build} ) : 
        $item = $c->stash->{resultset}->new_result( {} );
        delete $c->req->params->{'def_build'} 
    }

    #set the default backref according to the action (create or edit)
    my $def_br = $c->uri_for('/area/list');
    $def_br = $c->uri_for_action( 'area/view', [ $c->stash->{object}->id ] )
         if ( defined( $c->stash->{object} ) );
    $c->stash( default_backref => $def_br );

    my $form = IPAdmin::Form::Area->new( {item => $item, def_build => $def_build} );
    $c->stash( form => $form, template => 'area/save.tt' );

     # the "process" call has all the saving logic,
     #   if it returns False, then a validation error happened

    if ( $c->req->param('discard') ) {
         $c->detach('/follow_backref');
    }
    return unless $form->process( params => $c->req->params);

    # foreach my $subnet ($item->building->vlan->map_subnet){
    #     $c->log->debug("Creazione ".$item->id." ".$subnet->id);
    #     $c->model('IPAdminDB::FilterSubnet')->update_or_create({area_id => $item->id, subnet_id => $subnet->id});        
    # }

    $c->flash( message => 'Area creata con successo.' );
    $def_br = $c->uri_for_action( 'area/view', [ $item->id ] );
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
    my $area = $c->stash->{'object'};
    my $id       = $area->id;
    my $building     = $area->building;
    my $department   = $area->department;
    my $manager	     = $area->manager;
    $c->stash( default_backref => $c->uri_for_action('area/list') );

    if ( lc $c->req->method eq 'post' ) {
#        if ( $c->model('IPAdminDB::Rack')->search( { building => $id } )->count ) {
#            $c->flash( error_msg => 'Building is not empty. Cannot be deleted.' );
#            $c->stash( default_backref => $c->uri_for_action( 'building/view', [$id] ) );
#            $c->detach('/follow_backref');
#        }

        $area->delete;

        $c->flash( message => 'Area  id: ' . $id . ' eliminata con successo.' );
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
