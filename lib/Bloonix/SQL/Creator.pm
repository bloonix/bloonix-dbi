=head1 NAME

Bloonix::SQL::Creator - Create sql statements.

=head1 SYNOPSIS

    my $sql = Bloonix::SQL::Creator->new(
        quote_char => '`',
        name_sep   => "."
    );

    my ($stmt, @bind) = $sql->select(
        table     => \@tables,
        condition => \@condition
    );

=head1 DESCRIPTION

C<Bloonix::SQL::Creator> creates select, insert, update and delete statements for you!

Have fun!

=head1 METHODS

=head2 C<new>

Call C<new> to create a new C<Bloonix::SQL::Creator>. 

=head2 C<log>

Access to Log::Handler alias "bloonix".

=head3 Options

=over 4

=item quote_char

The sign to quote table and column names.

=item name_sep

The separator between table and column names. Default is a dot.

=item driver

It's possible to pass a driver name instead quote_char.
Supported is mysql, Oracle and Pg. The quote sign is set as follows:

If you set the driver then you don't need to set quote_char, because the sign
will be automatically set for you:

    mysql: `
    Oracle: '
    Pg: "

If you want to use a driver that is unsupported then you must use quote_char.

=back

Examples:

    my $sql = Bloonix::SQL::Creator->new(
        quote_char => '`'
    );

Or:

    my $sql = Bloonix::SQL::Creator->new(
        driver => "mysql"
    );

Please note that if you don't set a quote sign or a driver then all table and column names
will not be quoted!

=head2 C<select>

With the method C<select> it's possible to create simple to complex statements.

=head3 Options

=over 4

=item table

Option table is used to set the tables you want to select.

If you set the table name as scalar then you have to set the columns
you want to select with the option C<column>.

    $sql->select(
        table  => "foo",
        column => "bar",
    );

Or

    $sql->select(
        table  => "foo",
        column => [ qw(bar baz) ],
    );

If you want to select columns from different tables then you have to pass
the table and column names as a array reference:

    $sql->select(
        table => [
            $table_a => \@columns_a,
            $table_b => \@columns_b,
        ]
    );

=item column

Option column is used to set the columns you want to select. This option is only useful
if you set the table name as scalar.

=item join

Join tables.

See section join.

=item where

This method is deprecated! Please use C<condition> instead!

=item condition

The condition is used to pass the where clause.

See section condition.

=item order

Order columns ascending or descending. Examples:

    order => [
        asc => "column1",
        asc => "table.column2",
        asc => [ "column3", "column4" ],
        asc => [ "table.column5", "table.column6" ],
        desc => "column7",
        desc => "table.column8",
        desc => [ "column9", "column10" ],
        desc => [ "table.column11", "table.column12" ],
    ]

=item group_by

Group by clause. Examples:

    group_by => "column"
    group_by => "table.column"
    group_by => [ "column1", "column2" ]
    group_by => [ "table.column1", "table.column2" ]

=back

A simple select looks like

    my ($stmt, @bind) = $sql->select(
        table     => $table,
        column    => \@columns,
        condition => \@condition,
    );

A select with a join over 2 tables looks like

    my ($stmt, @bind) = $sql->select(
        table => [
            baz => [ qw/foo bar/ ],
            paz => [ qw/paz voo par/ ],
        ],
        join => [
            inner => {
                table => "paz",
                left  => "baz.id",
                right => "paz.id",
            }
        ],
        condition => [
            where => {
                table  => "baz",
                column => "foo",
                op     => "=",
                value  => "?",
            },
            or => {
                table  => "baz",
                column => "bar",
                op     => "=",
                value  => "?",
            },
            or => {
                table  => "baz",
                column => "bar",
                op     => "is not null",
            },
        ],
    );

The following SQL statement is generated:

    select baz.foo, baz.bar, paz.paz, paz.voo, paz.par
    from baz 
    inner join paz on baz.id = paz.id
    where baz.foo = ?
    or baz.bar = ?

You can use SQL functions like C<to_char>:

(Currently only to_char is supported)

    my %convert = (
        function => "to_char",
        column   => "time",
        pattern  => "YYYY-MM-DD HH24:MI:SS",
        alias    => "timestamp",
    );

    my ($stmt, @bind) = $self->sql->select(
        table  => "event",
        column => [ "*", \%convert ],
    );

