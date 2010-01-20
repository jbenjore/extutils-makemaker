#!/usr/bin/perl -w

# Test MM->_find_tar()

BEGIN {
    chdir 't' if -d 't';
}

use strict;
use warnings;
use lib './lib';
use ExtUtils::MakeMaker;
use Test::More tests => 3;

my $o = MM->new;
my $verbose = 0;
my $tar = $o->_find_tar( $verbose );
unlike( $tar, qr/bsdtar/, "Didn't select bsdtar" );

my $help = `$tar --help`;
unlike( $help, qr/^tar\(bsdtar\)/, "Not BSD tar masquerading as regular tar" );
unlike( $help, qr/^bsdtar/, "Not BSD just being itself" );
