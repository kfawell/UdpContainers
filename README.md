# UdpContainers
## Run three containers passing text between three times them using UDP.

### Getting Started
Run `./main.sh first`

The output should be:

```
firstxxx
firstxxxyxxx
firstxxxyxxxyxxx
```

### Requirements
- Create a bash script main.sh that:
  - Takes a single input argument, no stdin, sends its output to stdout.
  - Creates a suitable execution environment, populated with the dependencies for creating and starting Docker containers.
  - Creates and starts three container instances in sequence.
    - Container images are Ubuntu.
  - Provides each container with two (4) pieces of information: incoming udp address/port, outgoing udp address/port.
    - Provides for this information to become available to each container instance through any convenient means.
  - The output address/port of one container is input address/port of the next.
  - The containers should clean up when they are done.
  - The output of the final container is pointed at a udp address/port at which main.sh listens.
  - Sending and receiving are done using netcat.
  - Use a named pipe to keep the receiving socket open.
  - Process its output in a loop.
  - After creating the container instances, sends the command line argument to the first container.
  - Each time main.sh receives a datagram, it appends “y”, prints it to stdout, and sends it to the first container.
  - When main.sh receives the third datagram, it prints it to stdout and then exits instead of sending it to the first container.
- Container lifetime is as follows:
  - Upon startup, run udp_append_x_3times.sh that:
    - Starts listening at the incoming address/port.
    - As with main.sh, uses netcat and a named pipe.
    - When a datagram is received, read it, append “x”, and then send it.
    - After sending the third datagram, cleans up and exits.
