package IPAdmin::View::TT;
use Moose;
use namespace::autoclean;

extends 'Catalyst::View::TT';

__PACKAGE__->config(
	    TEMPLATE_EXTENSION => '.tt',
	    INCLUDE_PATH       => [
	        IPAdmin->path_to( 'root', 'src' ),
	        IPAdmin->path_to( 'root', 'src', 'include' ),
	        IPAdmin->path_to( 'root', 'src', 'forms' ),
				    ],
            PRE_PROCESS => 'init.tt',
            WRAPPER     => 'wrapper.tt',
            render_die  => 1,
		);



#__PACKAGE__->meta->make_immutable;

1;

=head1 NAME

IPAdmin::View::TT - Catalyst View

=head1 DESCRIPTION

Catalyst View.

=head1 AUTHOR

Enrico Liguori

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

