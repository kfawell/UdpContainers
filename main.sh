#!/bin/bash

log() {
    echo "$(basename "$0"): $@" > /dev/null
}

first_message="$1"

image_name=with_nc:latest

docker rmi "$image_name" > /dev/null
docker build -q -t "$image_name" . > /dev/null

address=$(ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)
wildcard=0.0.0.0
address_in=$wildcard
address_out=127.0.0.1
container_in=$wildcard
container_out=$address

port_1=5001
port_2=5002
port_3=5003
port_4=5004
port_last=$port_4

run_container() {
    local address_in="$1"
    local port_in="$2"
    local address_out="$3"
    local port_out="$4"

    local in="$port_in:$port_in/udp"
    local out="$port_out:$port_out/udp"    
    local script=/udp_append_x_3times.sh

    log docker run -d --rm -p $in $image_name "$script" $address_in $port_in $address_out $port_out
    container_id=$(docker run -d --rm -p $in $image_name "$script" $address_in $port_in $address_out $port_out)
    # docker logs -f $container_id &
}

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

pipe="pipe_${port_last}_$$"
mkfifo $pipe
log Pipe: $pipe

# listen, udp, listen again, no stdin
nc -lukd $address_in $port_last > $pipe &
nc_pid=$!
log NC PID: $nc_pid

log Begin run containers
run_container $container_in $port_1 $container_out $port_2
run_container $container_in $port_2 $container_out $port_3
run_container $container_in $port_3 $container_out $port_4
log End run containers

# Wait for containers to get ready. Not a greate solution, but seems reliable enough for now.
sleep 0.5

log Send first message: $first_message
# udp, quit 0 seconds after EOF
echo "$first_message" | nc -u -w 0 $address_out $port_1

count=3
index=0
log Loop: count: $count

while [ $index -lt $count ] && IFS= read -r line; do
    echo $line
    ((index++))
    if [ $index -lt $count ]; then
        modified_line="${line}y"
        # udp, quit 0 seconds after EOF
        echo "$modified_line" | nc -u -w 0 $address_out $port_1
    fi
done < $pipe

log Messages sent