=head2 C<insert>

    my ($stmt, @bind) = $sql->insert(
        table => $table,
        data  => \%data
    );

The data must be passed as a hash reference with column-value pairs.

Note: the data will not be modified! So you don't need to clone the data.

=head2 C<update>

    my ($stmt, @bind) = $sql->update(
        table => $table,
        data  => \%data,
        condition => \@condition,
    );

The data must be passed as a hash reference with column-value pairs.

Note: the data will not be modified! So you don't need to clone the data.

=head2 C<delete>

    my ($stmt, @bind) = $sql->delete(
        table     => $table,
        condition => \@condition
    );

=head2 C<join>

Inner join example:
 
    INNER JOIN TABLE b ON a.id = b.id;

Syntax:

    my $stmt = $sql->join(
        join => [
             inner => {
                table => "b",
                left  => "a.id",
                right => "b.id",
            },
        ],
    );

=head2 C<condition>

Simple where clause

    where a = 1
    and   b = 2
    and   c = 3

    my ($stmt, @bind) = $sql->condition(
        [
            a => 1,
            b => 2,
            c => 3
        ]
    );

The simple where clause could also looks like

    where a =  1
    and   b >  2
    and   c <  3
    and   d >= 4
    and   e <= 5
    and   f in (6, 7)
    and   g not in (8, 9) 

    my ($stmt, @bind) = $sql->condition(
        [
            a => { -eq => 1 },
            b => { -gt => 2 },
            c => { -lt => 3 },
            d => { -ge => 4 },
            e => { -le => 5 },
            f => { -in => [ 6, 7 ] },
            g => { -ni => [ 8, 9 ] },
        ]
    );

Possible operators:

    -lt     <
    -le     <=
    -gt     >
    -ge     >=
    -eq     =
    -ne     !=
    -in     in
    -ni     not in
    -IN     is null
    -NN     is not null
    -LI     like
    -NL     not like

=head2 C<create>

Call C<create> to create a freestyle sql statement. You can pass strings
and array references. All strings in a array reference will be quoted.

Example:

    my $stmt = $sql->create(
        select => [qw/id username password/],
        from   => [qw/user/],
    );

This would return (expect the quote char is a "`")

    select `id`, `username`, `password` from `user`

=head2 C<quote>

    my $quoted = $sql->quote(qw/foo bar baz/);

        `foo`,`bar`,`baz`

    my $quoted = $sql->quote(qw/a.foo b.bar c.baz/);

        `a`.`foo`,`b`.`bar`,`a`.`baz`

    my $quoted = $sql->quote("foo a", "foo b", "foo c");

        `foo` `a`,`bar` `b`,`baz` `c`

=head2 C<stmtquote>

If you missing a functionalety then it's possible to let
the sql generator quote a complete sql statement.

Example to replace all C<"> with the quote char of MySQL:

    my $replace = '"';
    my $stmt    = 'select * from "foo" where "a" = ?';
    my $quoted  = $sql->stmtquote($stmt, $replace);

    print $quoted;

Output:

    select * from `foo` where `a` = ?

=head2 C<search>

With the method C<search> it's possible to create sql statements to
search over multiple columns.

    $sql->select(
        table  => "host",
        column => "*",
        condition => [
            where => $sql->search(
                maps => {
                    h => { table => "host", column => "hostname" },
                    a => { table => "host", column => "ipaddr"   },
                    s => { table => "host", column => "status"   },
                },
                concat => [ "host.hostname", "host.ipaddr", "host.description" ],
                query  => "h:foo AND a:bar OR s:baz AND foobarbaz",
            )
        ]
    );

Output (Pg):

    select  "host".*
    from    "host"
    where (
        "host"."hostname" like ?
        and "host"."ipaddr" like ?
        or "host"."status" like ?
        and lower(concat_ws(' ', "host"."hostname","host"."ipaddr","host"."description")) like ?
    )

=over 4

=item query

With the option C<query> you pass the query you want to search. You can combine
the strings with logical AND and OR. Example:

    Search for foo OR bar:

    foo OR bar

If there is no logical operator then OR is the default:

    for OR bar

and

    foo bar

is the same.

=item maps

With the option C<maps> you can define prefixes to map table and host names
to ease the search. As example if you want to search only for hostnames and
ip addresses from the table host:

    query => "h:testserver OR a:127.0.0.1"

