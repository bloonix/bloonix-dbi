=head1 NAME

Bloonix::DBI::CRUD - The base CRUD class.

=head1 SYNOPSIS

    use base qw(Bloonix::DBI::CRUD);

=head1 DESCRIPTION

This module provides different default CRUD actions. CRUD means

    C create
    R select (read)
    U update
    D delete

=head1 METHODS

=head2 C<all>

    select * from table

    $schema->all();

=head2 C<get>

    select * from table where id = $id

    $schema->get($id);

    select foo, bar, baz from table where id = $id

    $schema->get($id, qw(foo bar baz));

=head2 C<find>

C<find> is like get and search for a unique row but allows
an extended statement.

    select * from table where foo = 1 and bar = 2

    $schema->find(
        condition => [
            foo => 1,
            bar => 2,
        ]
    );

It's possible to pass option C<column> to C<find()>:

    select beer, chips from table where foo = 1 and bar = 2

    $schema->find(
        column => [
            qw(chips beer)
        ],
        condition => [
            foo => 1,
            bar => 2,
        ]
    );

=head2 C<search>

    select * from table where foo = 1 and bar = 2

    $schema->search(
        condition => [
            foo => 1,
            bar => 2,
        ],
    );

    select * from table where foo = 1 and bar != 2
    order by foo asc, bar desc, baz desc

    $schema->search(
        condition => [
            foo => { -eq => 1 },
            bar => { -ne => 2 },
        ],
        order => [
            asc => "foo",
            desc => [ qw(bar baz) ],
        ],
    );

=head2 C<create>

    insert into table (foo, bar) values (1, 2);

    $schema->create(
        foo => 1,
        bar => 2,
    );

=head2 C<create_and_get>

This is the same like C<create> but returns the row that was inserted.

=head2 Unique columns

It's possible to check unique constraints automatically before a new row
is inserted or a existing row will be updated. The way to do this is very
simple.

In the first step the unique columns must be set with C<set_unique()>.

As example we use a table named "user". This table has two columns which
are unique in combination.

    $schema->set_unique(and => [ "username", "company" ]);

That means that a username+company is unique in combination. If a user
names "foo" workes for the company "bar", then this user can only exists
once in the table.

Ok, if you want to insert a new row into the table, then use the method
C<create_unique()>.

    $schema->create_unique({
        username => "foo",
        company => "bar",
        prename "Foo",
        name => "Baz"
    });

Before the new row is inserted, it is checked if a user with the name "foo"
and company "bar" already exists. If the user does not exists then the row
will be inserted, otherwise an error will be returned.

The same thing happends with updates on an existing row.

    $schema->update_unique(1000 => {
        username => "foohoo",
        company => "bahaar"
    });

The method C<update_unique()> expects the unique row id (primary key) as first
and the data to update as second argument. Like the C<create_unique()> method
the C<update_unique()> method checks at first if a row with the data already
exists and returns an error or update the row.

=over 4

=item set_unique

    $schema->set_unique(
        and => [qw(column_a column_b)],
        or => [qw(column_c column_d)]
    );

=item has_unique

    $true_or_false = $schema->has_unique();

=item check_unique

    $schema->check_unique(
        data => $data,
        skip => $id
    );

=item create_unique

    $schema->create_unique(
        data => $data
    );

=item update_unique

    $schema->update_unique(
        data => $data,
        skip => $id
    );

=back

=head2 C<validated>

It's possible to validate data before inserts or updates.

    my ($result, $success) = $schema->validated(create => \%data);
    my ($result, $success) = $schema->validated(update => \%data);

If the validation fails then only the result of C<Bloonix::Validator>
is returned.

=head2 C<update>

The method C<update> expects a condition to update table rows. If you
want to update all rows of a table then use the method C<do> of
C<Bloonix::DBI>.

    update table set foo = 10, bar = 20 where foo = 1 and bar = 2

    $schema->update(
        data => {
            foo => 10,
            bar => 20,
        },
        condition => [
            foo => 1,
            bar => 2,
        ],
    );

Or quiete simple

    update table set foo = 10, bar = 20 where id = 10

    $schema->update(
        10 => {
            foo => 10,
            bar => 20,
        }
    );

