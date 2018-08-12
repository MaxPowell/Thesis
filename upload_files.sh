#!/bin/sh

if [ $# -ne 1 ]; then
	echo "usage: ./upload_files.sh <dir where files are located (full path)>"
	exit 1
fi

DIR=$1

# Load generator
scp -P 10022 "$DIR"install_moongen.sh "$DIR"install_tcpreplay.sh "$DIR"moongen_script.sh "$DIR"moongen_script_v2.sh "$DIR"replay_script.sh "$DIR"retrieve_pcap.sh omanyte:/root

# DuT
scp -P 10022 "$DIR"install_bro.sh "$DIR"bro_script.sh "$DIR"bro_script_v2.sh "$DIR"count_packets.bro "$DIR"bind_queues.sh omastar:/root

