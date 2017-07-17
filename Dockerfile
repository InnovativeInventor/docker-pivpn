FROM ubuntu:16.04

MAINTAINER InnovativeInventor

ENV PASSWORD rootpassword

RUN apt-get update && apt-get install -y openssh-server
RUN apt-get install nano
RUN apt-get install curl
RUN apt-get install whiptail
RUN mkdir /var/run/sshd
RUN echo “root:$PASSWORD” | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
CMD passwd
CMD curl -L https://install.pivpn.io | bash
