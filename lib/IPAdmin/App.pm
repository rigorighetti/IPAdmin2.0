package IPAdmin::App;

# Copyright 2011 by the IPAdmin Team
#
# This library is free software. You can redistribute it and/or modify
# it under the same terms as Perl itself.

use Moose;
with 'MooseX::Getopt::Dashes';
with 'IPAdmin::Logger::Role';

use Config::JFDI;
use FindBin;
use File::Spec;

use IPAdmin::DB;
use IPAdmin::Logger;

has 'verbose' => (
    is       => 'rw',
    isa      => 'Bool',
    required => 0
);

has 'debug' => (
    is       => 'rw',
    isa      => 'Bool',
    required => 0
);

has 'config' => (
    traits  => ['NoGetopt'],
    is      => 'ro',
    lazy    => 1,
    builder => '_build_config'
);

has 'schema' => (
    traits  => ['NoGetopt'],
    is      => 'ro',
    lazy    => 1,
    builder => '_build_schema'
);

sub _build_config {
    my $self = shift;
    my $config;

    my @config_paths = ( File::Spec->catdir( $FindBin::Bin, File::Spec->updir() ), '/etc', );

    foreach my $path (@config_paths) {
        $config = Config::JFDI->open(
            path => $path,
            name => 'ipadmin',
        );
        $config and last;
    }
    $config or die "Cannot find config file";

    return $config;
}

sub _build_schema {
    my $self = shift;

    my $config       = $self->config;
    my $connect_info = $config->{'Model::IPAdminDB'}->{connect_info};
    my $schema       = IPAdmin::DB->connect(@$connect_info);

    return $schema;
}

sub _init_logging {
    my $self = shift;

    return if IPAdmin::Logger->initialized();

    my %args;
    $args{debug} = $self->debug;
    $args{class} = ref($self);

    IPAdmin::Logger->init( \%args );
}

no Moose;    # Clean up the namespace.
__PACKAGE__->meta->make_immutable;

# Local Variables:
# mode: cperl
# indent-tabs-mode: nil
# cperl-indent-level: 4
# cperl-indent-parens-as-block: t
# End:
