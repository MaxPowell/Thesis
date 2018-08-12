#!/bin/sh

sudo apt-get update

sudo apt-get install -y build-essential cmake linux-headers-`uname -r` pciutils libnuma-dev

git clone https://github.com/emmericp/MoonGen.git

./MoonGen/build.sh

./MoonGen/setup-hugetlbfs.sh