Or

    $schema->update(
        10,
        foo => 10,
        bar => 20,
    );

Note that this only works if the first key is a number!

=head2 C<last_insert_row>

This method returns the last row that was inserted with
C<create_and_get>. If just C<create> was called then the
hash is returned that was passed to it.

=head2 C<delete>

    delete from table where foo = 1 and bar = 2

    $schema->delete(
        foo => 1,
        bar => 2,
    );

=head2 C<count>

    select count(id) from table

    $schema->count("id")

=head2 C<min>

    select min(salary) from table

    $schema->min("salary");

=head2 C<max>

    select max(salary) from table

    $schema->max("salary");

=head2 C<sequence>

Get the next sequence number of the schema table.

This is only possible on some DBMS.

=head2 C<action>

With this parameter it's possible to create actions.

Two possible actions are available:

    pre_create
    pre_update

Both actions expects a subroutine or a hash reference as value.
The code is execute every time C<create()> or C<update()> is called.

This is really useful if you want to modify the data that are inserted
or updated. If you pass a hash reference, then the key-value pairs will
be written to the hash that is passed to C<create> or C<update>.

Example:

    $schema->action(
        pre_create => { created => time }
    );

    $schema->create(username => "Larry");

Now before the user with username "Larry" will be inserted, the C<pre_create>
action will be processes and the key-value pair "created => time" will be added.

=head2 has_unique_id

Set if the table has a unique id field with auto increment.

Default: 1 (yes)

=head2 begin_transaction, rollback_transaction, end_transaction

This are just accessors to DBI->begin_transaction and DBI->end_transaction.

=head1 EXAMPLES

=head1 PREREQUISITES

=head1 EXPORTS

No exports.

=head1 REPORT BUGS

Please report all bugs to <support(at)bloonix.de>.

=head1 AUTHOR

Jonny Schulz <support(at)bloonix.de>.

=head1 COPYRIGHT

Copyright (C) 2009-2014 by Jonny Schulz. All rights reserved.

=cut

package Bloonix::DBI::CRUD;

use strict;
use warnings;
use Bloonix::Validator;
use Bloonix::DBI::UniqueStatus;

sub get {
    my $self = shift;
    my $id = shift;
    my $columns;

    if (@_) {
        $columns = ref($_[0]) eq "ARRAY" ? shift : [@_];
    } else {
        $columns = $self->{columns};
    }

    return $self->find(
        column => $columns,
        condition => [ $self->{unique_id_column} => $id ]
    );
}

sub find {
    my ($self, %opts) = @_;

    $opts{table} = $self->{table};
    $opts{column} //= $self->{columns};

    my ($stmt, @bind) = $self->sql->select(%opts);

    return $self->dbi->unique($stmt, @bind);
}

sub all {
    my ($self, %opts) = @_;

    $opts{table} = $self->{table};
    $opts{column} //= $self->{columns};

    my $stmt = $self->sql->select(%opts);

    return $self->dbi->fetch($stmt);
}

sub search {
    my ($self, %opts) = @_;

    my $fetch_by = delete $opts{fetch_by};
    $opts{table} = $self->{table};
    $opts{column} //= $self->{columns};

    my ($stmt, @bind) = $self->sql->select(%opts);

    if ($fetch_by) {
        return $self->dbi->fetchhash($fetch_by, $stmt, @bind);
    }

    return $self->dbi->fetch($stmt, @bind);
}

sub validated {
    my $self = shift;
    my $action = shift;

    my $data = @_ > 1 ? {@_} : shift;
    my $result = $action =~ /^create/
        ? $self->validator->validate($data, force_defaults => 1)
        : $self->validator->validate($data, ignore_missing => 1);

    if ($result->has_failed) {
        return $result;
    }

    return ($result, $self->$action($result->data));
}

