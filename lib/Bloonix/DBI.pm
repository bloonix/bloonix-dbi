=head1 NAME

Bloonix::DBI - The database interface.

=head1 SYNOPSIS

    package MyApp::DBI;

    use base qw(Bloonix::DBI);

    my $dbi = MyApp::DBI->new(
        driver     => "Pg",
        host       => "127.0.0.1",
        port       => 5432,
        database   => "bloonix",
        user       => "bloonix",
        password   => "bloonix",
        quote_char => '"',
        sth_cache_enabled => 1,
    );

    $dbi->connect;
    $dbi->reconnect;

    # Transaction example

    my $old = $dbi->autocommit(0);

    eval {
        $dbi->begin;
        $dbi->lock($table);
        $dbi->do("insert into $table ...");
        $dbi->do("update into $table ...");
        $dbi->do("delete from $table ...");
        $dbi->commit;
        $dbi->unlock($table);
    };

    if ($@) {
        my $error = $@;
        eval { $dbi->rollback }; # might die
        $dbi->autocommit($old);
        die $error;
    }

    $dbi->autocommit($old);

=head1 DESCRIPTION

This is the main database interface of Bloonix. It handles and controls
the database connection for you. If the connection is lost then it tries
to reconnect. In addition it handles transactions for you and all this
database independent - assumed that the DBMS you want to use is supported.

At the moment PostgreSQL, MySQL and Oracle is supported.

=head1 METHODS

=head2 C<new>

Create a new C<Bloonix::DBI> object.

=head2 C<connect>

Connect to the database.

=head2 C<reconnect>

Re-connect to the database if the connection lost.

The connection is checked via ping.

=head2 C<disconnect>

Disconnect from database.

=head2 C<quote>

Returns the quote sign for tables, columns, indexes and so on.

=head2 C<validate>

Validate the configuration. This is automatically done if you
pass the configuration via C<new()>.

=head2 C<execute>

Prepare and execute a statement.

The statement handle is returned and also accessable via C<$dbi->sth>.

    $dbi->execute("select * from foo where bar = ?", @bind);

=head2 C<do>, C<doeval>

C<do> is very usable for insert, update and delete statements. It prepares
and execute a statement.

    $dbi->do("update foo set bar = ? where baz = ?", @bind);

C<doeval> is the same, the only difference is that the C<DBI> option
C<RaiseError> is set to 0.

=head2 C<count>

Prepare and execute a statement for count.

Note: "AS count" must be set!

=head2 C<min>, C<max>

Prepare and execute a statement for min and max.

    my $value = $dbi->max("select max(id) AS max from foo");

Note: "AS min" or "AS max" must be set!

If there is no min or max value because the table is empty then
a defined string is returned.

=head2 C<sequence>

Returns the nextval of a sequence.

    my $nextval = $dbi->sequence("sequence_name");

Note: not possible with MySQL!

A defined string is returned if the sequence couldn't fetched.

=head2 C<unique>

Prepare and execute a statement for unique rows.

    my $row = $dbi->unique("select * from foo where id = ?", $id);

The row is returned as a hash reference.

=head2 C<fetch>

Prepare and execute a statement to fetch rows.

    my $rows = $dbi->fetch("select * from foo where bar = ?", @bind);

The rows are returned as a AoH reference.

=head2 C<fetchhash>

This methods acts like C<fetch> but returns the data as a HoH reference.

    my $rows = $dbi->fetchhash("id", "select * from foo where bar = ?", @bind);

This would return each row by the column "id".

    $rows->{1000} = {
        id => 1000,
        user => "Jonny",
    };

=head2 C<fetchrow>

This methods acts like DBIs C<fetchrow_hashref> and returns the next row
or a resultset, the only difference is that the statement handle will
be finished before the last row is returned.

    $dbi->execute("select * from foo where id = ?", 100);

    while (my $row = $dbi->fetchrow) {
        print Dumper($row);
    }

This can be very useful if you want to pass the C<$dbi> object to a subsystem
like to the view of a MVC framework to fetch the resultset directly from the
view.

=head2 C<finish>

Close the statement handle.

=head2 C<execute_prepared>

Execute a prepared statements. The prepared statements will be cached.

    # first execution
    my $sth = $dbi->execute_prepared(foo => "select * from foo" => @bind);
    # second execution
    my $sth = $dbi->execute_prepared(foo => "select * from foo" => @bind);

First execution:

The statement is not cached yet. The statement will be prepared, cached
and then executed.

Second execution:

