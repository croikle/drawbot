#!/usr/bin/perl
# Converts coordinates given in x,y space to coordinates in the bot's r1,r2 space.
# Truncates to integers.
# Issues when a number isn't in 123.456 format, specifically scientific notation.

#space between pulleys, in svg pixels
$width = 1000;
#global multiplicative scaling factor
$scale = 1;

while (<>) {
	s/(\d*\.?\d*),(\d*\.?\d*)/$r1=sqrt($1**2+$2**2)*$scale; $r2=sqrt(($width-$1)**2+$2**2)*$scale; sprintf("%d,%d", $r1, $r2);/eg;
	print;
}
