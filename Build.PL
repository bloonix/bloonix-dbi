use strict;
use warnings;
use Module::Build;

my $build = Module::Build->new(
    create_makefile_pl => "traditional",
    module_name => "Bloonix::DBI",
    dist_author => "Jonny Schulz",
    dist_abstract => "Bloonix DBI",
    dist_version => "0.3",
    sign => 0
);

$build->create_build_script;
