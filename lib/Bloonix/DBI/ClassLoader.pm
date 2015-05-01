=head1 NAME

Bloonix::DBI::ClassLoader - The DBI class loader.

=head1 SYNOPSIS

=head1 DESCRIPTION

This is the Bloonix DBI class loader.

    use base qw(Bloonix::DBI::ClassLoader);

=head1 METHODS

=head2 C<new>

Create a new class loader.

=head2 C<load>

Returns the classes to load as a array.

=head2 C<connect>

Accessor to C<Bloonix::DBI->connect>.

=head2 C<reconnect>

Accessor to C<Bloonix::DBI->reconnect>.

=head2 C<disconnect>

Accessor to C<Bloonix::DBI->disconnect>.

=head2 C<begin_transaction>, C<rollback_transaction>, C<end_transaction>

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

package Bloonix::DBI::ClassLoader;

use strict;
use warnings;
use Bloonix::DBI;

use base qw(Bloonix::Accessor);
__PACKAGE__->mk_accessors(qw/dbi log sql/);

sub new {
    my ($class, $c, $config) = @_ == 2 ? ($_[0], "", $_[1]) : @_;

    my $dbi = Bloonix::DBI->new($config);
    my $log = $dbi->log;
    my $sql = $dbi->sql;
    my $self = bless { dbi => $dbi, log => $log, sql => $sql, c => $c }, $class;

    my %classes = $self->load;

    while (my ($accessor, $class) = each %classes) {
        $self->__include($accessor => $class);
    }

    $self->__init;

    return $self;
}

sub connect {
    my $self = shift;

    $self->dbi->connect;
}

sub reconnect {
    my $self = shift;

    $self->dbi->reconnect;
}

sub disconnect {
    my $self = shift;

    $self->dbi->disconnect;
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

sub __include {
    my ($self, $accessor, $schema) = @_;
    my $class = ref $self;
    my $dbi = $self->{dbi};
    my $log = $self->{log};
    my $sql = $self->{sql};
    my $c = $self->{c};

    eval "use $schema";

    if ($@) {
        die $@;
    }

    $class->mk_accessors($accessor);

    $self->{$accessor} = $schema->new(
        dbi => $dbi,
        log => $log,
        sql => $sql,
        c => $c,
        schema => $self
    );

    if ($self->{$accessor}->can("init")) {
        push @{ $self->{include} }, $accessor;
    }
}

sub __init {
    my $self = shift;

    if ($self->{include}) {
        foreach my $accessor (@{ $self->{include} }) {
            $self->{$accessor}->init;
        }
    }
}

1;
