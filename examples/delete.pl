#!/usr/bin/perl
use strict;
use warnings;
use Bloonix::SQL::Creator;

my $sql = Bloonix::SQL::Creator->new(driver => "Pg");

my ($stmt, @bind) = $sql->delete(
    table => "user",
    condition => [
        username => "Jonny",
        surname => "Schulz"
    ]
);

print "Statement: $stmt\n";
print "Binds: ", join(',', @bind), "\n";
