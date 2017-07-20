#!/bin/bash
# Script is from InnovativeInventor/pivpn, with some modifications

echo "Running . . ."

# Pulling from docker
docker pull innovativeinventor/docker-pivpn

# Getting random.sh file
mkdir -p assets
curl -L https://bit.ly/2uGNBbW -o assets/random.sh

# Getting and configuring setup.sh file
curl -L https://bit.ly/2uEmJZk -o assets/setup.sh

# Getting MOTD
curl -L https://bit.ly/2tgSzYD -o assets/motd.tail

# Checking ports
BASE=522
INCREMENT=1
port=$BASE
isfree=$(lsof -i -n -P | grep $port)

# Adding one every time a port is used up
while [[ -n "$isfree" ]]; do
  port=$[port+INCREMENT]
  isfree=$(lsof -i -n -P | grep $port)
done

# Getting password for container
echo Docker password:
read -s password

# Checking if name exists

# Adding docker is free varible and docker is exited varible
dockerisfree=$(docker ps -q -f name=pivpn$num)
dockerisexited=$(docker ps -aq -f status=exited -f name=pivpn)

# If statements
if [[ -n "$dockerisfree" ]]; then

	# Checking if it is exited
    if [[ -n "$dockerisexited" ]]; then

    	# Asking user if it is okay to delete exited container with the same name
    	echo "A exited version of docker-pivpn has been detected, do you want to delete it?"
    	read -r -p "Are you sure? [y/N] " response
		if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
		then

			# Creating everything, then exiting to prevent errors
    		docker rm pivpn
    		docker run --name=pivpn -d -p $port:22 innovativeinventor/docker-pivpn
			sudo sh assets/random.sh -d pivpn -a ssh
			printf "$password\n$password\n"  | docker exec -i pivpn$ passwd root
			echo "Done! A container with the name pivpn and the pivpn port $port has been created for you. Entropy has been added to the system from this server, and the ssh keys have been regenerated."

            # Setup PiVPN prompt
            sudo sh assets/setup.sh -d pivpn -p $port
            exit 10
    	elif [[ "$response" =~ ^([nN][oO]|[nN])+$ ]]
    	then
    		# Allowing to proceed
    		echo "Okay, creating a new container with different name"

		else
    		echo "Error, invalid input"
		fi
    fi

    # Figuring out what number suffix to attach to the end
	DOCKERBASE=1
	DOCKERINCREMENT=1

	num=$DOCKERBASE

	while [[ -n "$dockerisfree" ]];do
		num=$[num+DOCKERINCREMENT]
		dockerisfree=$(docker ps -q -f name=pivpn$num)
	done
	echo $num

	# Creating everything, then exiting to prevent errors
    docker run --name=pivpn$num -d -p $port:22 innovativeinventor/docker-pivpn
	sudo sh assets/random.sh -d pivpn$num -a ssh
	printf "$password\n$password\n"  | docker exec -i pivpn$num passwd root
    echo "Done! A container with the name pivpn$num and the pivpn port $port has been created for you. Entropy has been added to the system from this server, and the shh keys have been regenerated."

    # Setup PiVPN prompt
    sudo sh assets/setup.sh -d pivpn$num -p $port
    exit 10

fi

# Installing
docker run --name=pivpn -d -p $port:22 innovativeinventor/docker-pivpn
sudo sh assets/random.sh -d pivpn -a ssh
printf "$password\n$password\n"  | docker exec -i pivpn passwd root

# Setup PiVPN prompt
sudo sh assets/setup.sh -d pivpn -p $port

echo "Done! A container with the name pivpn and the pivpn port $port has been created for you. Entropy has been added to the system from this server, and the ssh keys have been regenerated."
exit 10
