#!/bin/bash

# Made by Innovative Inventor at https://github.com/innovativeinventor.
# If you like this code, star it on GitHub!
# Contributions are always welcome.

# MIT License
# Copyright (c) 2017 InnovativeInventor

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# Options
VERSION="1.0"
config="1"
seed="1"
extra=""

while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -c|--config)
    config="$2"
    shift # past argument
    shift # past value
    ;;
    -r|--rand)
    seed="$2"
    shift # past argument
    shift # past value
    ;;
    -h|--help)
    help=YES
    shift # past argument
    ;;
    -b|--build)
    build=YES
    shift # past argument
    ;;
    -d|--dev)
    dev=YES
    shift # past argument
    ;;
    -n|--nopass)
    extra="nopass"
    shift # past argument
    ;;
esac
done

display_help() {
    echo
    echo "Script version $VERSION"
    echo 'A tool for setting up a docker container with PiVPN'
    echo 'Usage: setup.sh <options>'
    echo 'Options:'
    echo '   -h --help                   Show help'
    echo '   -b --build                  Builds dockerfile'
    echo '   -c --config <amount>        Specify the amount of client configs you want'
    echo '   -r --rand <amount>          Specify the amount of random data (in 100s of bytes) that you want your Docker container to be seeded with'
    echo '   -d --dev                    Runs in developer mode'
    echo '   -n --nopass                    Creates a .ovpn file with no password'
    exit 1
}

install_docker_mac() {
    echo "Please install docker at https://download.docker.com/mac/stable/Docker.dmg and restart this script"
}

build_and_setup() {
    if [ "$dev" == YES ]; then
        echo "You are running as a developer, updates from git will not be fetched and your docker image will be built"
    elif [ -e docker-pivpn ]; then # check if -e will return if directory is detected
        cd docker-pivpn
        git pull
        cd ..
    else
        git clone https://github.com/InnovativeInventor/docker-pivpn --depth 1
    fi

    if ! [ $(which docker) ]; then
        if [ "$platform" == debian ]; then
            curl -fsSL get.docker.com | sh
        else
            echo "This OS is not supported"
        fi
    fi

    if [ "$dev" == YES ]; then
        build_run
    elif [ "$build" == YES ]; then
        build_run
    else
        pull_run
    fi
    pivpn_setup
}

build_run() {
    architecture=$(uname -m)
    if [[ "$architecture" == "x86_64" ]]; then
        tag="amd64"

    elif [[ "$architecture" == "arm"* ]]; then
        tag="armhf"

    else
        echo "Architecture not supported"
    fi

    if [ -e $tag/Dockerfile ]; then
        docker build $tag -t docker-pivpn:$tag
    else
        echo "Dockerfile does not exist, will not build. Defaulting to pull"
        pull
    fi
    container="$(docker run -i -d -P --cap-add=NET_ADMIN docker-pivpn:$tag)" # check if permissons can be lowered
}

pull_run() {
    architecture=$(uname -m)
    if [[ "$architecture" == "x86_64" ]]; then
        tag="amd64"
        docker pull innovativeinventor/docker-pivpn:amd64

    elif [[ "$architecture" == "arm"* ]]; then
        tag="armhf"
        docker pull innovativeinventor/docker-pivpn:armhf

    else
        echo "Architecture not supported"
    fi
    container="$(docker run -i -d -P --cap-add=NET_ADMIN innovativeinventor/docker-pivpn:$tag)" # check if permissons can be lowered
}

detect_port() {
    output=$(docker port "$container" 1194/udp)
    port=${output#0.0.0.0:}
    echo Your port is $port
}

pivpn_setup() {
    # ssh root@127.0.0.1 -i "$HOME/.ssh/id_rsa" -p $port
    echo "$container"
    seed_random
    docker exec -it $container bash install.sh
    docker exec -it $container dpkg --configure -a
    docker exec -it $container bash install.sh
    echo "Restarting container . . ."
    docker restart $container
    detect_port
    docker exec -it $container sed -i 's/1194/'"$port"'/g' /etc/openvpn/easy-rsa/pki/Default.txt
    gen_config
    echo "Done! To execute commands, type docker exec -it $container /bin/bash"
    echo "All currently generated configs are in the ovpns directory"
    echo "To generate more configs, just type docker exec -it $container pivpn -a"
    echo "Your openvpn port should be $port, open it up if you are using a firewall"
}

gen_config() {
    count=0
    while [[ $count -lt $config ]]; do
        echo "Generating configs . . . Please answer the prompts"
        docker exec -it $container pivpn -a $extra
        count+=1
    done

    docker cp $container:/home/pivpn/ovpns ovpns
}

seed_random() {

    # Moving script
    if [ -e randwrite.sh ]; then
        docker cp randwrite.sh $container:/randwrite.sh
    else
        docker cp docker-pivpn/randwrite.sh $container:/randwrite.sh
    fi

    # Writing random data
    count=0
    while [[ $count -lt $seed ]]; do
        rand="$(head -100 /dev/urandom)"
        docker exec $container bash randwrite.sh "$rand"
        count+=1
    done
}

# Help option
if [ "$help" == YES ]; then
    display_help
fi

platform=$(python -c "import platform; print(platform.dist()[0])")

build_and_setup
