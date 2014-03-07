#!/usr/bin/perl
# -*- cperl -*-
use strict;
use warnings;

package IPAdmin::InitDB;

use FindBin;
use lib "$FindBin::Bin/../lib";
eval { use local::lib "$FindBin::Bin/../support" };

use Moose;
use IPAdmin::Logger;

extends 'IPAdmin::App';
with 'MooseX::Getopt::Dashes';

has 'reset_admin' => (
    is       => 'rw',
    isa      => 'Bool',
    required => 0,
    default  => 0
);

sub run {
    my ($self) = @_;

    if  ($self->reset_admin) {
        $self->do_reset_admin;
        return;
    }

    # full init
    $self->do_reset_admin;
}

sub do_reset_admin {
    my ($self) = @_;

    my $schema = $self->schema;
    $self->log->info('Creating admin role.');
    my $admin_role = $schema->resultset('Role')->update_or_create( { role => 'admin', } );
    $self->log->info('Creating user role.');
    $schema->resultset('Role')->update_or_create( { role => 'user', } );

    $self->log->info('Creating admin user.');
    my $admin_user = $schema->resultset('User')->update_or_create(
        {
            username => 'admin',
            fullname => 'Administrator',
            active   => 1,
            password => 'admin',
        }
    );
#    $self->log->info('Adding admin role to the admin user (password: admin)... done.');
#    if ( $admin_user->roles->search( { role => 'admin' } )->count == 0 ) {
#        $admin_user->add_to_roles($admin_role);
#    }
}

no Moose;

package main;

my $app = IPAdmin::InitDB->new_with_options();
$app->run();

# Local Variables:
# mode: cperl
# indent-tabs-mode: nil
# cperl-indent-level: 4
# cperl-indent-parens-as-block: t
# End:
