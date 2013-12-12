# boatyard
Boatyard is a simple script to help with initial provisioning of Digital Ocean droplets. 
You call it with the name of the droplet and the plans you wish to use. 

# Usage
./launch <boatname> <plans> 
e.g.
./launch pugwash clipper

# Current Plans
Clipper: Creates a centos image and uses puppet to provision the firewall, nginx and node.js

# Extending
Please add more plans for other configurations

# Pre-requisites
Please install [Tugboat](https://github.com/pearkes/tugboat)