The sql-statement will be ignored because the statement is already prepared
and cached and is just executed with the bind variables.

Note:

The sql-statement must be passed each time C<execute_prepared> is called,
because if the database connection is lost then all cached statements will
be deleted. The statement will be cached again by the next execution.

You should know that it's not necessary to cache statements yourself,
only if you really want to do it. You can use the DBIs interal cache
mechanism, just pass the option "sth_cache_enabled => 1" by the call
of C<new()>.

=head2 C<begin>

Start a transaction. This is necessary for PostgreSQL and Oracle.

The method returns just true if the driver is set to "mysql".

=head2 C<lock>

Lock a table in exclusive mode.

=head2 C<unlock>

Unlock a table.

=head2 C<commit>

Commit a transaction.

=head2 C<rollback>

Rollback a transaction.

=head2 C<autocommit>

Turn on or off auto commit.

Please note that auto commit can only be switched if the database is connected!

=head2 C<transaction>

Pass a callback with arguments.

    sub mytr {
        my ($dbi, @args) = @_;
        $dbi->do("lock table foo");
        $dbi->do("lock table bar");
        $dbi->do("update foo set bar = ?", $args[0]);
        $dbi->do("update bar set foo = ?", $args[1]);
        $dbi->do("commit");
    }

    $dbi->transaction(\&mytr, @args);

Before the callback is called auto-commit will be turned of.
The callback will be executed in a eval context. If the callback
dies then a rollback is issued. After the callback was called
auto-commit is set back to the old value.

=head2 C<begin_transaction>, C<rollback_transaction>, C<end_transaction>

This methods is the easiest way to execute transactions.

    $dbi->begin_transaction;
        or die "unable to begin transaction";

    eval {
        ... do your stuff like insert/update/delete ...
    };

    if ($@) {
        $dbi->rollback_transactiom;
    } else {
        $dbi->end_transaction
            or die "unable to end transaction";
    }

=head2 C<query>

With the method C<query> it's possible to pass extended options. Before the
select statement is executed a C<count($field)> statement is executed
with a modfied version of the select statement and both result are returned.

    my ($count, $rows) = $dbi->query(
        # "*" is the default for count
        count => "*",
        offset => $offset,
        limit => $limit,
        query => $query,
        delimiter => $delimiter,
        concat => [@columns],
        select => [@select],
    );

The options C<query>, C<delimiter>, C<concat> and C<maps> are passed to the search method
of Bloonix::SQL::Creator. The option select is passed to the select method of
Bloonix::SQL::Creator. The options offset and limit are appended to the select
statement.

The select statement will be modified

=head2 C<is_dup>

Returns true if the error message of the last doeval() call contains the string "duplicate".

=head2 C<errstr>

Just returns the last error message of DBI.

=head2 C<driver>

Returns the driver name that is current in use.

=head1 PREREQUISITES

    DBI
    DBD::* (Your preferred DBD module)
    Log::Handler
    Params::Validate
    Bloonix::SQL::Creator

=head1 EXPORTS

No exports.

=head1 REPORT BUGS

Please report all bugs to <support(at)bloonix.de>.

=head1 AUTHOR

Jonny Schulz <support(at)bloonix.de>.

=head1 COPYRIGHT

Copyright (C) 2009-2014 by Jonny Schulz. All rights reserved.

=cut

package Bloonix::DBI;

use strict;
use warnings;
use DBI;
use Log::Handler;
use Params::Validate qw//;
use Bloonix::SQL::Creator;

use base qw/Bloonix::Accessor/;
__PACKAGE__->mk_accessors(qw/dbh sth log sql is_dup pid driver database/);

our $VERSION = "0.9";

sub new {
    my $class = shift;
    my $opts  = $class->validate(@_);
    my $self  = bless $opts, $class;

    $self->pid($$);
    $self->log(Log::Handler->new);
    $self->log->set_default_param(die_on_errors => 0);

    if ($self->{logger}) {
        $self->log->config(config => $self->{logger});
    }

    $self->{sql} = Bloonix::SQL::Creator->new(
        driver => $opts->{driver},
        name_sep => $opts->{name_sep},
        quote_char => $opts->{quote_char},
    );

    # Do not init myself
    if (__PACKAGE__ ne "Bloonix::DBI") {
        $self->init;
    }

    return $self;
}

sub connect {
    my $self = shift;

    $self->log->notice("connect to database");

    my $dbh = DBI->connect(@{$self->{cstr}});
    #$dbh->{pg_enable_utf8} = 1;

    $self->dbh($dbh);
    $self->sth(undef);

    return $dbh;
}