Then you can map the string C<h> with the table "host" and column "hostname" with

    maps => {
        h => "host.hostname",
        a => "host.ipaddr"
    }

Or the long version

    maps => {
        h => { table => "host", column => "hostname" },
        a => { table => "host", column => "ipaddr"   }
    }

The sql statement would be

    where host.hostname like '%testserver%'
    or    host.ipaddr   like '%127.0.0.1%'

Please note:

- single quotes C<'> are not allowed as delimiter and will be removed
- leading and ending logical operators will be ignored and removed
- the characters \n, \r, \t will be treated as whitespaces

=item concat

With the option C<concat> you set the column in order to search.

    concat => [ "host.hostname", "host.ipaddr", "host.description" ]
    query  => "testserver"

Then the following sql statement will be created:

    where lower(concat_ws(' ', host.hostname, host.ipaddr, host.description)) like '%testserver%'

On this way you can simulate a fulltext search.

=item delimiter

With this option it's possible to set the delimiter for the concatenation.
By default a whiteapces is used. The following example

    concat => [ "host.hostname", "host.ipaddr", "host.description" ]
    query  => "testserver"
    delimiter => ','

would create

    where lower(concat_ws(',', host.hostname, host.ipaddr, host.description)) like '%testserver%'

Please note: single quotes C<'> are not allowed as delimiter and will be removed

=back

=head1 EXAMPLES

No more examples. Try and error ;-)

=head1 PREREQUISITES

    Data::Dumper
    Log::Handler

=head1 EXPORTS

No exports.

=head1 REPORT BUGS

Please report all bugs to <support(at)bloonix.de>.

=head1 AUTHOR

Jonny Schulz <support(at)bloonix.de>.

=head1 COPYRIGHT

Copyright (C) 2007-2014 by Jonny Schulz. All rights reserved.

=cut

package Bloonix::SQL::Creator;

use strict;
use warnings;
use Data::Dumper;
use Log::Handler;

our $VERSION = "0.1";

sub new {
    my $class = shift;
    my $opts = @_ > 1 ? {@_} : shift;

    $opts->{name_sep} ||= ".";

    if (!$opts->{quote_char} && $opts->{driver}) {
        if ($opts->{driver} =~ /^(?:Pg|PostgreSQL|postgresql)\z/) {
            $opts->{quote_char} = '"';
        } elsif ($opts->{driver} =~ /^(?:MySQL|mysql)\z/) {
            $opts->{quote_char} = '`';
        } elsif ($opts->{driver} =~ /^[Oo]racle\z/) {
            $opts->{quote_char} = "'";
        }
    }

    $opts->{op} = {
        -lt => "<", 
        -le => "<=",
        -gt => ">",
        -ge => ">=",
        -eq => "=",
        -ne => "!=",
        -in => "in",
        -ni => "not in",
        -IN => "is null",
        -NN => "is not null",
        -LI => "like",
        -NL => "not like",
    };

    foreach my $key (qw/name_sep quote_char/) {
        if (!defined $opts->{$key} || !length $opts->{$key}) {
            die "missing mandatory database param '$key'";
        }
    }

    $opts->{allowed_select_keywords} = { map { $_ => 1 } qw(
        table       column      distinct    count
        join        condition   order       order_desc
        order_asc   group_by    min         max
        limit       offset
    )};

    $opts->{log} = Log::Handler->get_logger("bloonix");

    return bless $opts, $class;
}

sub log {
    my $self = shift;

    return $self->{log};
}

