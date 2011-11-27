#!/usr/bin/perl
# Converts coordinates given in x,y space to coordinates in the bot's a,b space.
# Truncates to integers.

#space between pulleys, in svg pixels
$pixelwidth = 1000;
#diameter of pulleys, in mm
$diameter = 10;
#distance between pulleys, in mm
$distance = 1000;
#steps/rev
$ticks = 200;

#distance moved by one revolution = $diameter*pi
#this is $ticks steps
#so steps/distance is $ticks/($diameter*pi)
#multiply this by distance
$steps_between_pulleys = $ticks*$distance/($diameter*3.14);
#global multiplicative scaling factor
$scale = $steps_between_pulleys/$pixelwidth;


while (<>) {
	s/(?<x>-?\d*\.?\d*([eE][+-]?\d+)?),(?<y>-?\d*\.?\d*([eE][+-]?\d+)?)/$a=sqrt($+{x}**2+$+{y}**2)*$scale; $b=sqrt(($pixelwidth-$+{x})**2+$+{y}**2)*$scale; sprintf("%d,%d", $a, $b);/eg;
	#lol perl. TODO: make more readable/maintainable. Better way to do this?
	print;
}
