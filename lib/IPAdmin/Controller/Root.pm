package IPAdmin::Controller::Root;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

with 'IPAdmin::BackRef::Actions';

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config( namespace => '' );

=head1 NAME

IPAdmin::Controller::Root - Root Controller for IPAdmin

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=head2 index

The root page (/)

=cut

sub index : Path : Args(0) {
    my ( $self, $c ) = @_;
    $c->response->redirect('/userldap');
    $c->detach();
}

=head2 auto


=cut

sub auto : Private {
  my ( $self, $c ) = @_;
        use Data::Dumper;

  if ( $c->controller eq $c->controller('Auth') ) {
   return 1;
  }

  if($c->request->path eq "managerrequest/public_list" ){
    return 1;
  }

  # If a user doesn't exist, force login
  if (!$c->user_exists) {
      $c->flash( backref => $c->request->uri );
      $c->request->path !~ m|^$|o
        and $c->flash( error_msg => 'You must login to view this page!');
        $c->response->redirect($c->uri_for_action('/auth/login'));
       return 0;
   }

  my ($realm, $user) = IPAdmin::Utils::find_user($self,$c,$c->user->username);

  if($realm eq 'ldap' and defined($user) ){
    if(!$user->active){
    $c->flash( error_msg => 'Il suo account è stato disabilitato. Contattare l\'amministratore di rete.');
    $c->response->redirect($c->uri_for_action('/auth/login'));
   }
  }

  return 1;
}

=head2 default

Standard 404 error page

=cut

sub default : Path {
    my ( $self, $c ) = @_;
    my $url = $c->request->uri;
    $c->response->body("Page not found $url");
    
    $c->response->status(404);
}

=head2 message

Basic minimal page for showing messages

=cut

sub message : Path('message') Args(0) {
    my ( $self, $c ) = @_;
    my $page = $c->request->param('page');
    $c->stash( template => 'message.tt' );
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {
}

=head2 access_denied

=cut

sub access_denied : Private {
    my ( $self, $c ) = @_;
    $c->flash( backref => $c->req->uri );
    $c->stash( template  => 'auth/access_denied.tt' );
    $c->stash( error_msg => "Sorry, you are not allowed to see this page!" );
}

=head1 AUTHOR

gabriele

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
