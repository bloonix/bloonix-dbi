=head1 NAME

Bloonix::DBI::UniqueStatus - The status of CRUD operations.

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 new, is_dup, has_failed, success, status, data

=head1 AUTHOR

Jonny Schulz <support(at)bloonix.de>.

=head1 COPYRIGHT

Copyright (C) 2009-2014 by Jonny Schulz. All rights reserved.

=cut

package Bloonix::DBI::UniqueStatus;

use strict;
use warnings;
use base qw(Bloonix::Accessor);

__PACKAGE__->mk_accessors(qw/status data/);

sub new {
    my ($class, %result) = @_;

    return bless \%result, $class;
}

sub is_dup {
    my $self = shift;

    return $self->status eq "dup";
}

sub has_failed {
    my $self = shift;

    return $self->status ne "ok";
}

sub success {
    my $self = shift;

    return $self->status eq "ok";
}

1;
