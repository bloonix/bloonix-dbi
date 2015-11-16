=head1 NAME

Bloonix::DBI::Base - The base class.

=head1 SYNOPSIS

=head1 DESCRIPTION

This is the base database interface.

    use base qw(Bloonix::DBI::Base);

=head1 METHODS

=head2 C<new>

Create a new table accessor.

=head2 C<dbi>

Accessor to C<Bloonix::DBI>.

=head2 C<log>

Accessor to C<Bloonix::DBI::log>.

=head2 C<sql>

Accessor to C<Bloonix::SQL::Creator>.

=head2 C<schema>

Accessor to the base class.

=head2 C<validator>

Accessor to C<Bloonix::Validate>.

=head2 C<c>

Accessor to the web framework controller.

This controller is accessable if the controller was
passed to the new constructor of the model. As example
if your base model class is C<Bloonix::Model::Database>
then you can pass the controller and the database
configuration as follows:

    Bloonix::Model::Database->new($c, %config);

Where C<$c> is the object of your web framework controller.

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

package Bloonix::DBI::Base;

use strict;
use warnings;
use Bloonix::Validate;

sub new {
    my ($class, %opts) = @_;
    my $self  = bless \%opts, $class;
    my @class = split /::/, $class;
    my $table = pop @class;

    $table =~ s/([A-Z])/lc("_$1")/eg;
    $table =~ s/^_//;

    # This is used in CRUD.pm for all(), get(), find(), and search().
    $self->{table} = $table;
    $self->{columns} = "*";
    $self->{sequence} = "${table}_id_seq";
    $self->{unique_id_column} = "id";

    return $self;
}

sub dbi {
    my $self = shift;

    return $self->{dbi};
}

sub log {
    my $self = shift;

    return $self->{log};
}

sub sql {
    my $self = shift;

    return $self->{sql};
}

sub schema {
    my $self = shift;

    return $self->{schema};
}

sub validator {
    my $self = shift;

    if (!$self->{validator}) {
        $self->{validator} = Bloonix::Validate->new();
        $self->validator->schema($self->{schema});
    }

    return $self->{validator};
}

sub c {
    my $self = shift;

    return $self->{c};
}

1;
