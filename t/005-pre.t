use strict;
use warnings;
use Test::More tests => 4;
use Bloonix::SQL::Creator;
use Data::Dumper;

my $sql = Bloonix::SQL::Creator->new(driver => "Pg");

my ($stmt, @bind) = $sql->condition([
    where => { column => "x", value => "x" },
    pre => [
        pre => [
            pre => [
                pre => [
                    and => { column => "a", value => "a" },
                    and => { column => "b", value => "b" },
                ]
            ]
        ]
    ]
]);

ok(
    $stmt eq 'where "x" = ? and ( ( ( ( "a" = ? and "b" = ? ) ) ) )',
    "condition pre 1"
);

($stmt, @bind) = $sql->condition([
    where => { column => "x", value => "x" },
    pre => [
        pre => [
            and => { column => "a", value => "a" },
            and => { column => "b", value => "b" },
        ],
        pre => [
            and => { column => "c", value => "c" },
            and => { column => "d", value => "d" },
        ],
        pre => [
            and => { column => "e", value => "e" },
            and => { column => "f", value => "f" },
        ],
    ]
]);

ok(
    $stmt eq 'where "x" = ? and ( ( "a" = ? and "b" = ? ) and ( "c" = ? and "d" = ? ) and ( "e" = ? and "f" = ? ) )',
    "condition pre 2"
);

($stmt, @bind) = $sql->condition([
    where => { column => "x", value => "x" },
    pre => [
        pre => [
            and => { column => "a", value => "a" },
            pre => [
                and => { column => "e", value => "e" },
                and => { column => "f", value => "f" },
            ],
            and => { column => "b", value => "b" },
        ],
        pre => [
            and => { column => "c", value => "c" },
            and => { column => "d", value => "d" },
            pre => [
                and => { column => "g", value => "g" },
                and => { column => "h", value => "h" },
            ],
        ],
        pre => [
            pre => [
                and => { column => "i", value => "i" },
                and => { column => "j", value => "j" },
            ],
            and => { column => "k", value => "k" },
        ],
    ]
]);

ok(
    $stmt eq 'where "x" = ? and ( ( "a" = ? and ( "e" = ? and "f" = ? ) and "b" = ? ) and ( "c" = ? and "d" = ? and ( "g" = ? and "h" = ? ) ) and ( ( "i" = ? and "j" = ? ) and "k" = ? ) )',
    "condition pre 3"
);

($stmt, @bind) = $sql->condition([
    pre => [
        where => { column => "a", value => "a" },
        and => { column => "b", value => "b" }
    ],
    or => { column => "c", value => "c" },
]);

ok(
    $stmt eq 'where ( "a" = ? and "b" = ? ) or "c" = ?',
    "condition pre 4"
);