sub reconnect {
    my $self = shift;

    if ($self->pid != $$) {
        $self->disconnect;
        $self->pid($$);
    }

    if ($self->dbh) {
        my $ping = ();
        local $self->dbh->{RaiseError};
        local $self->dbh->{PrintError};

        if ($self->dbh->do("select 1")) {
            return $self->dbh;
        }

        $self->log->notice("connection to database lost - trying to reconnect");
    }

    return $self->connect;
}

sub disconnect {
    my $self = shift;
    my $dbh = delete $self->{dbh};

    if ($dbh) {
        $self->log->debug("disconnect from database");
        return $dbh->disconnect;
    }

    return 1;
}

sub count {
    my ($self, $stmt, @bind) = @_;

    my $sth = $self->execute($stmt, @bind)
        or return undef;

    my $row = $sth->fetchrow_hashref;

    $sth->finish
        or return undef;

    return $row ? $row->{count} : undef;
}

sub min {
    my ($self, $stmt, @bind) = @_;

    my $sth = $self->execute($stmt, @bind)
        or return undef;

    my $row = $sth->fetchrow_hashref;

    $sth->finish
        or return undef;

    return $row ? $row->{min} : undef;
}

sub max {
    my ($self, $stmt, @bind) = @_;

    my $sth = $self->execute($stmt, @bind)
        or return undef;

    my $row = $sth->fetchrow_hashref;

    $sth->finish
        or return undef;

    return $row ? $row->{max} : undef;
}

sub sequence {
    my ($self, $sequence) = @_;

    my $sth = $self->execute("select nextval('$sequence')")
        or return undef;

    my $row = $sth->fetchrow_hashref;

    $sth->finish
        or return undef;

    return $row->{nextval};
}

sub unique {
    my ($self, $stmt, @bind) = @_;

    my $sth = $self->execute($stmt, @bind)
        or return undef;

    my $row = $sth->fetchrow_hashref;

    $sth->finish
        or return undef;

    return $row;
}

sub fetch {
    my ($self, $stmt, @bind) = @_;

    my $sth = $self->execute($stmt, @bind)
        or return undef;

    my @rows = ();

    while (my $row = $sth->fetchrow_hashref) {
        push @rows, $row;
    }

    $sth->finish
        or return undef;

    return \@rows;
}

sub fetchhash {
    my ($self, $key, $stmt, @bind) = @_;

    my $sth = $self->execute($stmt, @bind)
        or return undef;

    my %rows = ();

    while (my $row = $sth->fetchrow_hashref) {
        $rows{$row->{$key}} = $row;
    }

    $sth->finish
        or return undef;

    return \%rows;
}

sub fetchrow {
    my $self = shift;

    my $row = $self->sth->fetchrow_hashref;

    if (!defined $row) {
        $self->sth->finish;
    }

    return $row;
}

sub do {
    my ($self, $stmt, @bind) = @_;
    my $sth;

    $self->log->info("sql execute $stmt:", join(",", map { "'$_'" } @bind));

    if ($self->{sth_cache_enabled}) {
        $sth = $self->dbh->prepare_cached($stmt)
            or return undef;
    } else {
        $sth = $self->dbh->prepare($stmt)
            or return undef;
    }

    $sth->execute(@bind)
        or return undef;

    $sth->finish
        or return undef;

    return 1;
}

sub doeval {
    my ($self, $stmt, @bind) = @_;
    my $sth;
    $self->is_dup(0);

    local $self->dbh->{RaiseError};

    $self->log->info("sql execute $stmt:", join(",", map { "'$_'" } @bind));

    if ($self->{sth_cache_enabled}) {
        $sth = $self->dbh->prepare_cached($stmt)
            or return undef;
    } else {
        $sth = $self->dbh->prepare($stmt)
            or return undef;
    }

    if (!$sth->execute(@bind)) {
        if ($sth->errstr =~ /duplicate/i) {
            $self->is_dup(1);
        }
        $self->log->warning($sth->errstr);
        return undef;
    }

    $sth->finish
        or return undef;

    return 1;
}

sub begin {
    my $self = shift;

    if ($self->{driver} eq "Pg" || $self->{driver} eq "Oracle") {
        return $self->do("begin");
    } elsif ($self->{driver} eq "mysql") {
        return $self->do("start transaction");
    }

    return 1;
}

