#!/bin/bash

if [ -e /var/local/puppet-bootstrapped ] ; then
    echo "Skipping puppet bootstrap as it appears to already have been done."
    echo "Remove /var/local/puppet-bootstrapped in VM to re-provision puppet modules."
    exit 0
fi

if [ "$EUID" -ne "0" ] ; then
    echo "Script must be run as root." >&2
    exit 1
fi

wget https://apt.puppetlabs.com/puppetlabs-release-pc1-xenial.deb
dpkg -i puppetlabs-release-pc1-xenial.deb
apt-get update
apt-get install puppetserver -y
apt-get install rubygems -y

mkdir -p /etc/puppet/modules

if which gem > /dev/null ; then
    /usr/bin/gem install r10k
    apt-get install git -y
    
    cd /vagrant
    r10k puppetfile install
fi

touch /var/local/puppet-bootstrapped

