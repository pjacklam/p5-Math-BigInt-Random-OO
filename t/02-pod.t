#!/usr/bin/perl
#
# Author:      Peter J. Acklam
# Time-stamp:  2010-01-24 21:34:34 +01:00
# E-mail:      pjacklam@cpan.org
# URL:         http://home.online.no/~pjacklam

#########################

use 5.008;              # for the 'utf8' and 'warnings' pragmas
use strict;             # restrict unsafe constructs
use warnings;           # control optional warnings
#use utf8;               # enable/disable UTF-8 (or UTF-EBCDIC) in source code

#########################

use Test::More;

# Ensure a recent version of Test::Pod

my $min_tp = 1.22;
eval "use Test::Pod $min_tp";
plan skip_all => "Test::Pod $min_tp required for testing POD" if $@;

all_pod_files_ok();

# Emacs Local Variables:
# Emacs coding: us-ascii-unix
# Emacs mode: perl
# Emacs End:
