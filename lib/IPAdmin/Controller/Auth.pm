
# Copyright 2011 by the Manoc Team
#
# This library is free software. You can redistribute it and/or modify
# it under the same terms as Perl itself.
package IPAdmin::Controller::Auth;
use Moose;
use namespace::autoclean;
use Data::Dumper;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

IPAdmin::Controller::Auth - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index

=cut

sub index : Path : Args(0) {
    my ( $self, $c ) = @_;
    $c->response->redirect( $c->uri_for('/auth/login') );
    $c->detach();
}

=head2 login

=cut

sub login : Local : CaptureArgs(0) {
    my ( $self, $c ) = @_;

    $c->stash( template => 'auth/login.tt' );
    $c->keep_flash("backref");

    if ( defined( $c->req->params->{'username'} ) ) {
     my $username = lc($c->req->params->{'username'});
	 if ($c->authenticate(
                {
                    username => $c->req->params->{'username'},
                    password => $c->req->params->{'password'},
                }, 'normal'
            )  or $c->authenticate(
                {
                    id    => $c->req->params->{'username'},
                    password => $c->req->params->{'password'},
                }, 'ldap'
            )){
         	$c->flash( message => 'Login avvenuto con successo.' );
          $c->session(user_id => $username);
          $c->detach('/follow_backref');
	 # 	if($c->user_in_realm('normal')){	
		#  $c->detach('/follow_backref');
  #       	}
		# if($c->user_in_realm('ldap') ){
		# $c->response->redirect(
  #         $c->uri_for_action( '/userldap/view', [$username] ) );
  #     		$c->detach();
		# }
          }
         #not authenticated
	 $c->flash( error_msg => 'Invalid Login' );
         $c->response->redirect( $c->uri_for('/auth/login') );
         $c->detach();
	}
}
=head2 logout

=cut

sub logout : Local : CaptureArgs(0) {
    my ( $self, $c ) = @_;

    $c->stash( template => 'auth/logout.tt' );

    $c->logout();
    $c->stash( message => 'Logout avvenuto con successo.' );
    $c->session(user_id => undef);
}

=head2 access_denied

=cut

sub access_denied : Local {
    my ( $self, $c ) = @_;
    $c->flash( backref => $c->req->uri );
    $c->stash( template  => 'auth/access_denied.tt' );
    $c->stash( error_msg => "Attenzione: non hai i permessi per visualizzare questa pagina!" );
}


=head1 AUTHOR

Rigo

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
