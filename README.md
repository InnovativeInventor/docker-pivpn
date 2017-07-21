# PiVPN Docker
A simple docker container that sets up pivpn.

# Install and Config
Type in:
 `curl -L https://bit.ly/2vpfRx9 | bash`

Docker SSH Password is the password that you will use to manage the container in the future.

Docker OpenVPN port is the port that you plan to configure PiVPN to send traffic through (Set it to 1194 for most circumstances).

OpenVPN forward port is the port that will be exposed to the internet and will be used to connect to your container. This is the port that you type into the PiVPN installer. The script will reject your port number if it sees that it is currently being used.

When the script prompts for your password, it requires your host root password.

When the script asks if you want to add the fingerprint to known-hosts, type yes.

# Credits
Visit PiVPN's GitHub at https://github.com/pivpn/pivpn
