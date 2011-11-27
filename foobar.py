#!/usr/bin/python2

import serial
import sys

s = serial.Serial("/dev/ttyACM0")
inputread = sys.stdin.read()
positions = inputread.split()

print positions

while True:
	foo = positions.pop(0) + " "
	print foo
	s.write(foo)
	s.read(1)

