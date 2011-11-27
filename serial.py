#/usr/bin/python2

import serial

s = serial.Serial("/dev/ttyACM0")
inputread = sys.stdin.read()
positions = inputread.split()

while s.read():
	s.write(positions.pop(0) + " ")

