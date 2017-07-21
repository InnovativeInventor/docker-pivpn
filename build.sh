#!/bin/bash
# Script is from InnovativeInventor/pivpn, with some modifications

echo "Making sure everything is up to date . . ."

# Pulling from docker
docker pull innovativeinventor/docker-pivpn

# Getting random.sh file
mkdir -p assets
curl -s -L https://bit.ly/2uGNBbW -o assets/random.sh

# Getting and configuring setup.sh file
curl -s -L https://bit.ly/2uEmJZk -o assets/setup.sh

# Getting MOTD
curl -s -L https://bit.ly/2gN6TGM -o assets/motd

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
echo Docker SSH password:
read -s password

echo Docker OpenVPN port:
read expose


echo "Which port on the host do you want to forward to $expose?"
read forward

isfree=$(lsof -i -n -P | grep $forward)

while [[ -n "$isfree" ]]; do
    echo "This port is taken, please try another one."
    echo OpenVPN forward port:
    read forward
    isfree=$(lsof -i -n -P | grep $forward)
done

# Adding docker is free varible and docker is exited varible
dockerisfree=$(docker ps -q -f name=pivpn$num)
dockerisexited=$(docker ps -aq -f status=exited -f name=pivpn)

# Checking if name exists
if [[ -n "$dockerisfree" ]]; then

	# Checking if it is exited
    if [[ -n "$dockerisexited" ]]; then

    	# Asking user if it is okay to delete exited container with the same name
    	echo "A exited version of docker-pivpn has been detected, do you want to delete it?"
    	read -r -p "Are you sure? [y/N] " response
		if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
		then

			# Creating everything, then exiting to prevent errors
            {
    		docker rm pivpn
    		docker run --name=pivpn -d -p $port:22 -p $forward:$expose innovativeinventor/docker-pivpn
            ufw allow $forward
            sudo sh assets/random.sh -d pivpn -a ssh
            } &> /dev/null

            # Changing root password for SSH access
            {
                printf "$password\n$password\n"  | docker exec -i pivpn passwd root >> /dev/null
            } &> /dev/null

            # Setup PiVPN prompt
            sudo sh assets/setup.sh -d pivpn -p $port
            exit

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

	# Creating everything, then exiting to prevent errors
    {
    docker run --name=pivpn$num -d -p $port:22 -p $forward:$expose innovativeinventor/docker-pivpn
    ufw allow $forward
    sudo sh assets/random.sh -d pivpn$num -a ssh
    } &> /dev/null

    # Changing root password for SSH access
    {
        printf "$password\n$password\n"  | docker exec -i pivpn$num passwd root >> /dev/null
    } &> /dev/null

    # Setup PiVPN prompt
    sudo sh assets/setup.sh -d pivpn$num -p $port
    exit

fi

# Installing
{
docker run --name=pivpn -d -p $port:22 -p $forward:$expose innovativeinventor/docker-pivpn
ufw allow $forward
sudo sh assets/random.sh -d pivpn -a ssh
} &> /dev/null

# Changing root password for SSH access
{
    printf "$password\n$password\n"  | docker exec -i pivpn passwd root >> /dev/null
} &> /dev/null

# Setup PiVPN prompt
sudo sh assets/setup.sh -d pivpn -p $port
exit
