#!/bin/bash
set -e

# update repositories
/usr/bin/apt-get -y -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confnew update
/usr/bin/apt-get -y -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confnew upgrade
# /usr/bin/apt-get -y -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confnew dist-upgrade
# /usr/bin/do-release-upgrade

# install dokku
cd /plans
export DOKKU_TAG=v0.2.0
wget https://raw.github.com/progrium/dokku/v0.2.0/bootstrap.sh -O dokku-bootstrap.sh
chmod u+x /plans/dokku-bootstrap.sh
/plans/dokku-bootstrap.sh
