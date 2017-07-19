#!/bin/bash
echo "Making sudo, please ensure that you have verified this script's checksum"
sudo -v
SIZE=$((100))
while getopts d:s:a option
do
	case "${option}"
	in
	d) DOCKER=${OPTARG};;
	s) SIZE=${OPTARG};;
	a) APP=${OPTARG};;
	esac
done

# OS-detection
if [[ "$OSTYPE" == "linux-gnu" ]]; then
	apt-get install -y haveged
	echo "Detected GNU/Linux, installing haveged" >> /etc/rnd/random.log
fi

# might be useful: LC_ALL=C sed s/\"//
mkdir -p /etc/rnd
touch /etc/rnd/random
touch /etc/rnd/random_openssl
chmod -R 775 /etc/rnd
chmod 775 /etc/rnd/random
chmod 775 /etc/rnd/random_openssl

# Creating error log
echo '' >> /etc/rnd/random.log
echo "Running random.sh, with options -d $DOCKER -s $SIZE -a $APP at date +%c" >> /etc/rnd/random.log

# Generating random numbers a few times
cat /dev/random | head -c 512 >> /etc/rnd/random
openssl rand -rand /etc/rnd/random 200 >> /etc/rnd/random_openssl
cat /dev/urandom | head -c 100 >> /etc/rnd/random
openssl rand -rand /etc/rnd/random 200 >> /etc/rnd/random_openssl
cat /dev/urandom | head -c 100 >> /etc/rnd/random
openssl rand -rand /etc/rnd/random 200 >> /etc/rnd/random_openssl

if [[ "$DOCKER" == "" ]]; then
	echo "Please type in your Docker container's name. For help, type -h"
fi

docker stop "$DOCKER" >> /dev/null
docker cp /etc/rnd/random_openssl "$DOCKER":/dev/random
docker start "$DOCKER" >> /dev/null

if [[ "$APP" = "ssh" || "$APP" = "SSH" ]]; then
	echo "Changing SSH keys, you may get a known hosts error when connecting next time"
	docker exec $DOCKER /bin/rm -v /etc/ssh/ssh_host_*
	docker exec $DOCKER dpkg-reconfigure openssh-server
	echo "Restarting SSH service, beware"
	docker exec $DOCKER /etc/init.d/ssh restart
fi

rm -r /etc/rnd
