tcpdump -i $1 -w $2 -G $3 &
sleep $3
tcpdumppid=$!
kill -2 $tcpdumppid
