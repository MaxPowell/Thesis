#!/bin/sh

sudo apt-get update

apt install mdadm

mdadm --assemble /dev/md127

mkdir /persistent

mount /dev/md127 /persistent

