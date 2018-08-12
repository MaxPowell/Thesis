#!/bin/bash

DPDK=$1

if [ $# -ne 1 ]; then
	echo "usage: ./install_bro.sh <0 if Libpcap, 1 if DPDK>"
	exit 1
fi

sudo apt-get update

sudo apt install linux-tools-common linux-tools-`uname -r`

if [ $DPDK -gt 0 ]; then
		sudo apt-get install cmake make gcc g++ flex bison libpcap-dev libssl-dev python-dev swig zlib1g-dev

		sudo apt-get install -y build-essential cmake linux-headers-`uname -r` pciutils libnuma-dev

		git clone --recursive https://github.com/MaxPowell/bro.git

		cd bro/src/ 

		rm -r libmoon

		git clone https://github.com/MaxPowell/libmoon.git
	
		./libmoon/build.sh

		./libmoon/setup-hugetlbfs.sh
		
		cd ..

else
		sudo apt-get install cmake make gcc g++ flex bison libpcap-dev libssl-dev python-dev swig zlib1g-dev

		git clone --recursive git://git.bro.org/bro

		cd bro
fi


./configure

make -j 30

cd ..
