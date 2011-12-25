#!/usr/bin/python2

import serial
import sys
import time

s = serial.Serial("/dev/ttyACM0")
inputread = sys.stdin.read()

time.sleep(1)

for n in inputread:
   s.write(n)
   if n == '\n' or n == ' ':
      s.read()
      print "dot read"

print "All Done"