sub lock {
    my ($self, $table) = @_;
    $table = $self->sql->quote($table);

    if ($self->{driver} eq "Pg") {
        return $self->do("lock table $table in exclusive mode");
    }

    if ($self->{driver} eq "mysql") {
        return $self->do("lock table $table write");
    }

    if ($self->{driver} eq "oracle") {
        return $self->do("lock table $table exclusive");
    }

    return 1;
}

sub unlock {
    my $self = shift;

    # PostgreSQL unlock the table after commit work.
    # Oracle unlock the table after commit.
    if ($self->{driver} eq "mysql") {
        return $self->do("unlock tables");
    }

    return 1;
}

sub rollback {
    my $self = shift;

    return $self->dbh->rollback;
}

sub commit {
    my $self = shift;

    return $self->dbh->commit;
}

sub autocommit {
    my ($self, $value) = @_;
    my $old = $self->dbh->{AutoCommit};

    if (@_ == 1) {
        # If no value is passed then the current
        # setting of AutoCommit is returned
        return $old;
    }

    $self->dbh->{AutoCommit} = $value;
    return $old;
}

sub begin_transaction {
    my $self = shift;

    eval {
        $self->{__old} = $self->autocommit;
        $self->autocommit(0);
        $self->begin;
    };

    if ($@) {
        eval { $self->autocommit($self->{__old}) };
        $self->log->error($@);
        return undef;
    }

    return 1;
}

sub rollback_transaction {
    my $self = shift;

    eval { $self->rollback };

    if ($@) {
        eval { $self->autocommit($self->{__old}) };
        $self->log->error($@);
        return undef;
    }

    eval { $self->autocommit($self->{__old}) };
    return 1;
}

sub end_transaction {
    my $self = shift;

    eval { $self->commit };

    if ($@) {
        $self->log->error($@);
        $self->rollback_transaction;
        return undef;
    }

    eval { $self->autocommit($self->{__old}) };
    return 1;
}

sub transaction {
    my ($self, $callback, @args) = @_;
    my $old = $self->autocommit;
    my $ret = undef;

    # Set AutoCommit to off!
    $self->autocommit(0);

    # begin and commit must be executed in the callback,
    # because it's possible that there are more then
    # one commit points
    eval { $ret = &$callback(@args) };

    if ($@) {
        eval { $self->rollback };
    }

    $self->autocommit($old);
    return $ret;
}

sub execute {
    my ($self, $stmt, @bind) = @_;
    my (@rows, $sth);

    # DBI dies by default but we want a nicer error message
    # with the complete statement and the bind variables.
    eval {
        $self->log->info("sql prepare $stmt");

        if ($self->{sth_cache_enabled}) {
            $sth = $self->dbh->prepare_cached($stmt);
        } else {
            $sth = $self->dbh->prepare($stmt);
        }

        $self->log->info("sql execute $stmt", join(",", map { "'$_'" } @bind));
        $sth->execute(@bind);
    };

    if ($@) {
        if ($self->dbh) {
            die join(',', $stmt, @bind, $self->dbh->errstr, $@);
        } else {
            die join(',', $stmt, @bind, $@);
        }
    }

    $self->sth($sth);
    return $sth;
}

sub finish {
    my $self = shift;
    my $sth  = $self->{sth};

    $self->{sth} = undef;

    return $sth->finish;
}

sub query {
    my $self = shift;
    my $opts = @_ == 1 ? shift : {@_};

    $self->log->info("start dbi->query");
    my @count = (count => $opts->{count} ? $opts->{count} : "*");
    my @stmt = @{$opts->{select}};
    my $hit_condition = 0;

    if (defined $opts->{query}) {
        if ($opts->{query} =~ /\S/) {
            if (!$opts->{concat} || ref $opts->{concat} ne "ARRAY") {
                die "no concat defined for query";
            }
        } else {
            $opts->{query} = undef;
        }
    }

    for (my $i=0; $i < @stmt; $i+=2) {
        my ($key, $val) = ($stmt[$i], $stmt[$i+1]);

        if ($key eq "table") {
            if (ref $val eq "ARRAY") {
                push @count, table => $val->[0];
            } else {
                push @count, table => $val;
            }
        } elsif ($key !~ /^(offset|limit|order|column)\z/) {
            push @count, $key, $val;
        }

        if ($key eq "condition" && defined $opts->{query}) {
            push @$val, (
                pre => [
                    and => $self->sql->search(
                        maps => $opts->{maps},
                        concat => $opts->{concat},
                        query => $opts->{query},
                        delimiter => $opts->{delimiter},
                    )
                ]
            );

            $hit_condition = 1;
        }
    }

    if ($hit_condition == 0 && defined $opts->{query}) {
        push @stmt, (
            condition => [
                where => $self->sql->search(
                    maps => $opts->{maps},
                    concat => $opts->{concat},
                    query => $opts->{query},
                    delimiter => $opts->{delimiter},
                )
            ]
        );
    }

    if (defined $opts->{offset}) {
        if ($opts->{offset} !~ /^\d+\z/) {
            $opts->{offset} = 0;
        }
        push @stmt, offset => $opts->{offset};
    }

    if (defined $opts->{limit}) {
        if ($opts->{limit} !~ /^\d+\z/) {
            $opts->{limit} = 20;
        }
        push @stmt, limit => $opts->{limit};
    }

    my $count = $self->count($self->sql->select(@count));
    my $data = $self->fetch($self->sql->select(@stmt));
    $self->log->info("end dbi->query");

    return ($count, $data);
}

