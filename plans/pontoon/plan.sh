#!/bin/bash
set -e

# update repositories
export DEBIAN_FRONTEND=noninteractive
/usr/bin/apt-get update -y
/usr/bin/apt-get upgrade -y

# install puppet
apt-get install puppet

# apply puppet scripts
cd /plans
/usr/bin/puppet apply default.pp

# install dokku
# cd /plans
# export DOKKU_TAG=v0.2.0
# wget https://raw.github.com/progrium/dokku/v0.2.0/bootstrap.sh -O dokku-bootstrap.sh
# chmod u+x /plans/dokku-bootstrap.sh
# /plans/dokku-bootstrap.sh
