#!/bin/bash
set -e

# update repositories
# apt-get update
# apt-get upgrade -y
apt-get install -y git 

if [ ! -d "$DIRECTORY" ]; then
  git clone https://github.com/hopsoft/docker-graphite-statsd.git
  ./docker-graphite-statsd/bin/start 
fi

