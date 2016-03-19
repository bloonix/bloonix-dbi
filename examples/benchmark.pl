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
            service => "*",
            service_parameter => "*",
            host => [
                "hostname", "interval", "ipaddr",
                "notification AS host_notification",
                "active AS host_active"
            ],
            company => [ "id AS company_id", "company" ],
            status_priority => "priority",
            plugin => "plugin"
        ],
        join => [
            inner => {
                table => "service_parameter",
                left => "service.service_parameter_id",
                right => "service_parameter.ref_id"
            },
            inner => {
                table => "host",
                left => "service.host_id",
                right => "host.id"
            },
            inner => {
                table => "company",
                left => "host.company_id",
                right => "company.id"
            },
            inner => {
                table => "status_priority",
                left => "service.status",
                right => "status_priority.status"
            },
            inner => {
                table => "host_group",
                left => "host.id",
                right => "host_group.host_id"
            },
            inner => {
                table => "user_group",
                left => "host_group.group_id",
                right => "user_group.group_id"
            },
            inner => {
                table => "plugin",
                left => "service_parameter.plugin_id",
                right => "plugin.id"
            }
        ],
        condition => [
            where => {
                table  => "user_group",
                column => "user_id",
                value  => 1
            },
            and => {
                table  => "host",
                column => "id",
                value  => [2,3,4]
            },
        ],
        order => [
            desc => ["status_priority.priority", "service.status_nok_since"],
            asc => ["host.hostname", "service_parameter.service_name"]
        ],
        limit => 10,
        offset => 0
    );
}

Benchmark::timethis(100000, \&create);
