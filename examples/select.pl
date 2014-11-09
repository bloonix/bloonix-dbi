#!/usr/bin/perl
use strict;
use warnings;
use Bloonix::SQL::Creator;

my $sql = Bloonix::SQL::Creator->new(driver => "Pg");

my ($stmt, @bind) = $sql->select(
    table => [
        user   => [qw/username surname/],
        thread => [qw/id date time text/],
    ]
);

print "Statement: $stmt\n";
print "Binds: ", join(',', @bind), "\n";
