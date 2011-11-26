#!/usr/bin/perl
# Converts coordinates given in x,y space to coordinates in the bot's r1,r2 space.
# Truncates to integers.

#space between pulleys, in svg pixels
$width = 1000;
#global multiplicative scaling factor
$scale = 1;

while (<>) {
	s/(?<x>-?\d*\.?\d*([eE][+-]?\d+)?),(?<y>-?\d*\.?\d*([eE][+-]?\d+)?)/$r1=sqrt($+{x}**2+$+{y}**2)*$scale; $r2=sqrt(($width-$+{x})**2+$+{y}**2)*$scale; sprintf("%d,%d", $r1, $r2);/eg;
	print;
}
