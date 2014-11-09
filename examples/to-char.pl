#!/usr/bin/perl
use strict;
use warnings;
use Bloonix::SQL::Creator;

my $sql = Bloonix::SQL::Creator->new(driver => "Pg");

my %convert = (
    function => "to_char",
    column   => "creation_time",
    pattern  => "YYYY-MM-DD HH24:MI:SS",
    alias    => "timestamp",
);

my ($stmt, @bind) = $sql->select(
    table  => "ticket",
    column => [ "*", \%convert ],
    condition => [ status => 1 ],
    order => [ asc => "id" ]
);

print "Statement: $stmt\n";
print "Binds: ", join(',', @bind), "\n";

