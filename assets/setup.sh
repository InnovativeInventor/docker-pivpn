#!/bin/bash
while getopts d:p:s option
do
	case "${option}"
	in
	d) DOCKER=${OPTARG};;
	p) PORT=${OPTARG};;
	esac
done

curl -L https://install.pivpn.io -o /usr/bin/pivpn
echo "rm /usr/bin/pivpn" >> /usr/bin/pivpn
chmod +x pivpn

mv assets/motd.tail /etc/motd.tail

echo "Logging into $DOCKER, type in your $DOCKER password"
ssh root@127.0.0.1 -p $PORT
