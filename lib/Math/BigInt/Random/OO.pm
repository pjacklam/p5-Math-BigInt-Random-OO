# -*- mode: perl; coding: utf-8-unix; -*-
#
# Author:      Peter J. Acklam
# Time-stamp:  2010-02-20 10:12:49 +01:00
# E-mail:      pjacklam@online.no
# URL:	       http://home.online.no/~pjacklam

package Math::BigInt::Random::OO;

###############################################################################
## Modules and general package variables.
###############################################################################

use 5.008;              # required version of Perl
use strict;             # restrict unsafe constructs
use warnings;           # control optional warnings
use utf8;               # enable UTF-8 in source code

# Modules from the Standard Perl Library.

use Config;
use Carp;
use Math::BigInt;
#use Data::Dumper;

###############################################################################
# Package variables.
###############################################################################

our $VERSION = 0.02;

=pod

=head1 NAME

Math::BigInt::Random::OO - generate uniformly distributed Math::BigInt objects

=head1 SYNOPSIS

  use Math::BigInt::Random::OO;

  # Random numbers between 1e20 and 2e30:

  my $gen = Math::BigInt::Random::OO -> new(min => "1e20",
					    min => "2e30");
  $x = $gen -> generate();	# one number
  $x = $gen -> generate(1);	# ditto
  @x = $gen -> generate(100);	# 100 numbers

  # Random numbers with size fitting 20 hexadecimal digits:

  my $gen = Math::BigInt::Random::OO -> new(length => 20,
					    base => 16);
  @x = $gen -> generate(100);

=head1 ABSTRACT

Math::BigInt::Random::OO is a module for generating arbitrarily large random
integers from a discrete, uniform distribution. The numbers are returned as
Math::BigInt objects.

=head1 DESCRIPTION

Math::BigInt::Random::OO is a module for generating arbitrarily large random
integers from a discrete, uniform distribution. The numbers are returned as
Math::BigInt objects.

=head1 CONSTRUCTORS

=over 4

=item CLASS -E<gt> new ( ... )

Returns a new C<Math::BigInt::Random::OO> random number generator object. The
arguments are given in the “hash style”, as shown in the following example
which constructs a generator for random numbers in the range from –2 to 3,
inclusive.

  my $gen = Math::BigInt::Random::OO -> new(min => -2, max => 3);

The following parameters are recognized.

=over 4

=item min => NUM

Specifies the minimum possible output value, i.e., the lower bound. If ‘max’ is
given, but ‘min’ is not, then ‘min’ is set to zero.

=item max => NUM

Specifies the maximum possible output value, i.e., the upper bound. If ‘max’ is
given, but ‘min’ is not, then ‘max’ must be non-negative.

=item length => NUM

Specifies the length of the output value, i.e., the number of digits. Use this
option to ensure that all random numbers have the same number of digits. If the
base is not given explicitly with the ‘base’ option, then a base of 10 is used.
The following two constructors are equivalent

  Math::BigInt::Random::OO -> new(length => $n, base => $b);

  $min = Math::BigInt -> new($b) -> bpow($n - 1);
  $max = Math::BigInt -> new($b) -> bpow($n) -> bsub(1));
  Math::BigInt::Random::OO -> new(min => $min, max => $max);

For instance, if the length is 4 and the base is 10, the random numbers will be
in the range from 1000 to 9999 (decimal), inclusive. If the length is 3 and the
base is 16, the random numbers will be in the range from 256 to 4095 (decimal).

This option is ignored if the ‘max’ option is present.

=item base => NUM

Sets the base to be used with the ‘length’ option. See also the description for
the ‘length’ option.

=item length_bin => NUM

This option is only compatibility with Math::BigInt::Random. The following two
cases are equivalent

  $cls -> new(length_bin => $n);
  $cls -> new(length => $n, base => 2);

=item length_hex => NUM

This option is only compatibility with Math::BigInt::Random. The following two
cases are equivalent

  $cls -> new(length_hex => $n);
  $cls -> new(length => $n, base => 16);

=back

=cut

