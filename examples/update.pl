#!/usr/bin/perl
use strict;
use warnings;
use Bloonix::SQL::Creator;

my $sql = Bloonix::SQL::Creator->new(driver => "Pg");

my ($stmt, @bind) = $sql->update(
    table => "user",
    data => {
        salary => 5000,
        pax => 0
    }
);

print "Statement: $stmt\n";
print "Binds: ", join(',', @bind), "\n";
