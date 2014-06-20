package IPAdmin::View::Email;

use strict;
use base 'Catalyst::View::Email';

__PACKAGE__->config(
    stash_key => 'email'
);

=head1 NAME

IPAdmin::View::Email - Email View for IPAdmin

=head1 DESCRIPTION

View for sending email from IPAdmin. 

=head1 AUTHOR

enrico liguori

=head1 SEE ALSO

L<IPAdmin>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;