#!/bin/bash

root_check() {
    get_curusr=$(whoami)
    if [ $get_curusr == "root" ]
    then
        ok="okhere"
    else
        echo "ERROR! Please run as root."
        echo "Try: 'sudo su' to elevate and then run install script again."
	echo "OR sudo bash $0"
        exit 1
    fi
}
root_check

# see releases via:
# https://opensearch.org/lines/2x.html

ver=2.11.1
url=https://artifacts.opensearch.org/releases/bundle/opensearch/${ver}/opensearch-${ver}-linux-x64.deb
wget ${url}

dpkg -i opensearch-${ver}-linux-x64.deb

echo "Install Completed"
echo "NOTE: You may need to start/restart service opensearch:"
echo "systemctl restart opensearch"
