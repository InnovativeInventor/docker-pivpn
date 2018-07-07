FROM arm32v7/debian:stretch

MAINTAINER InnovativeInventor

RUN apt-get update && apt-get install -y \
	curl \
	software-properties-common \
	debconf-utils \
	git \
	nano \
	whiptail \
	openvpn \
	dhcpcd5 \
	dnsutils \
	expect \
	whiptail \
	&& rm -rf /var/lib/apt/lists/*

RUN mkdir /home/pivpn
RUN curl -L https://install.pivpn.io -o install.sh
RUN useradd pivpn
EXPOSE 1194

