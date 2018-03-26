FROM arm32v7/debian:latest

MAINTAINER InnovativeInventor

RUN apt-get update
RUN apt-get install -y curl software-properties-common debconf-utils git nano whiptail openvpn dhcpcd5 dnsutils expect
RUN curl -L https://install.pivpn.io -o install.sh
RUN useradd -m pivpn
EXPOSE 1194
