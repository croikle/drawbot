#!/usr/bin/perl
# Converts coordinates given in x,y space to coordinates in the bot's a,b space.
# Truncates to integers.

#space between pulleys, in svg pixels
$width = 1000;
#global multiplicative scaling factor
$scale = 1;

while (<>) {
	s/(?<x>-?\d*\.?\d*([eE][+-]?\d+)?),(?<y>-?\d*\.?\d*([eE][+-]?\d+)?)/$a=sqrt($+{x}**2+$+{y}**2)*$scale; $b=sqrt(($width-$+{x})**2+$+{y}**2)*$scale; sprintf("%d,%d", $a, $b);/eg;
	#lol perl. TODO: make more readable/maintainable. Better way to do this?
	print;
}
