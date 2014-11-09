#!/usr/bin/perl
use strict;
use warnings;
use Bloonix::SQL::Creator;

sub count {
    my $stmt = shift;
    my $open = () = $stmt =~ /\(/g;
    my $close = () = $stmt =~ /\)/g;
    print "Open: $open; Close $close\n";
}

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

print "Condition: $stmt\n";
print "Binds: ", join(',', @bind), "\n";
&count($stmt);
print "\n";

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

print "Condition: $stmt\n";
print "Binds: ", join(',', @bind), "\n";
&count($stmt);
print "\n";

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

print "Condition: $stmt\n";
print "Binds: ", join(',', @bind), "\n";
&count($stmt);
print "\n";

($stmt, @bind) = $sql->condition([
    where => { column => "x", value => "x" },
    pre => [
        pre => [
            and => { column => "a", value => "a" },
            and => { column => "b", value => "b" }
        ],
        or => { column => "c", value => "c" },
    ]
]);

print "Condition: $stmt\n";
print "Binds: ", join(',', @bind), "\n";
&count($stmt);
print "\n";

($stmt, @bind) = $sql->condition([
    pre => [
        where => { column => "a", value => "a" },
        and => { column => "b", value => "b" }
    ],
    or => { column => "c", value => "c" },
]);

print "Condition: $stmt\n";
print "Binds: ", join(',', @bind), "\n";
&count($stmt);
print "\n";