sub new {
    my $proto	 = shift;
    my $protoref = ref $proto;
    my $class	 = $protoref || $proto;
    my $name	 = 'new';

    # Check how the method is called.

    croak "$name() is a class method, not an instance/object method"
      if $protoref;

    # Check the number of input arguments.

    croak "$name(): not enough input arguments"	     if @_ < 1;
    croak "$name(): odd number of input arguments"   if @_ % 2;

    # Check the context.

    carp "$name(): useless use of method in void context"
      unless defined wantarray;

    # Initialize the new object.

    my $self = {
		min	  => undef,
		max	  => undef,
		length	  => undef,
		base	  => 10,
	       };

    # Get the input arguments.

    while (@_) {
	my $key = shift;
	my $val = shift;

	# The minimum value, i.e., lower bound.

	if ($key eq 'min') {
	    croak "$name(): minimum value can't be undefined"
	      unless defined $val;
	    $val = Math::BigInt -> new($val)
	      unless UNIVERSAL::isa($val, 'Math::BigInt');
	    croak "$name(): minimum is not a valid number"
	      if $val -> is_nan();
	    $self -> {min} = $val -> as_int();
	    next;
	}

	# The maximum value, i.e., upper bound.

	if ($key eq 'max') {
	    croak "$name(): maximum value can't be undefined"
	      unless defined $val;
	    $val = Math::BigInt -> new($val)
	      unless UNIVERSAL::isa($val, 'Math::BigInt');
	    croak "$name(): maximum is not a valid number"
	      if $val -> is_nan();
	    $self -> {max} = $val -> as_int();
	    next;
	}

	# The length for the given base.

	if ($key eq 'length') {
	    croak "$name(): length value can't be undefined"
	      unless defined $val;
	    croak "$name(): length value must be positive"
	      unless $val > 0;
	    $self -> {length} = $val;
	    $self -> {base}   = 10;
	    next;
	}

	# The base used when computing the length.

	if ($key eq 'base') {
	    croak "$name(): base value can't be undefined"
	      unless defined $val;
	    croak "$name(): base value must be positive"
	      unless $val > 0;
	    $self -> {base} = $val;
	    next;
	}

	# The length with an implicit base 16.

	if ($key eq 'length_hex') {
	    croak "$name(): length_hex value can't be undefined"
	      unless defined $val;
	    croak "$name(): length_hex value must be positive"
	      unless $val > 0;
	    $self -> {length} = $val;
	    $self -> {base}   = 16;
	    next;
	}

	# The length with an implicit base 2.

	if ($key eq 'length_bin') {
	    croak "$name(): length_bin value can't be undefined"
	      unless defined $val;
	    croak "$name(): length_bin value must be positive"
	      unless $val > 0;
	    $self -> {length} = $val;
	    $self -> {base}   = 2;
	    next;
	}

	croak "$name(): unknown parameter -- $key\n";
    }

    # If the maximum value is given, use that. If the length is given, compute
    # the minimum and maximum values for the given length and base. For
    # instance, if the base is 10 and the length is 3, the minimum value is
    # 100, and the maximum is 999. If the base is 2 and the length is 5, the
    # minimum value is 10000 binary (= 16 decimal) and the maximum is 11111
    # binary (= 31 decimal).

    if (defined $self->{max}) {

	if (defined $self->{length}) {
	    carp "$name(): 'max' is given, so 'length' is ignored";
	}
	if (! defined $self->{min}) {
	    $self->{min} = 0,
	}

	croak "$name(): maximum can't be smaller than minimum"
	  if $self->{max} < $self->{min};

    } else {

	if (defined $self->{length}) {
	    my $base = $self -> {base};
	    my $len  = $self -> {length};
	    $self->{min} = Math::BigInt -> new($base) -> bpow($len - 1);
	    $self->{max} = $self->{min} -> copy() -> bmul($base) -> bsub(1);
	} else {
	    croak "$name(): either 'max' or 'length' must be given\n";
	}

    }

    # The value of $rand_mult * CORE::rand() is a random integer X in the range
    # 0 <= X < 2 ** $rand_bits.

    my $range	  = $self->{max} - $self->{min};
    my $rand_bits = $Config{randbits};
    my $rand_mult = 2 ** $rand_bits;		# multiplier

    # How many chunks, each of size $rand_bits bits, do we need? And what is
    # the size of the highest chunk.

    my $chunks = 1;
    my $hi_range = $range -> copy();
    while ($hi_range >= $rand_mult) {
	$hi_range /= $rand_mult;
	++ $chunks;
    }

    # How many bits in the highest (top) chunk?

    my $hi_bits = 0;
    my $tmp = $hi_range -> copy();
    while ($tmp > 0) {
	$tmp /= 2;
	++ $hi_bits;
    }

    # Save these, since they are needed to generate the random numbers.

    $self->{_chunks}	     = $chunks;
    $self->{_range}	     = $range;
    $self->{_range_high}     = $hi_range -> numify();
    $self->{_rand_mult}	     = $rand_mult;
    $self->{_rand_mult_high} = 2 ** $hi_bits;

    ###########################################################################

    # Bless the reference into an object and return it.

    bless $self, $class;
}

=pod

=item OBJECT -E<gt> generate ( COUNT )

=item OBJECT -E<gt> generate ( )

Generates the given number of random numbers, or one number, if no input
argument is given.

  # Generate ten random numbers:

  my @num = $gen -> generate(10);

=cut

sub generate {
    my $self	= shift;
    my $selfref = ref $self;
    my $class	= $selfref || $self;
    my $name	= 'generate';

    # Check how the method is called.

    croak "$name() is an object instance method, not a class method"
      unless $selfref;

    # Check number of input arguments.

    #croak "$name(): not enough input arguments" if @_ < 1;
    croak "$name(): too many input arguments"	if @_ > 1;

    # Get the count;

    my $count = 1;
    if (@_) {
	$count = shift;
	croak "$name(): input argument must be defined"
	  unless defined $count;
	croak "$name(): input argument must be an integer"
	  unless $count = int $count;
    }

    # Generate the random numbers.

    my @num;

    for (1 .. $count) {
	my $num;

	do {
	    $num = 0;

	    # Generate the highest (top) digits.

	    $num = int CORE::rand $self->{_rand_mult_high};

	    $num = Math::BigInt -> new($num);

	    # Generate the chunks of lower digits.

	    for (2 .. $self->{_chunks}) {
		$num *=		   $self->{_rand_mult};
		$num += CORE::rand $self->{_rand_mult};
	    }

	} until $num <= $self->{_range};

	$num += $self->{min};

	push @num, $num;
    }

    return @num if wantarray;
    return $num[0];
}

