#!/bin/bash

# Receive from address_in:port_in, append y, send to address_out:port_out, and exit after 3 datagrams.

address_in=$1
port_in=$2
address_out=$3
port_out=$4

log() {
    echo "$(basename "$0"): $port_in: $@" > /dev/null
}

log Arguments: $address_in $port_in $address_out $port_out

cleanup() {
    if [ -n "$nc_pid" ]; then
        kill $nc_pid
    fi
    if [ -n "$pipe" ]; then
        rm $pipe
    fi
    exit
}
trap cleanup EXIT

pipe="pipe_${port_in}_$$"
mkfifo $pipe
log Pipe: $pipe

# listend, udp, listen again, no stdin
nc -lukd $address_in $port_in > $pipe &
nc_pid=$!
log NC PID: $nc_pid

count=3
index=0
log Loop: count: $count

while [ $index -lt $count ] && IFS= read -r line; do
    modified_line="${line}x"
    # udp, quit 0 seconds after EOF
    echo "$modified_line" | nc -u -w 0 $address_out $port_out
    ((index++))
done < $pipe

log End messages
