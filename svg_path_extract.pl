#!/usr/bin/perl
# Reads an SVG file, prints the sequence of points in paths. Each path gets a new line.
# Example: 0,0 10,0 10,10 0,10
# If path has an extra M (or any other characters), not handled yet.
# Relative positions not handled.
# Behavior on more complex files is undefined.

$regex = '^\s*d="M (.*)"$';

while(<>) {
	print "$1\n" if /$regex/;
}

