use strict;
use warnings;

use IPAdmin;

my $app = IPAdmin->apply_default_middlewares(IPAdmin->psgi_app);
$app;

