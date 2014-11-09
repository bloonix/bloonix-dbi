#!/usr/bin/perl
use strict;
use warnings;
use Bloonix::SQL::Creator;

my $sql = Bloonix::SQL::Creator->new(driver => "Pg");

my ($stmt, @bind) = $sql->select(
    table => [
        user   => [qw/username surname/],
        thread => [qw/id date time text/],
    ],
    order => [
        desc => [qw/user username/],
        asc  => [qw/user surname/],
        desc => [qw/thread id date/],
        asc  => [qw/thread time text/],
    ],
);

print "Statement: $stmt\n";
print "Binds: ", join(',', @bind), "\n";
