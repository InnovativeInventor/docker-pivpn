FROM resin/rpi-raspbian

MAINTAINER InnovativeInventor

RUN apt-get update
RUN apt-get install curl -y
RUN apt-get install software-properties-common -y
RUN apt-get install debconf-utils
RUN apt-get install git -y
RUN apt-get install nano
RUN apt-get install whiptail -y
RUN apt-get install openvpn -y
RUN apt-get install dhcpcd5 -y
RUN apt-get install dnsutils -y
RUN apt-get install expect -y
RUN apt-get install whiptail
RUN mkdir /home/pivpn
RUN curl -L https://install.pivpn.io -o install.sh
RUN useradd pivpn
EXPOSE 1194
