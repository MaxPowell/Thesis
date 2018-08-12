#!/bin/sh

MULTIPLIER=$1
LIMIT=$2
INTERFACE=$3


REPLAY_OUTPUT="raw_replay.txt"
DATA_OUTPUT="data_replay.txt"
INTERMEDIATE="intermediate.txt"

TIMEOUT=30
PORT_START=2999
PORT_STOP=3999

# usage: ./moongen_script.sh <minimum_rate(Mbps)> <maximum_rate(Mbps)> <interface> [ Mode = 0 or 1 ]

increase_speed()
{
	#thresholds
	p1=20
	p2=100
	p3=1000

	#increase values
	inc1=2
	inc2=20
	inc3=100
	inc4=1000

	if [ $MULTIPLIER -lt $p1 ]; then
		MULTIPLIER=$(($MULTIPLIER + $inc1))
	elif [ $MULTIPLIER -lt $p2 ]; then
		MULTIPLIER=$(($MULTIPLIER + $inc2))
	elif [ $MULTIPLIER -lt $p3 ]; then
		MULTIPLIER=$(($MULTIPLIER + $inc3))
	else
		MULTIPLIER=$(($MULTIPLIER + $inc4))
	fi
}

increase_speed2()
{
	#thresholds
	p1=20
	p2=100
	p3=1000

	#increase values
	inc1=5
	inc2=10
	inc3=50
	inc4=1000

	if [ $MULTIPLIER -lt $p1 ]; then
		MULTIPLIER=$(($MULTIPLIER + $inc1))
	elif [ $MULTIPLIER -lt $p2 ]; then
		MULTIPLIER=$(($MULTIPLIER + $inc2))
	elif [ $MULTIPLIER -lt $p3 ]; then
		MULTIPLIER=$(($MULTIPLIER + $inc3))
	else
		MULTIPLIER=$(($MULTIPLIER + $inc4))
	fi
}

if [ $# -eq 3 ]; then
	MODE=0
elif [ $# -eq 4 ]; then
	MODE=$4
else
	echo "usage: ./moongen_script.sh <minimum_rate(Mbps)> <maximum_rate(Mbps)> <interface> [ Mode = 0 or 1 ]"
	exit 1
fi

echo "Replay Mode: $MODE"

echo "Replay script: multiplier-> $MULTIPLIER, limit-> $LIMIT, interface->$INTERFACE, mode->$MODE"
echo "Replay script: multiplier-> $MULTIPLIER, limit-> $LIMIT, interface->$INTERFACE, mode->$MODE" >> $REPLAY_OUTPUT
sleep 1

while [ $MULTIPLIER -le $LIMIT ]
do

	echo "[+] Waiting message from Bro..."
	(nc -d -l $PORT_START &) | { read conn; echo "Received: $conn"; }

	echo "[+] Testing with $MULTIPLIER\n"
	echo "[+] Testing with $MULTIPLIER\n" >> $REPLAY_OUTPUT
	echo "[+] Testing with $MULTIPLIER\n" >> $DATA_OUTPUT
	sleep 1
	

	#SPEED=$(awk -v m=$MULTIPLIER 'BEGIN { print (m/1.3) }') # Uncomment if using 64 B packets for better precision
	SPEED=$MULTIPLIER
	
	./MoonGen/build/MoonGen MoonGen/libmoon/examples/pktgen.lua -r $SPEED -s $TIMEOUT $INTERFACE > $INTERMEDIATE

	timeout -s SIGINT 1 nc omastar $PORT_STOP &

	cat $INTERMEDIATE >> $REPLAY_OUTPUT

	echo -n 'Speed: ' >> $DATA_OUTPUT	
	cat $INTERMEDIATE | grep total | grep TX | awk '{print substr($12, 2)}' >> $DATA_OUTPUT
	echo -n 'Packets_sent: ' >> $DATA_OUTPUT
	cat $INTERMEDIATE | grep total | grep TX | awk '{print $17}' >> $DATA_OUTPUT
	echo -n 'Bytes_sent: ' >> $DATA_OUTPUT
	cat $INTERMEDIATE | grep total | grep TX | awk '{print $20}' >> $DATA_OUTPUT

	echo "\n" >> $DATA_OUTPUT
	echo "\n" >> $REPLAY_OUTPUT

	sleep 1

	if [ $MODE -gt 0 ]; then
		increase_speed2
	else
		increase_speed
	fi

done

echo "----------------------------" >> $REPLAY_OUTPUT
echo "----------------------------" >> $DATA_OUTPUT

rm $INTERMEDIATE

echo "END :D"

# usage: ./moongen_script.sh <minimum_rate(Mbps)> <maximum_rate(Mbps)> <interface> [ Mode = 0 or 1 ]


