#!/bin/sh

SPEED=$1
LIMIT=$2
PCAP=$3
INTERFACE=$4
MAX_PKTS=$5


REPLAY_OUTPUT="raw_replay.txt"
DATA_OUTPUT="data_replay.txt"
INTERMEDIATE="intermediate.txt"

TIMEOUT=60
PORT=2999

# usage: ./replay_script.sh <minimum_speed(Mbps)> <maximum_speed(Mbps)> <pcap_file> <interface> <max_packets to send (0 if no limit)> [ Mode = 0 or 1 ]

increase_speed()
{
	#thresholds
	p1=20
	p2=100
	p3=1000

	#increase values
	inc1=5
	inc2=20
	inc3=100
	inc4=1000

	if [ $SPEED -lt $p1 ]; then
		SPEED=$(($SPEED + $inc1))
	elif [ $SPEED -lt $p2 ]; then
		SPEED=$(($SPEED + $inc2))
	elif [ $SPEED -lt $p3 ]; then
		SPEED=$(($SPEED + $inc3))
	else
		SPEED=$(($SPEED + $inc4))
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

	if [ $SPEED -lt $p1 ]; then
		SPEED=$(($SPEED + $inc1))
	elif [ $SPEED -lt $p2 ]; then
		SPEED=$(($SPEED + $inc2))
	elif [ $SPEED -lt $p3 ]; then
		SPEED=$(($SPEED + $inc3))
	else
		SPEED=$(($SPEED + $inc4))
	fi
}



if [ $# -eq 5 ]; then
	MODE=0
elif [ $# -eq 6 ]; then
	MODE=$6
else
	echo "usage: ./replay_script.sh <minimum_speed(Mbps)> <maximum_speed(Mbps)> <pcap_file> <interface> <max_packets to send (0 if no limit)> [ Mode = 0 or 1 ]"
	exit 1
fi

echo "Replay Mode: $MODE"

echo "Replay script: speed-> $SPEED, limit-> $LIMIT, pcap-> $PCAP, interface->$INTERFACE, max_pkts->$MAX_PKTS, mode->$MODE"
echo "Replay script: speed-> $SPEED, limit-> $LIMIT, pcap-> $PCAP, interface->$INTERFACE, max_pkts->$MAX_PKTS, mode->$MODE" >> $REPLAY_OUTPUT
sleep 1

while [ $SPEED -le $LIMIT ]
do

	echo "[+] Waiting message from Bro..."
	(nc -d -l $PORT &) | { read conn; echo "Received: $conn"; }

	echo "[+] Testing with $SPEED Mbps\n"
	echo "[+] Testing with $SPEED Mbps\n" >> $REPLAY_OUTPUT
	echo "[+] Testing with $SPEED Mbps\n" >> $DATA_OUTPUT
	sleep 1
	
	if [ $MAX_PKTS -gt 0 ]; then 
		timeout -s SIGINT $TIMEOUT tcpreplay -q --limit=$MAX_PKTS --mbps=$SPEED --intf1=$INTERFACE $PCAP > $INTERMEDIATE
	else
		timeout -s SIGINT $TIMEOUT tcpreplay -q --mbps=$SPEED --intf1=$INTERFACE $PCAP > $INTERMEDIATE
	fi

	cat $INTERMEDIATE >> $REPLAY_OUTPUT


	echo "Speed: $SPEED" >> $DATA_OUTPUT
	echo -n 'Packets_sent: ' >> $DATA_OUTPUT
	cat $INTERMEDIATE | grep Actual | awk '{print $2}' >> $DATA_OUTPUT
	echo -n 'Bytes_sent: ' >> $DATA_OUTPUT
	cat $INTERMEDIATE | grep Actual | awk '{print substr($4, 2)}' >> $DATA_OUTPUT
	#echo -n 'Actual_speed: ' >> $DATA_OUTPUT
	#cat $INTERMEDIATE | grep Actual | awk '{print $13}' >> $DATA_OUTPUT
	#echo -n 'Time: ' >> $DATA_OUTPUT
	#cat $INTERMEDIATE | grep Actual | awk '{print $8}' >> $DATA_OUTPUT
	#echo -n 'Attempted_packets: ' >> $DATA_OUTPUT
	#cat $INTERMEDIATE | grep Attempted | awk '{print $3}' >> $DATA_OUTPUT
	#echo -n 'Successful_packets: ' >> $DATA_OUTPUT
	#cat $INTERMEDIATE | grep Successful | awk '{print $3}' >> $DATA_OUTPUT
	#echo -n 'Failed_packets: ' >> $DATA_OUTPUT
	#cat $INTERMEDIATE | grep Failed | awk '{print $3}' >> $DATA_OUTPUT


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

# usage: ./replay_script.sh <minimum_speed(Mbps)> <maximum_speed(Mbps)> <pcap_file> <interface> <max_packets to send (0 if no limit)> [ Mode = 0 or 1 ]


