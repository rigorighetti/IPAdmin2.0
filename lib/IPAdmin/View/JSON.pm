package IPAdmin::View::JSON;

use strict;
use base 'Catalyst::View::JSON';

use JSON;

=head1 NAME

IPAdmin::View::JSON - Catalyst JSON View

=head1 SYNOPSIS

See L<IPAdmin>

=cut

sub encode_json($) {
    my($self, $c, $data) = @_;

    # HACK we use latin1 to avoid a double uft8 encoding 
    my $encoder = JSON->new->latin1();

    $encoder->encode($data);
}


=head1 DESCRIPTION

Catalyst JSON View.

=head1 AUTHOR

Rigo

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