sub last_insert_id {
    my $self = shift;

    return $self->dbh->last_insert_id(@_);
}

sub errstr {
    my $self = shift;

    return $self->dbh->errstr;
}

sub validate {
    my $class = shift;

    my %options = Params::Validate::validate(@_, {
        driver => {
            type  => Params::Validate::SCALAR,
            regex => qr/^(?:MySQL|mysql|Pg|PostgreSQL|Oracle|oracle)\z/,
        },
        database => {
            type => Params::Validate::SCALAR,
        },
        user => {
            type => Params::Validate::SCALAR,
        },
        password => {
            type => Params::Validate::SCALAR,
            default => "",
        },
        host => {
            type => Params::Validate::SCALAR,
            default => "127.0.0.1",
        },
        port => {
            type => Params::Validate::SCALAR,
            regex => qr/^\d+\z/,
            optional => 1,
        },
        logger => {
            type => Params::Validate::HASHREF,
            optional => 1,
        },
        # Now it follows possible, but undocumented parameters!!!
        # The reason is that the following parameter should only be
        # set by very experienced users!
        db_params => {
            type => Params::Validate::HASHREF,
            default => {
                PrintWarn  => 0,
                PrintError => 0,
                RaiseError => 1,
                AutoCommit => 1,
                ShowErrorStatement => 1,
            },
        },
        quote_char => {
            type => Params::Validate::SCALAR,
            regex => qr/^.\z/,
            default => "",
        },
        name_sep => {
            type => Params::Validate::SCALAR,
            regex => qr/^.\z/,
            default => ".",
        },
        sth_cache_enabled => {
            type => Params::Validate::SCALAR,
            regex => qr/^(?:yes|no|0|1)\z/,
            default => 0,
        },
    });

    if ($options{driver} =~ /^m/i) {
        $options{driver} = "mysql";
    } elsif ($options{driver} =~ /^p/i) {
        $options{driver} = "Pg";
    } elsif ($options{driver} =~ /^o/i) {
        $options{driver} = "Oracle";
    }

    for my $key (qw/sth_cache_enabled/) {
        if ($options{$key} eq "no") {
            $options{$key} = 0;
        }
    }

    if ($options{driver} eq "Pg") {
        $options{quote_char} = '"';
        $options{port} //= 5432;
        #$options{db_params}{mysql_enable_utf8} = 1;
    } elsif ($options{driver} eq "Oracle") {
        $options{quote_char} = "'";
        $options{port} //= 1521;
    } elsif ($options{driver} eq "mysql") {
        $options{quote_char} = '`';
        $options{port} //= 3306;
        #$options{db_params}{pg_enable_utf8} = 1;
    }

    # build the connect string
    my @cstr = ("dbi:$options{driver}:database=$options{database}");

    if ($options{host}) {
        $cstr[0] .= ";host=$options{host}";

        if ($options{port}) {
            $cstr[0] .= ";port=$options{port}";
        }
    }

    if ($options{user}) {
        $cstr[1] = $options{user};
        if ($options{port}) {
            $cstr[2] = $options{password};
        }
    }

    $options{db_params}{PrintWarn}  //= 0;
    $options{db_params}{PrintError} //= 0;
    $options{db_params}{AutoCommit} //= 1;
    $options{db_params}{RaiseError} //= 1;
    $options{db_params}{ShowErrorStatement} //= 1;
    $cstr[3] = $options{db_params};
    $options{cstr} = \@cstr;

    return \%options;
}

1;