sub __create {
    my ($self, %opts) = @_;
    my $data = $opts{data};
    my $unique_id_column = $self->{unique_id_column} // "id";

    $self->{last_insert_row} = undef;

    if ($opts{gen_id}) {
        $data->{$unique_id_column} //= $self->sequence;
    }

    if ($self->{pre_create}) {
        &{$self->{pre_create}}($self, $data);
    }

    my ($stmt, @bind) = $self->sql->insert(
        table => $self->{table},
        data => $data,
    );

    $self->dbi->doeval($stmt, @bind)
        or return undef;

    if ($opts{gen_id}) {
        $self->{last_insert_row} = $self->get($data->{$unique_id_column});
    } else {
        # HOAH! Careful! If the table has a auto-increment column
        # then this column will not be returned! If the table has
        # a auto-increment column use create_and_get instead!!!
        $self->{last_insert_row} = $data;
    }

    return $self->{last_insert_row};
}

sub create {
    my $self = shift;
    my $data = @_ > 1 ? {@_} : shift;

    return $self->__create(data => $data);
}

sub create_and_get {
    my $self = shift;
    my $data = @_ > 1 ? {@_} : shift;

    return $self->__create(data => $data, gen_id => 1);
}

sub create_unique {
    my $self = shift;
    my $data = @_ > 1 ? {@_} : shift;
    my $ret;

    my $old = $self->dbi->autocommit(0);
    $self->dbi->begin;
    $self->dbi->lock($self->{table});

    my $dups = $self->check_unique(data => $data);

    if ($dups) {
        $ret = Bloonix::DBI::UniqueStatus->new(status => "dup", data => $dups);
    } elsif (!$self->has_unique_id && $self->create($data)) {
        $ret = Bloonix::DBI::UniqueStatus->new(status => "ok", data => $data);
    } elsif ($self->has_unique_id && $self->create_and_get($data)) {
        $ret = Bloonix::DBI::UniqueStatus->new(status => "ok", data => $self->{last_insert_row});
    } else {
        $ret = Bloonix::DBI::UniqueStatus->new(status => "err");
    }

    $self->dbi->unlock($self->{table});
    $self->dbi->commit;
    $self->dbi->autocommit($old);

    return $ret;
}

sub update_unique {
    my ($self, $id, $data) = @_;
    my $ret;

    my $old = $self->dbi->autocommit(0);
    $self->dbi->begin;
    $self->dbi->lock($self->{table});

    my $dups = $self->check_unique(
        data => $data,
        skip => $id
    );

    if ($dups) {
        $ret = Bloonix::DBI::UniqueStatus->new(status => "dup", data => $dups);
    } elsif ($self->update($id => $data)) {
        $ret = Bloonix::DBI::UniqueStatus->new(status => "ok", data => $self->get($id));
    } else {
        $ret = Bloonix::DBI::UniqueStatus->new(status => "err");
    }

    $self->dbi->unlock($self->{table});
    $self->dbi->commit;
    $self->dbi->autocommit($old);

    return $ret;
}

sub set_unique {
    my ($self, @opts) = @_;

    $self->{check_unique} = \@opts;
}

sub has_unique {
    my $self = shift;

    return $self->{check_unique} ? 1 : 0;
}

sub check_unique {
    my ($self, %opts) = @_;
    my $data = $opts{data};
    my $check = $self->{check_unique}
        or return 0;

    my (@condition, @dups, %columns, $object);

    for (my $i=0; $i < @$check; $i++) {
        my $rel = $check->[$i];
        my $cols = $check->[++$i];
        my (@cond);

        foreach my $col (@$cols) {
            $columns{$col}++;

            if (!exists $data->{$col} && $rel eq "and") {
                # UNIQUE(foo,bar,baz);
                # To check the uniquness of multiple columns it's
                # necessary that all column has a value! If a value
                # is not set and the skip-id is set then the object
                # is requested first.

                if ($opts{skip} && !$object) {
                    $object = $self->get($opts{skip})
                        or die "object does not exists - maybe a race condition and the object were deleted";
                }
            }

            if (exists $data->{$col} || exists $object->{$col}) {
                if (@cond) {
                    push @cond, $rel;
                }
                push @cond, {
                    column => $col,
                    value => exists $data->{$col}
                        ? $data->{$col}
                        : $object->{$col}
                        # $data->{$col} must be untouched, for this reason
                        # the data cannot be copied to $data->{$col} and
                        # $object->{$col} is checked
                };
            }
        }

        if (@cond) {
            if (@condition) {
                push @condition, pre => [ or => @cond ];
            } else {
                push @condition, pre => [ and => @cond ];
            }
        }
    }

    if (@condition) {
        if ($opts{skip}) {
            @condition = (
                "where" => {
                    column => $self->{unique_id_column},
                    op => "!=",
                    value => $opts{skip}
                },
                pre => [@condition]
            );
        } else {
            $condition[1][0] = "where";
        }

        my ($stmt, @bind) = $self->sql->select(
            table => $self->{table},
            column => [ keys %columns ],
            condition => \@condition
        );

        my $row = $self->dbi->unique($stmt, @bind);

        # dups found or not
        if ($row) {
            foreach my $col (keys %columns) {
                if ($row->{$col} eq $data->{$col}) {
                    push @dups, $col;
                }
            }
        }
    }

    return @dups ? \@dups : 0;
}

