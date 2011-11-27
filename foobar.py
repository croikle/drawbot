#!/usr/bin/python2

import serial
import sys
import time

s = serial.Serial("/dev/ttyACM0")
inputread = sys.stdin.read()
positions = inputread.split()

time.sleep(1)

while len(positions) >= 1:
	foo = positions.pop(0) + " "
	s.write(foo)
	print "foo: \"" + foo + "\""
	s.read()
	print "dot read"

print "All Done"
