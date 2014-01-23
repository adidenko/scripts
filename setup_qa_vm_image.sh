#!/bin/bash
LC_ALL=C

cd /root/

mv /etc/resolv.conf /etc/resolv.conf_bak
echo 'nameserver 8.8.8.8' > /etc/resolv.conf

# some output for logs
id
cat /etc/issue

# do the stuff
apt-get -y --force-yes update
apt-get -y --force-yes install libpq-dev git-core python-dev libevent-dev libssl-dev python-pip
pip install pbr

git clone https://github.com/stackforge/rally.git && cd rally && python setup.py install && rally-manage db recreate

# clean up
mv /etc/resolv.conf_bak /etc/resolv.conf

