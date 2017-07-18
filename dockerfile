FROM ubuntu:16.04

MAINTAINER InnovativeInventor

RUN apt-get update && apt-get install -y openssh-server
RUN apt-get install nano
RUN apt-get install -y curl
RUN apt-get install -y whiptail
RUN apt-get install -y net-tools
RUN mkdir /var/run/sshd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

RUN adduser root sudo

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
CMD curl -L https://install.pivpn.io -o ~/install.sh
CMD echo "Please type in the following command, then follow the onscreen prompts to install PiVPN:"
CMD echo 
CMD echo bash install.sh
CMD echo