sub select {
    my $self   = shift;
    my $select = @_ > 1 ? {@_} : shift;
    my $sep    = $self->{name_sep};
    my $alkeys = $self->{allowed_select_keywords};
    my @stmt   = ("select");
    my @bind   = ();

    foreach my $key (keys %$select) {
        if (!exists $alkeys->{$key}) {
            die "invalid keyword '$key' for select statement: ".Dumper($select);
        }
    }

    # Maybe other methods wants to put some
    # bind variables to @bind.
    $self->{bind} = \@bind;

    if (exists $select->{distinct} && !$select->{count}) {
        push @stmt, "distinct";
    }

    if (exists $select->{count}) {
        if (exists $select->{distinct}) {
            if (ref $select->{count} eq "ARRAY") {
                my @c = map { $self->quote($_) } @{$select->{count}};
                push @stmt, "count(distinct ".join(" || ' ' || ", @c).") AS count";
            } else {
                push @stmt, "count(distinct ".$self->quote($select->{count}).") AS count";
            }
        } else {
            push @stmt, "count(".$self->quote($select->{count}).") AS count";
        }
    }

    if (exists $select->{min}) {
        push @stmt, "min(".$self->quote($select->{min}).") AS min";
    }

    if (exists $select->{max}) {
        push @stmt, "max(".$self->quote($select->{max}).") AS max";
    }

    # select( table => [ tablename => columns ] )
    if (ref($select->{table}) eq "ARRAY") {
        my (@table, @cols, $table);
        my $elem = scalar @{$select->{table}};

        for (my $i=0; $i < $elem; $i++) {
            my $t = $select->{table}[$i]; # tablename
            my @c = ();
            $i++;

            if (ref($select->{table}[$i]) eq "ARRAY") {
                @c = @{$select->{table}[$i]};
            } else {
                @c = ($select->{table}[$i]);
            }

            for (@c) {
                if (ref($_) ne "HASH") {
                    $_ = $t.$sep.$_;
                }   
            }   

            push @cols, @c;

            # There should be at least one table in the from clause
            # but only one if a join clause exists.
            if (!@table || !exists $select->{join}) {
                push @table, $t;
            }
        }

        push @stmt, $self->quote(@cols);
        push @stmt, "from", $self->quote(@table);
    } elsif (exists $select->{column}) {
        if (ref($select->{column}) eq "ARRAY") {
            my @c = @{$select->{column}};

            for (@c) {
                if (ref($_) ne "HASH") {
                    $_ = $select->{table}.$sep.$_;
                }
            }

            push @stmt, $self->quote(@c);
        } else {
            if (ref($select->{column}) eq "HASH") {
                push @stmt, $self->quote(keys %{$select->{column}});
            } else {
                push @stmt, $self->quote($select->{table}.$sep.$select->{column});
            }
        }
        push @stmt, "from", $self->quote($select->{table});
    } elsif (exists $select->{table}) {
        push @stmt, "from", $self->quote($select->{table});
    }

    if (exists $select->{join}) {
        push @stmt, $self->join($select->{join});
    }

    if (exists $select->{condition}) {
        my ($s, @b) = $self->condition($select->{condition});
        push @stmt, $s;
        push @bind, @b;
    }

    if (exists $select->{group_by}) {
        push @stmt, "group by";
        push @stmt, $self->quote($select->{group_by});
    }

    if (exists $select->{order_asc}) {
        warn "order_asc is deprecated";
        push @stmt, "order by";
        push @stmt, ref($select->{order_asc})
            ? $self->quote(@{$select->{order_asc}})
            : $self->quote($select->{order_asc});
        push @stmt, "asc";
    }

    if (exists $select->{order_desc}) {
        warn "order_desc is deprecated";
        push @stmt, "order by";
        push @stmt, ref($select->{order_desc})
            ? $self->quote(@{$select->{order_desc}})
            : $self->quote($select->{order_desc});
        push @stmt, "desc";
    }

    if (exists $select->{order}) {
        push @stmt, "order by";

        if (ref($select->{order}) eq "ARRAY") {
            my $elem = scalar @{$select->{order}};
            my @cols;

            for (my $i=0; $i < $elem; $i+=2) {
                my $type   = $select->{order}[$i];
                my $column = $select->{order}[$i+1];

                if (ref($column) eq "HASH") {
                    push @cols, $self->quote("$column->{table}.$column->{column}") . " $type";
                } elsif (ref($column) eq "ARRAY") {
                    foreach my $col (@$column) {
                        if (ref($col) eq "HASH") {
                            push @cols, $self->quote("$col->{table}.$col->{column}") . " $type";
                        } else {
                            push @cols, $self->quote($col) . " $type";
                        }
                    }
                } else {
                    push @cols, $self->quote($column) . " $type";
                }
            }

            push @stmt, CORE::join(",", @cols);
        } elsif (ref($select->{order}) eq "HASH") {
            warn "'order => { }' is deprecated, please use 'order => [ ]' instead";
            my $ord = $select->{order};

            foreach my $type (qw/asc desc/) {
                if ($ord->{$type}) {
                    if (ref($ord->{$type}) eq "ARRAY") {
                        my @cols;
                        foreach my $col (@{ $ord->{$type} }) {
                            push @cols, $self->quote($col) . " $type";
                        }
                        push @stmt, CORE::join(",", @cols);
                    } else {
                        push @stmt, $self->quote($ord->{$type});
                        push @stmt, $type;
                    }
                }
            }
        } else {
            push @stmt, $self->quote($select->{order});
        }
    }

    if (exists $select->{limit}) {
        push @stmt, "limit ?";
        push @bind, $select->{limit};
    }

    if (exists $select->{offset}) {
        push @stmt, "offset ?";
        push @bind, $select->{offset};
    }

    my $stmt = CORE::join(" ", @stmt);
    return wantarray ? ($stmt, @bind) : $stmt;
}

