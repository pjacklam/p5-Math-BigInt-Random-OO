#!/usr/bin/perl
#
# Author:      Peter J. Acklam
# Time-stamp:  2010-01-31 12:39:41 +01:00
# E-mail:      pjacklam@cpan.org
# URL:         http://home.online.no/~pjacklam

########################

use 5.008;              # for the 'utf8' and 'warnings' pragmas
use strict;             # restrict unsafe constructs
use warnings;           # control optional warnings
#use utf8;               # enable/disable UTF-8 (or UTF-EBCDIC) in source code

########################

local $| = 1;

#BEGIN {
#    chdir 't' if -d 't';
#    unshift @INC, '../lib';     # for running manually
#}

use Math::BigInt::Random::OO;

use Math::BigInt;
use Math::BigFloat;

use Test::More tests => 5;

my $class = 'Math::BigInt::Random::OO';

########################

{
    print <<"EOF";
#
# \$x = $class -> new(length => 4) -> generate();
#
EOF

    my $x = $class -> new(length => 4) -> generate();

    ok(defined($x) and
       ref($x) eq 'Math::BigInt' and
       length($x) == 4);
}

########################

{
    my $len  = 37;
    my $num  = 10;

    print <<"EOF";
#
# \@x = $class -> new(length => $len) -> generate($num);
#
EOF

    my @x = $class -> new(length => $len) -> generate($num);

    subtest 'each element in output array' => sub {
        plan tests => 1 + 2 * $num;
        ok(@x == $num, 'Number of elements in output array is correct');
        for my $x (@x) {
            isa_ok($x, 'Math::BigInt');
            my $data = sprintf '%s', $x;
            my $outlen = length $data;
            ok($outlen == $len, "The length $outlen, expected is $len");
        }
    };
}

########################

{
    my $len  = 37;
    my $base =  2;
    my $num  = 10;

    print <<"EOF";
#
# \@x = $class -> new(length => $len, base => $base) -> generate($num);
#
EOF

    my @x = $class -> new(length => $len, base => $base) -> generate($num);

    subtest 'each element in output array' => sub {
        plan tests => 1 + 2 * $num;
        ok(@x == $num, 'Number of elements in output array is correct');
        for my $x (@x) {
            isa_ok($x, 'Math::BigInt');

            my $data = sprintf '%b', $x;
            $data =~ s/^0b0*(\d)/$1/;
            my $outlen = length $data;
            ok($outlen == $len, "The length $outlen, expected is $len");
        }
    };
}

########################

{
    my $len  = 37;
    my $base =  8;
    my $num  = 10;

    print <<"EOF";
#
# \@x = $class -> new(length => $len, base => $base) -> generate($num);
#
EOF

    my @x = $class -> new(length => $len, base => $base) -> generate($num);

    subtest 'each element in output array' => sub {
        plan tests => 1 + 2 * $num;
        ok(@x == $num, 'Number of elements in output array is correct');
        for my $x (@x) {
            isa_ok($x, 'Math::BigInt');
            my $data = $x -> copy() -> as_oct();
            $data =~ s/^0*(\d)/$1/;
            my $outlen = length $data;
            ok($outlen == $len, "The length $outlen, expected is $len");
        }
    };
}

########################

{
    my $len  = 37;
    my $base = 16;
    my $num  = 10;

    print <<"EOF";
#
# \@x = $class -> new(length => $len, base => $base) -> generate($num);
#
EOF

    my @x = $class -> new(length => $len, base => $base) -> generate($num);

    subtest 'each element in output array' => sub {
        plan tests => 1 + 2 * $num;
        ok(@x == $num, 'Number of elements in output array is correct');
        for my $x (@x) {
            isa_ok($x, 'Math::BigInt');
            my $data = $x -> copy() -> as_hex();
            $data =~ s/^0x0*([\da-f])/$1/i;
            my $outlen = length $data;
            ok($outlen == $len, "The length $outlen, expected is $len");
        }
    };
}

# Emacs Local Variables:
# Emacs coding: us-ascii-unix
# Emacs mode: perl
# Emacs End:
