#!/usr/bin/perl
use strict;
use warnings;
use Bloonix::SQL::Creator;

my $sql = Bloonix::SQL::Creator->new(driver => "Pg");

my ($stmt, @bind) = $sql->select(
    table => [
        user   => ["id AS user.id", "username"],
        thread => ["id AS thread.id", "thread"],
    ],
);

print "Statement: $stmt\n";
print "Binds: ", join(',', @bind), "\n";