sub insert {
    my $self   = shift;
    my $insert = @_ > 1 ? {@_} : shift;
    my $quote  = $self->{quote_char};
    my $data   = $insert->{data} || $insert->{column};
    my (@cols, @bind);

    foreach my $c (keys %$data) {
        my $v = $data->{$c};
        push @cols, $c;
        push @bind, $v;
    }

    my $stmt = CORE::join(" ",
        "insert into", $quote.$insert->{table}.$quote,
        "(" . $self->quote(@cols) . ")",
        "values",
        "(" . CORE::join(",", map {"?"} @cols) . ")"
    );

    return wantarray ? ($stmt, @bind) : $stmt;
}

sub update {
    my $self   = shift;
    my $update = @_ > 1 ? {@_} : shift;
    my $quote  = $self->{quote_char};
    my $data   = $update->{data} || $update->{column};
    my (@bind, @set, @stmt);

    foreach my $c (keys %$data) {
        my $v = $data->{$c};
        push @set, "$quote$c$quote = ?";
        push @bind, $v;
    }

    my $stmt = "update $quote$update->{table}$quote set " . CORE::join(",", @set);

    if (exists $update->{condition}) {
        my ($s, @b) = $self->condition($update->{condition});
        push @bind, @b;
        $stmt .= " ".$s;
    }

    return wantarray ? ($stmt, @bind) : $stmt;
}

sub delete {
    my $self   = shift;
    my $delete = @_ > 1 ? {@_} : shift;
    my $quote  = $self->{quote_char};
    my ($stmt, @bind) = $self->condition($delete->{condition});
    $stmt = "delete from ".$quote.$delete->{table}.$quote." ".$stmt;
    return wantarray ? ($stmt, @bind) : $stmt;
}

sub join {
    my ($self, $join) = @_;
    my @stmt;

    for (my $i=0; $i < @$join; $i+=2) {
        my $logic  = $join->[$i];
        my $clause = $join->[$i+1];

        if ($logic =~ /^(inner|left|right|outer)\z/) {
            if (ref($clause) eq "HASH") {
                push @stmt,
                    "$logic join",
                    $self->quote($clause->{table}),
                    "on",
                    $self->quote($clause->{left}),
                    "=",
                    $self->quote($clause->{right});
            } else {
                push @stmt,
                    "$logic join",
                    $self->quote($clause->[0]),
                    "on",
                    $self->quote($clause->[1]),
                    "=",
                    $self->quote($clause->[2]);
            }
        }
    }

    return CORE::join(" ", @stmt);
}

sub where {
    my $self = shift;

    warn "Method Bloonix::SQL::Creator::where() is deprecated!";

    return $self->condition(@_);
}

