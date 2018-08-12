#!/bin/sh

if [ $# -ne 1 ]; then
	echo "usage: ./retrieve_files.sh <dir>"
	exit 1
fi

DIR=$1

scp omanyte:/root/data_replay.txt $DIR
scp omanyte:/root/raw_replay.txt $DIR

scp omastar:/root/data_bro.txt $DIR
scp omastar:/root/raw_bro.txt $DIR
scp omastar:/root/raw_perf.txt $DIR
