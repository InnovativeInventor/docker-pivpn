#!/bin/bash

# Options
while getopts d:p:s option
do
	case "${option}"
	in
	d) DOCKER=${OPTARG};;
	p) PORT=${OPTARG};;
	esac
done

# Getting latest copy of PiVPN script
docker exec $DOCKER curl -L https://install.pivpn.io -o /usr/bin/pivpn
docker exec $DOCKER echo "rm /usr/bin/pivpn" >> /usr/bin/pivpn
docker exec $DOCKER chmod +x pivpn

# Adding MOTD
docker cp assets/motd.tail $DOCKER:/etc/motd.tail

# SSHing into docker container
ssh-keygen -R [127.0.0.1]:$PORT
echo "Logging into $DOCKER, type in your $DOCKER password"
ssh root@127.0.0.1 -p $PORT
