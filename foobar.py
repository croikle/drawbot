#!/usr/bin/python2

from __future__ import print_function
import serial
import sys
import time

s = serial.Serial("/dev/ttyACM0")
inputread = sys.stdin.read()

time.sleep(1)

for n in inputread:
   s.write(n)
   print( n, end="")
   if n == '\n' or n == ' ':
      s.read()

print("All Done")
