#!/bin/sh

NUMBER=0

sudo apt-get install bc

while [ $NUMBER -lt 40 ] 
do
	testbed-set-smp-affinity enp4s0f1 2 3 $NUMBER
	NUMBER=$(($NUMBER + 1))
done
