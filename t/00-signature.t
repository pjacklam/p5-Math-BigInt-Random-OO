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

print "1..1\n";

# The following is from the Module::Signature manual page.

if (! $ENV{TEST_SIGNATURE}) {
    print "ok 1 # skip Set the environment variable",
      " TEST_SIGNATURE to enable this test\n";
}
elsif (! -s 'SIGNATURE') {
    print "ok 1 # skip No signature file found\n";
}
elsif (! eval { require Module::Signature; 1 }) {
    print "ok 1 # skip ",
      "Next time around, consider install Module::Signature, ",
        "so you can verify the integrity of this distribution.\n";
}
elsif (! eval { require Socket; Socket::inet_aton('pgp.mit.edu') }) {
    print "ok 1 # skip ",
      "Cannot connect to the keyserver\n";
}
else {
    (Module::Signature::verify() == Module::Signature::SIGNATURE_OK())
      or print "not ";
    print "ok 1 # Valid signature\n";
}

# Emacs Local Variables:
# Emacs coding: us-ascii-unix
# Emacs mode: perl
# Emacs End:
