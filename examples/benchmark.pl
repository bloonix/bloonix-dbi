#!/usr/bin/perl
use strict;
use warnings;
use Bloonix::SQL::Creator;
use Benchmark;

my $sql = Bloonix::SQL::Creator->new(driver => "Pg");

sub create {
    my ($stmt, @bind) = $sql->select(
        distinct => 1,
        table => [
            event   => "*",
            service => [qw/service_name host_id/],
            host    => "hostname",
        ],
        join => [
            inner => [ "service", "event.service_id", "service.id" ],
            inner => [ "host", "service.host_id", "host.id" ],
            inner => [ "host_group", "host.id", "host_group.host_id" ],
            inner => [ "user_group", "host_group.group_id", "user_group.group_id" ],
        ],
        condition => [
            where => {
                table  => "event",
                column => "time",
                op     => ">",
                value  => time,
            },
            and => {
                table  => "user_group",
                column => "user_id",
                op     => "=",
                value  => 1,
            },
        ],
        order_desc => "time",
        limit => 30,
    );
}

Benchmark::timethis(10000, \&create);