sub has_unique_id {
    my $self = shift;

    if (@_) {
        $self->{has_unique_id} = shift;
    }

    if (!defined $self->{has_unique_id}) {
        return 1;
    }

    return $self->{has_unique_id};
}

sub last_insert_row {
    my $self = shift;

    return $self->{last_insert_row};
}

sub update {
    my $self = shift;
    my (%opts, $data, $condition, $result);

    if ($_[0] =~ /^\d+\z/) {
        $condition = [ $self->{unique_id_column} => shift ];
        $data = @_ > 1 ? {@_} : shift;
    } else {
        %opts = @_;
        $condition = $opts{condition};
        $data = $opts{data};
    }

    if ($self->{pre_update}) {
        &{$self->{pre_update}}($self, $data);
    }

    my ($stmt, @bind) = $self->sql->update(
        table  => $self->{table},
        column => $data,
        condition => $condition,
    );

    return $self->dbi->doeval($stmt, @bind);
}

sub delete {
    my $self = shift;
    my $cond = @_ > 1 ? [@_] : shift;

    if (!ref($cond)) {
        $cond = [ $self->{unique_id_column} => $cond ];
    }

    my ($stmt, @bind) = $self->sql->delete(
        table => $self->{table},
        condition => $cond,
    );

    return $self->dbi->doeval($stmt, @bind);
}

sub min {
    my ($self, $column) = @_;

    my $stmt = $self->sql->select(
        table => $self->{table},
        min   => $column,
    );

    my $row = $self->dbi->unique($stmt);

    return $row ? $row->{min} : undef;
}

sub max {
    my ($self, $column) = @_;

    my $stmt = $self->sql->select(
        table => $self->{table},
        max   => $column,
    );

    my $row = $self->dbi->unique($stmt);

    return $row ? $row->{max} : undef;
}

sub count {
    my ($self, $column, %opts) = @_;

    my @stmt = (
        table => $self->{table},
        count => $column,
    );

    if ($opts{condition}) {
        push @stmt, condition => $opts{condition};
    }

    my ($stmt, @bind) = $self->sql->select(@stmt);

    return $self->dbi->count($stmt, @bind);
}

sub sequence {
    my ($self, $sequence) = @_;

    $sequence ||= $self->{sequence};

    my $row = $self->dbi->unique("select nextval('$sequence')");

    if ($row && $row->{nextval}) {
        return $row->{nextval};
    }

    return 0;
}

sub action {
    my ($self, %actions) = @_;

    foreach my $action (keys %actions) {
        if ($action !~ /^pre_(create|update)\z/) {
            die "invalid action '$action'";
        }

        my $code = $actions{$action};

        if (ref $code ne "CODE") {
            $code = sub {
                my ($self, $data) = @_;

                foreach my $key (keys %$action) {
                    $data->{$key} = $action->{$key};
                }
            };
        }

        $self->{$action} = $code;
    }
}

sub begin_transaction {
    my $self = shift;

    return $self->dbi->begin_transaction(@_);
}

sub rollback_transaction {
    my $self = shift;

    return $self->dbi->rollback_transaction(@_);
}

sub end_transaction {
    my $self = shift;

    return $self->dbi->end_transaction(@_);
}

1;
