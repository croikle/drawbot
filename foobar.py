#!/usr/bin/python2

import serial
import sys

s = serial.Serial("/dev/ttyACM0")
inputread = sys.stdin.read()
positions = inputread.split()

while True:
	foo = positions.pop(0) + " "
	s.write(foo)
	print foo
	s.read(1)

