use strict;
use warnings;
use Test::More tests => 2;
use Bloonix::SQL::Creator;

my $sql = Bloonix::SQL::Creator->new(driver => "Pg");

my ($stmt, @bind) = $sql->select(
    count => "id",
    table => "test",
);

ok($stmt eq 'select count("id") AS count from "test"', "count 1");

($stmt, @bind) = $sql->select(
    table => "bloonix_3_event",
    count => "*",
    condition => [
        where => {
            column => "service_id",
            op     => "=",
            value  => 24,
        },
        and => {
            column => "time",
            op     => ">=",
            value  => 1362948270,
        },
        and => {
            column => "time",
            op     => "<=",
            value  => 1362950070,
        },
    ],
);

ok($stmt eq 'select count(*) AS count from "bloonix_3_event" where "service_id" = ? and "time" >= ? and "time" <= ?', "count 2");
