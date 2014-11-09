#!/usr/bin/perl
use strict;
use warnings;
use Bloonix::SQL::Creator;

my $sql = Bloonix::SQL::Creator->new(driver => "Pg");

my %from = (
    function => "to_char",
    column   => "invoice.from_time",
    pattern  => "YYYY-MM-DD",
    alias    => "from_timestamp"
);

my %to = (
    function => "to_char",
    column   => "invoice.to_time",
    pattern  => "YYYY-MM-DD",
    alias    => "to_timestamp"
);

my %expired = (
    function => "to_char",
    column   => "invoice.expired",
    pattern  => "YYYY-MM-DD",
    alias    => "expired_at"
);

my ($stmt, @bind) = $sql->select(
    table => [
        invoice  => [ "*", \%from, \%to, \%expired ],
        customer => [ qw(company bank_collection) ]
    ],
    join => [
        inner => {
            table => "customer",
            left  => "invoice.customer_id",
            right => "customer.id"
        }
    ]
);

print "Statement: $stmt\n";
print "Binds: ", join(',', @bind), "\n";

