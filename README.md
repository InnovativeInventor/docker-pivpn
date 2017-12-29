# PiVPN Docker
A simple docker container that sets up pivpn.

# Install and Config
Type in:
```
curl -L https://bit.ly/2CzLV3T -o setup.sh
sudo bash setup.sh
```
For most use cases, you just need to press enter all the way through your prompts.

```
Usage: setup.sh <options>
Options:
   -h --help                Show help
   -b --build               Builds dockerfile
   -c --config <amount>     Specify the amount of client configs you want
   -r --rand <amount>       Specify the amount of random data (100's of bytes) that you want your Docker container to be seeded with
```

# Credits & Contributions
Visit PiVPN's GitHub at https://github.com/pivpn/pivpn.

Contributions are always welcome! Just submit a pull request, and I'll review it.
