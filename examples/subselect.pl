#!/usr/bin/perl
use strict;
use warnings;
use Bloonix::SQL::Creator;

my $sql = Bloonix::SQL::Creator->new(driver => "Pg");

my %select = (
    table     => "y",
    column    => "x",
    condition => [
        where => {
            table => "y",
            column => "z",
            value => 5
        }
    ]
);

my ($stmt, @bind) = $sql->select(
    table  => "x",
    column => [qw/a b c d e/],
    condition => [
        where  => { table => "x", column => "a", op => "=",  value => 1        },
        and    => { table => "x", column => "c", op => "in", value => [2,3,4]  },
        and    => { table => "x", column => "d", op => "in", value => \%select },
        or     => { table => "x", column => "e", op => ">=", value => 6        }
    ],
    order => [
        desc => "a"
    ]
);

print "Statement: $stmt\n";
print "Binds: ", join(",", @bind), "\n";

=head2 output

    select  "x"."a","x"."b","x"."c","x"."d","x"."e"
    from    "x"
    where   "x"."a"  =   ?
    and     "x"."c"  in  (?,?,?)
    and     "x"."d"  in  (select "y"."x" from "y" where "y"."z" = ?)
    or      "x"."e"  >=  ?
    order by "a" desc
    Binds: 1,2,3,4,5,6

=cut
