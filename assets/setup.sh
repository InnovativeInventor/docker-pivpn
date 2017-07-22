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
docker exec $DOCKER curl -s -L https://install.pivpn.io -o /usr/bin/pivpn
docker exec $DOCKER "echo su pivpn >> /usr/bin/pivpn"
docker exec $DOCKER chmod +x /usr/bin/pivpn
docker exec $DOCKER usermod -aG sudo root

# Getting password for PiVPN user
echo PiVPN user password:
read -s password </dev/tty
epass=$(perl -e 'print crypt($ARGV[0], "password")' $password)

docker exec -i $DOCKER useradd -m -p $epass pivpn
docker exec $DOCKER usermod -aG sudo pivpn

# Adding MOTD
docker cp assets/motd $DOCKER:/etc/motd
# docker restart $DOCKER

# SSHing into docker container
echo "Logging into $DOCKER, type in your $DOCKER password"

# Adding to known_hosts file automatically since a MiTM attack is only possible if an attacker already has access to the machine
ssh-keygen -R [127.0.0.1]:$PORT
ssh root@127.0.0.1 -q -o StrictHostKeyChecking=no -p $PORT
echo "Done! Access your secure container by typing in: ssh root@127.0.0.1 -p $PORT"