=pod

=back

=head1 TODO

=over 4

=item *

Add a way to change the core uniform random number generator. Currently,
CORE::rand() is used, but it would be nice to be able to switch to, e.g.,
Math::Random::random_uniform_integer().

=item *

Add functionality similar to the ‘use_internet’ parameter argument in
Math::BigInt::Rando::random_bigint(). This could be implemented using, e.g.,
Net::Random.

=item *

Add more tests.

=back

=head1 NOTES

=head2 How Math::BigInt::Random::OO works

The generate() method generates a big random integer $X in the range $Xmin ≤ $X
≤ $Xmax by first generating a random integer $U in the range 0 ≤ $U ≤ $R E<lt>
2**$N, where $R is the range $Xmax - $Xmin, and $N is the smallest integer so
that $R E<lt> 2**$N. If $U > $R, then $U is discarded and a new $U is generated
until $U ≤ $R.

A random integer $U in the range 0 ≤ $U E<lt> 2**$N is generated by combining
smaller random integers $V in the range 0 ≤ $V E<lt> 2**$M, where $M ≤ $N. The
smaller random integers are generated with Perl’s own routine for generating
uniformly distributed integers, CORE::rand(). Care is taken so that $M is never
larger than RANDBITS.

You can see the number of RANDBITS in your Perl with

  $ perl -MConfig -wle 'print $Config{randbits}'

or

  $ perl -V:randbits

=head2 Problems with Math::BigInt::Random

I wrote this module since Math::BigInt::Random v0.04 is buggy, and in many
cases slower. The bugs in Math::BigInt::Random v0.04 is

=over 4

=item *

When the range (the maximum value minus the minimum value) is smaller than
0xfffff hexadecimal, which is 1048575 decimal, then the maximum value will
never be returned.

=item *

When Perl has been compiled with a number of RANDBITS less than 20, certain
values will never occur.

=item *

When the range is not a power of two, certain values are more likely to occur
than others.

=back

The core of this two last problems is the use of int(rand(X)), which only
returns uniformly distributed numbers when X is a power of two no larger than
RANDBITS.

In addition, the function Math::BigInt::Random::random_bigint() generates only
one random integer at a time, and in doing so, there is some overhead. In
Math::BigInt::Random::OO, this overhead is placed in the new() constructor, so
it is only done once, independently of how many random numbers are generated by
the generator() method.

=head1 CAVEATS

=over 4

=item *

Some versions of Perl are compiled with the wrong number of RANDBITS.
This module has way to detect if this is the case.

=item *

Some versions of CORE::rand() behave poorly. For intance, in some
implementations

  rand(1 << $Config{randbits}) % 2

alternates between 0 and 1 deterministically.

=back

=head1 BUGS

There are currently no known bugs.

Please report any bugs or feature requests to
C<bug-math-bigint-random-oo at rt.cpan.org>, or through the web interface
at L<http://rt.cpan.org/Public/Bug/Report.html?Queue=Math-BigInt-Random-OO>
I will be notified, and then you’ll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

  perldoc Math::BigInt::Random::OO

You can also look for information at:

=over 4

=item * RT: CPAN’s request tracker

L<http://rt.cpan.org/Public/Dist/Display.html?Name=Math-BigInt-Random-OO>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/~PJACKLAM/Math-BigInt-Random-OO>

=item * AnnoCPAN: HTML-formatted POD

L<http://annocpan.org/~PJACKLAM/Math-BigInt-Random-OO-0.01/lib/Math/BigInt/Random/OO.pm>

=item * CPAN Ratings

L<http://cpanratings.perl.org/dist/Math-BigInt-Random-OO>

=item * Search CPAN

L<http://search.cpan.org/dist/Math-BigInt-Random-OO>

=item * CPAN Testers PASS Matrix

L<http://www.cpantesters.org/distro/M/Math-BigInt-Random-OO.html>

=item * CPAN Testers Reports

L<http://www.cpantesters.org/distro/M/Math-BigInt-Random-OO.html>

=back

=head1 SEE ALSO

Math::BigInt::Random(3), Math::Random(3), Net::Random(3).

=head1 AUTHOR

Peter John Acklam, E<lt>pjacklam@cpan.orgE<gt>

=head1 COPYRIGHT & LICENSE

Copyright 2010 by Peter John Acklam <pjacklam@cpan.org>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.1 or,
at your option, any later version of Perl 5 you may have available.

=cut

1;			# modules must return true
