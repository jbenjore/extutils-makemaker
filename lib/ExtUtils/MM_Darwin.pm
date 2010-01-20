package ExtUtils::MM_Darwin;

use strict;

BEGIN {
    require ExtUtils::MM_Unix;
    our @ISA = qw( ExtUtils::MM_Unix );
}

our $VERSION = '6.56';


=head1 NAME

ExtUtils::MM_Darwin - special behaviors for OS X

=head1 SYNOPSIS

    For internal MakeMaker use only

=head1 DESCRIPTION

See L<ExtUtils::MM_Unix> for L<ExtUtils::MM_Any> for documention on the
methods overridden here.

=head2 Overriden Methods

=head3 _tar_names

=over

=item *

Turn off Apple tar's tendency to copy resource forks as "._foo" files.

=item *

Use GNU tar because BSD tar (validly) adds a bunch of metadata GNU tar
can't handle.

=cut

sub _tar_names {
    my ( $self ) = @_;
    
    # Thank you, Apple, for breaking tar and then breaking the work
    # around.  10.4 wants COPY_EXTENDED_ATTRIBUTES_DISABLE while 10.5
    # wants COPYFILE_DISABLE.  I'm not going to push my luck and
    # instead just set both. In both cases, what's going on is linking
    # in copyfile(3) and checking copyfile.h for something like:
    #
    #    #define COPYFILE_DISABLE_VAR "COPYFILE_DISABLE"
    #
    # It's not documented. Bummer for us, I guess.
    #
    # Thank you, also for using BSD tar. The tar format as defined by
    # POSIX lets us add some additional header information. BSD tar
    # sometimes adds headers that GNU tar versions 1.19 or earlier
    # can't handle that. As I'm writing this, it's pretty common for
    # the Linux systems we've surveyed to have something like GNU tar
    # 1.16.
    #
    # The following are the added headers. If you see errors from
    # people about not being able to handle these, the input is
    # probably from BSD tar and their tar might be GNU. The fixes are
    # to a) upgrade their tar, b) re-do the tarball using a tar that
    # GNU tar can handle. BSD is "correct" in this case.
    #
    #   LIBARCHIVE.creationtime
    #   SCHILY.acl.access
    #   SCHILY.acl.default
    #   SCHILY.dev
    #   SCHILY.devmajor
    #   SCHILY.devminor
    #   SCHILY.fflags
    #   SCHILY.ino
    #   SCHILY.nlink
    #   SCHILY.nlinks
    #   SCHILY.realsize
    #
    # Some cases that seem to provoke this include a user id or group
    # id that is greater than octal 0777777 or using non- 7-bit ASCII
    # filenames. I'm not sure exactly how uncommon it is to have a
    # user id greater than octal 0777777. I happen to have suffered
    # this on a machine where my user account was provisioned by
    # Active Directory.
    #
    return(
        'COPY_EXTENDED_ATTRIBUTES_DISABLE=1 COPYFILE_DISABLE=1 gnutar',
        'COPY_EXTENDED_ATTRIBUTES_DISABLE=1 COPYFILE_DISABLE=1 tar',
        'COPY_EXTENDED_ATTRIBUTES_DISABLE=1 COPYFILE_DISABLE=1 bsdtar',
    );
}

1;
