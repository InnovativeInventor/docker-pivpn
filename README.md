# PiVPN Docker
A simple openvpn container that uses pivpn.

# Install
Type in:
 `docker pull innovativeinventor/docker-pivpn`

`docker run --name=docker-pivpn -d -p 522:22 -p 1194:1194 innovativeinventor/docker-pivpn`

To set up a password, type

`docker exec -it docker-pivpn passwd`

You will be able to ssh into your container on port 522 using the password you just set up. The moment you log in, you will be prompted to setup pivpn.

# Credits

Visit PiVPN's GitHub at https://github.com/pivpn/pivpn