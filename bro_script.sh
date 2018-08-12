#!/bin/sh


INTERFACE=$1
ITERATIONS=$2
MULTICORE=$3
BRO_SCRIPTS=$4

BRO_OUTPUT="raw_bro.txt"
PERF_OUTPUT="raw_perf.txt"
DATA_OUTPUT="data_bro.txt"
BRO_INTER="intermediate.txt"
PERF_INTER="perf_inter.txt"
BRO_LOG="reporter.log"

COUNT_SCRIPT="count_packets.bro"
SSL_SCRIPT="ssl_handshakes.bro"

TIMEOUT=75
PORT=2999

ROUND=0

if [ $# -ne 4 ]; then
	if [ $# -ne 3 ]; then
		echo "usage: ./bro_script.sh <interface> <num_executions> <1 if multicore, 0 if not> <script>"
		exit 1
	fi
fi

echo "Interface-> $INTERFACE, scripts-> $BRO_SCRIPTS\n"

while [ $ROUND -lt $ITERATIONS ]
do
	ROUND=$(($ROUND + 1))
	echo "Execution of Bro number: $ROUND\n"
	echo "Execution of Bro number: $ROUND\n" >> $DATA_OUTPUT
	echo "Execution of Bro number: $ROUND\n" >> $BRO_OUTPUT
	echo "Execution of Bro number: $ROUND\n" >> $PERF_OUTPUT

	(sleep 15 &&  timeout -s SIGINT 2 nc omanyte $PORT &)

	if [ $MULTICORE -gt 0 ]; then 
		timeout -s SIGINT $TIMEOUT perf stat -o $PERF_INTER ./bro/build/src/bro -C -i $INTERFACE $BRO_SCRIPTS > $BRO_INTER

	else
		timeout -s SIGINT $TIMEOUT taskset 0x8 perf stat -o $PERF_INTER ./bro/build/src/bro -C -i $INTERFACE $BRO_SCRIPTS > $BRO_INTER
	fi

	cat $BRO_LOG >> $BRO_OUTPUT
	cat $BRO_INTER >> $BRO_OUTPUT
	cat $PERF_INTER >> $PERF_OUTPUT

	echo -n "Packets_received: " >> $DATA_OUTPUT
	cat $BRO_LOG | grep dropped | awk '{print $3}' >> $DATA_OUTPUT
	echo -n "Packets_dropped: " >> $DATA_OUTPUT
	cat $BRO_LOG | grep dropped | awk '{print $9}' >> $DATA_OUTPUT

	case "$BRO_SCRIPTS" in
		*$COUNT_SCRIPT*) 
			echo -n "Packets_counted: " >> $DATA_OUTPUT
			cat $BRO_INTER | grep script | awk '{print $6}' >> $DATA_OUTPUT;;
		* ) ;;
	esac

	case "$BRO_SCRIPTS" in
		*$SSL_SCRIPT*) 
			echo -n "Handshakes_counted: " >> $DATA_OUTPUT
			cat $BRO_INTER | grep handshakes | awk '{print $5}' >> $DATA_OUTPUT;;
		* ) ;;
	esac

	echo -n "CPUs_used: " >> $DATA_OUTPUT
	cat $PERF_INTER | grep task-clock | awk '{print $5}' >> $DATA_OUTPUT
	echo -n "CPU_cycles(GHz): " >> $DATA_OUTPUT
	cat $PERF_INTER | grep cycles | awk '{print $4}' >> $DATA_OUTPUT
	echo -n "Page_faults(M/sec): " >> $DATA_OUTPUT
	cat $PERF_INTER | grep page-faults | awk '{print $4}' >> $DATA_OUTPUT
	echo -n "Exec_time: " >> $DATA_OUTPUT
	cat $PERF_INTER | grep elapsed | awk '{print $1}' >> $DATA_OUTPUT

	echo "\n" >> $DATA_OUTPUT
	echo "\n" >> $BRO_OUTPUT
	echo "\n" >> $PERF_OUTPUT

done

rm $BRO_INTER
rm $PERF_INTER

echo "----------------------------" >> $DATA_OUTPUT
echo "----------------------------" >> $BRO_OUTPUT
echo "----------------------------" >> $PERF_OUTPUT

echo "END :D"


