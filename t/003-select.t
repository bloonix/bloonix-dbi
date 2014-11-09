use strict;
use warnings;
use Test::More tests => 2;
use Bloonix::SQL::Creator;
use Data::Dumper;

$Data::Dumper::Sortkeys = 1;

my $sql = Bloonix::SQL::Creator->new(driver => "Pg");

my @orig = (
    table => [
        test1 => [ qw(a b c) ],
        test2 => "d",
        test3 => "*",
    ],
    join => [
        inner => {
            table => "test",
            left  => "a",
            right => "b",
        },
    ],
    condition => [
        where => {
            table => "test1",
            column => "a",
            op => "=",
            value => 10,
        },
    ],
    order => [
        asc => [ "test1.a", "b" ]
    ],
    group_by => [ qw(a b c) ],
    limit => 10,
    offset => 20,
);

my $dump_before = Dumper(\@orig);

my ($stmt, @bind) = $sql->select(@orig);

ok($stmt eq 'select "test1"."a","test1"."b","test1"."c","test2"."d","test3".* from "test1" inner join "test" on "a" = "b" where "test1"."a" = ? group by "a","b","c" order by "test1"."a" asc,"b" asc limit ? offset ?', "statement");

my $dump_after = Dumper(\@orig);

ok($dump_before eq $dump_after, "equal data");
