#!/bin/bash
# Docker script is from InnovativeInventor/docker-pivpn

# Making sure running with sudo privilges
sudo -v

if [[ "$1" =~ ^([vV][eE][rR][bB][oO][sS][eE]|[vV])+$ ]]; then
    sudo apt-get install curl
    curl -L https://bit.ly/2vJ5PWS | sudo bash #If verbose build
    exit
fi

lsof=$(lsof -v)
if [[ ! "$lsof" ]]; then
    if [[ "$OSTYPE" == "linux-gnu" ]]; then
        sudo apt-get install lsof
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "For some reason, lsof isn't installed on this system"
    fi
fi

# docker=$(docker -v)
# if [[ ! "$docker" ]]; then
#     if [[ "$OSTYPE" == "linux-gnu" ]]; then
#         sudo apt-get update
#         sudo apt-get install -y apt-transport-https
#         sudo apt-get install ca-certificates
#         sudo apt-get install curl
#         sudo apt-get install -y software-properties-common
#         curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
#         sudo add-apt-repository \
#         "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
#         $(lsb_release -cs) \
#         stable"
#         sudo apt-get update
#         sudo apt-get install -y docker-ce
#     elif [[ "$OSTYPE" == "darwin"* ]]; then
#         echo "Please install docker at https://download.docker.com/mac/stable/Docker.dmg"
#     else
#         echo "Not supported operating system, docker isn't installed"
#     fi
# fi

# Starting logs
echo "Running silent-build.sh at date +%c" >> /var/log/docker-pivpn.log

# Pulling from docker
{
docker pull innovativeinventor/docker-pivpn
} &> /dev/null

# Getting random.sh file
mkdir -p assets
curl -s -L https://bit.ly/2uGNBbW -o assets/random.sh

# Getting and configuring setup.sh file
curl -s -L https://bit.ly/2uEmJZk -o assets/setup.sh

# Getting MOTD
curl -s -L https://bit.ly/2gN6TGM -o assets/motd

# Getting password for container
echo Docker SSH password:
read -s password </dev/tty

expose=1194

# Port forwarding
echo "Which port on the host do you want to forward to $expose (usually 1194)?"
read forward </dev/tty

forwardisfree=$(sudo lsof -i :$forward)

while [[ -n "$forwardisfree" ]]; do
    echo "This port is taken, please try another one." >> /var/log/docker-pivpn.log
    echo "Port is taken, please type in another port:"
    read forward </dev/tty
    forwardisfree=$(sudo lsof -i :$forward)
done

# Checking ports
BASE=522
INCREMENT=1
port=$BASE
isfree=$(sudo lsof -i :$port)

# Adding one every time a port is used up
while [[ -n "$isfree" ]]; do
  port=$[port+INCREMENT]
  isfree=$(sudo lsof -i :$port)
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
    	read -r -p "Are you sure? [y/N] " response </dev/tty
		if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]; then

            # Installing
            {
            docker rm pivpn
            docker run --name=pivpn -d -p $port:22 -p $forward:$expose innovativeinventor/docker-pivpn
            ufw allow $forward
            sudo bash assets/random.sh -d pivpn -a ssh
            } &> /dev/null

            # Changing root password for SSH access
            {
                printf "$password\n$password\n"  | docker exec -i pivpn passwd root >> /dev/null
            } &> /dev/null

            # Setup PiVPN prompt
            sudo bash assets/setup.sh -d pivpn -p $port
            exit

    	elif [[ "$response" =~ ^([nN][oO]|[nN])+$ ]]; then
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
    sudo bash assets/random.sh -d pivpn$num -a ssh
    } &> /dev/null

    # Changing root password for SSH access
    {
        printf "$password\n$password\n"  | docker exec -i pivpn$num passwd root >> /dev/null
    } &> /dev/null

    # Setup PiVPN prompt
    sudo bash assets/setup.sh -d pivpn$num -p $port
    exit

fi

# Installing
{
docker run --name=pivpn -d -p $port:22 -p $forward:$expose innovativeinventor/docker-pivpn
ufw allow $forward
sudo bash assets/random.sh -d pivpn -a ssh
} &> /dev/null

# Changing root password for SSH access
{
    printf "$password\n$password\n"  | docker exec -i pivpn passwd root >> /dev/null
} &> /dev/null

# Setup PiVPN prompt
sudo bash assets/setup.sh -d pivpn -p $port
exit