sub condition {
    my ($self, $where) = @_;
    my $sep = $self->{name_sep};
    my $ops = $self->{op};
    my (@stmt, @bind);

    if (ref($where) eq "HASH") {
        die "hashes are deprecated for conditions!";
    }

    if (scalar @$where == 0) {
        # That could be fatal, because the user gets more data as allowed.
        die "empty condition passed";
    }

    if ($where->[0] eq "where" || $where->[0] eq "pre") {
        #shift @$where;
        return $self->_extended_condition($where);
    }

    for (my $i=0; $i < @$where; $i+=2) {
        my $col = $where->[$i];
        my $val = $where->[$i+1];

        if (!@stmt) {
            push @stmt, "where";
            push @stmt, "(";
        } else {
            push @stmt, "and";
        }

        push @stmt, $self->quote($col);

        if (ref($val) eq "ARRAY") {
            push @stmt, "in";
            push @stmt, "(". CORE::join(",", map {"?"} @$val) .")";
            push @bind, @$val;
        } elsif (ref($val) eq "HASH") {
            my ($op, $value) = %$val;

            if (exists $ops->{$op}) {
                if ($op eq "-in") {
                    push @stmt, $ops->{$op},
                    push @stmt, map {"?"} @$value;
                    push @bind, @$value;
                } elsif ($op eq "-IN" || $op eq "-NN") {
                    push @stmt, $ops->{$op};
                } elsif ($op eq "-TS") {
                    push @stmt, "to_tsquery(?)";
                    push @bind, $value;
                } else {
                    push @stmt, $ops->{$op}, "?";
                    push @bind, $value;
                }
            } else {
                die "missing or invalid operator '$op'";
            }
        } else {
            push @stmt, "=";
            push @stmt, "?";
            push @bind, $val;
        }
    }

    push @stmt, ")";
    my $stmt = CORE::join(" ", @stmt);
    return wantarray ? ($stmt, @bind) : $stmt;
}

sub _extended_condition {
    my ($self, $where, $brace) = @_;
    my $sep = $self->{name_sep};
    my $ops = $self->{op};
    my (@stmt, @bind, $close);
    $brace //= 0;

    for (my $i=0; $i < @$where; $i+=2) {
        my $logic = $where->[$i];
        my $clause = $where->[$i+1];

        # logic can be condition | where | and | or
        if ($logic eq "pre") { # stand for precedence
            my ($s, @b) = $self->_extended_condition($clause, $i == 0 ? $brace + 1 : 1);
            push @stmt, $s, (")");
            push @bind, @b;
            $brace = 0;
            next;
        }

        push @stmt, $logic;

        if ($brace) {
            push @stmt, ("(") x $brace;
            $brace = 0;
        }

        my $col;
        my $val = $clause->{value};
        my $lc = $clause->{lower};
        my $uc = $clause->{upper};
        my $op = $clause->{op};

        if (ref $clause->{column} eq "HASH") {
            $col = $clause->{column};
            if ($col->{concat}) {
                my $del = defined $col->{delimiter} ? $col->{delimiter} : " ";
                $del =~ s/'//g;
                my @quoted;
                foreach my $c (@{$col->{concat}}) {
                    push @quoted, $self->quote($c);
                }
                $col = "lower(concat_ws('$del',".CORE::join(",", @quoted)."))";
            }
        } else {
            $col = $self->quote(
                $clause->{table}
                    ? "$clause->{table}.$clause->{column}"
                    : $clause->{column}
            );
        }

        if (!defined $op) {
            $op = ref $val eq "ARRAY" ? "in" : "=";
        }

        if ($op eq "is null" || $op eq "is not null") {
            push @stmt, $col, $op;
        } elsif (!ref($val)) {
            if ($lc) {
                push @stmt, "lower($col)", $op, "lower(?)";
            } elsif ($uc) {
                push @stmt, "upper($col)", $op, "upper(?)";
            } else {
                push @stmt, $col, $op, "?";
            }

            push @bind, $val;
        } elsif (ref($val) eq "ARRAY" && $op =~ /not\s+in|in/i) {
            push @stmt, $col, $op, "(" . CORE::join(",", map {"?"} @$val) . ")";
            push @bind, @$val;
        } elsif (ref($val) eq "HASH") {
            my ($substmt, @subbind) = $self->select($val);
            push @stmt, $col, $op, "($substmt)";
            push @bind, @subbind;
        } else {
            die "unable to determine 'column op value' format";
        }
    }

    my $stmt = CORE::join(" ", @stmt);
    return wantarray ? ($stmt, @bind) : $stmt;
}

sub create {
    my $self = shift;
    my @stmt = ();

    foreach my $r (@_) {
        if (ref($r) eq "ARRAY") {
            push @stmt, scalar $self->quote(@$r);
        } else {
            push @stmt, $r;
        }
    }

    return CORE::join(" ", @stmt);
}

