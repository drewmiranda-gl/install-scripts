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
# https://opensearch.org/lines/1x.html
# https://opensearch.org/docs/1.3/install-and-configure/install-opensearch/index/

# verify prereqs are present
sudo apt-get update && sudo apt-get -y install lsb-release ca-certificates curl gnupg2

# download signing key
 curl -o- https://artifacts.opensearch.org/publickeys/opensearch.pgp | sudo gpg --dearmor --batch --yes -o /usr/share/keyrings/opensearch-keyring

# create repository file
echo "deb [signed-by=/usr/share/keyrings/opensearch-keyring] https://artifacts.opensearch.org/releases/bundle/opensearch/1.x/apt stable main" | sudo tee /etc/apt/sources.list.d/opensearch-1.x.list

# install opensearch
sudo apt-get update
sudo apt-get -y install opensearch

echo "Install Completed"
echo "NOTE: You may need to start/restart service opensearch:"
echo "systemctl restart opensearch"
