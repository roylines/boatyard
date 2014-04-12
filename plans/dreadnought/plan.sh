#!/bin/bash
set -e

# update repositories
/usr/bin/yum -y update

# install puppet
echo 'installing puppet'
set +e
/bin/rpm -Uvh http://yum.puppetlabs.com/el/6/products/i386/puppetlabs-release-6-7.noarch.rpm
set -e
/usr/bin/yum -y install puppet

# provision
cd /plans
/usr/bin/puppet apply default.pp