sub quote {
    my $self   = shift;
    my @string = ref($_[0]) eq "ARRAY" ? @{$_[0]} : @_;
    my $char   = $self->{quote_char};
    my $sep    = $self->{name_sep};
    my @return = ();

    # To use functions like to_char the column must
    # be hash ref. Example for to_char:
    #
    #     function => "to_char",
    #     column   => "time",
    #     pattern  => "YYYY-MM-DD HH24:MI:SS",
    #     alias    => "timestamp",
    #
    # This would generate the following statement for PostgreSQL:
    #
    #    to_char("time", 'YYYY-MM-DD HH24:MI:SS') AS "timestamp"
    #
    # DBI style with the pattern as bind variable:
    #
    #    to_char("time", ?) AS "timestamp"

    foreach my $str (@string) {
        if (ref($str) eq "HASH") {
            my $temp;

            # At the moment just to_char is supported
            if ($str->{function} eq "to_char") {
                $temp = "to_char(" . $self->quote($str->{column}) . ", ?)";
                push @{$self->{bind}}, $str->{pattern};
            } elsif ($str->{function} =~ /^(min|max|sum|avg|count)\z/) {
                $temp = "$1(" . $self->quote($str->{column}) . ")";
            }

            if ($str->{alias}) {
                $temp .= " as " . $self->quote($str->{alias});
            }

            push @return, $temp;
            next;
        }

        if ($str =~ /^(.+?)\Q$sep\E(.+?)\s[Aa][Ss]\s(.+)\z/) {
            push @return, $char.$1.$char.$sep.$char.$2.$char." AS ".$char.$3.$char;
        } elsif ($str =~ /^(.+?)\s+(.+)\z/) {
            push @return, $char.$1.$char." ".$char.$2.$char;
        } elsif ($str =~ /^(.+?)\Q$sep\E(.+)\z/) {
            push @return, $2 eq "*"
                ? $char.$1.$char.$sep.$2
                : $char.$1.$char.$sep.$char.$2.$char;
        } elsif ($str ne "*") {
            push @return, $char.$str.$char;
        } else {
            push @return, $str;
        }
    }

    return CORE::join(",", @return);
}

sub stmtquote {
    my ($self, $query, $to_quote) = @_;
    $to_quote ||= '"';
    my $quote = $self->{quote_char};
    $query =~ s/$to_quote/$quote/g;
    return $query;
}

sub search {
    my $self = shift;
    my $opts = @_ > 1 ? {@_} : shift;

    if (!defined $opts->{query} || !length $opts->{query} || $opts->{query} =~ /^[\s\t\r\n]+\z/) {
        $opts->{query} = 0;
    }

    $opts->{query} =~ s/[\r\n\t]+/ /g;

    my @items = split /\s+/, $opts->{query};
    my $expr = $opts->{start};
    my $maps = $opts->{maps} || { };
    my $table = $opts->{table};
    my (@cond, $del);

    if (defined $opts->{delimiter}) {
        $del = $opts->{delimiter};
    } else {
        $del = " ";
    }

    for (my $i = 0; $i <= $#items; $i++) {
        my $item = $items[$i];

        if (!$expr && ($item eq "AND" || $item eq "OR")) {
            $expr = lc($item);
            next;
        }

        my %cond = (op => "like");

        if ($item =~ /^(.+?):(.+)/ && exists $maps->{$1}) {
            my ($key, $value) = ($1, $2);

            # search:"foo bar baz"
            # search:'foo bar baz'
            $value =~ s/^(['"])(.*)\1\z/$2/;

            if ($value =~ s/^(['"])//) {
                my $end = $1;

                while (++$i <= $#items) {
                    $value .= " " . $items[$i];

                    if ($value =~ s/$end\z//) {
                        last;
                    }
                }
            }

            $cond{value} = "%". lc($value) ."%";
            $cond{lower} = 1;

            if (ref $maps->{$key} eq "HASH") {
                my $tmap = $maps->{$key};
                $cond{column} = $tmap->{column};

                if ($tmap->{table}) {
                    $cond{table} = $tmap->{table};
                }
            } elsif ($maps->{$key} =~ /^(.+?)\.(.+)/) {
                $cond{table} = $1;
                $cond{column} = $2;
            } else {
                $cond{column} = $maps->{$key};
            }
        } else {
            $cond{column} = {
                concat => $opts->{concat},
                delimiter => $del,
            };
            $cond{value} = "%". lc($item) ."%";
        }

        if (@cond) {
            push @cond, $expr ? $expr : "or", \%cond;
        } else {
            push @cond, \%cond;
        }

        $expr = "";
    }

    return wantarray ? @cond : \@cond;
}

1;
