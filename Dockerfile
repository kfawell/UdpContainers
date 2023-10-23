FROM ubuntu:latest

RUN apt-get update && apt-get install -y netcat
RUN apt-get update && apt-get install -y net-tools

ENV MAIN=udp_append_x_3times.sh
ADD $MAIN /$MAIN
RUN chmod +x /$MAIN