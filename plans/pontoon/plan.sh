#!/bin/bash
set -e

# update repositories
export DEBIAN_FRONTEND=noninteractive
/usr/bin/apt-get update -y
/usr/bin/apt-get upgrade -y

# install puppet
/usr/bin/apt-get install -y puppet

# apply puppet scripts
cd /plans
/usr/bin/puppet apply default.pp
