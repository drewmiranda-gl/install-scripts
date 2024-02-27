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

# Disable Transparent Huge Pages (THP)
echo "Description=Disable Transparent Huge Pages (THP)
DefaultDependencies=no
After=sysinit.target local-fs.target
[Service]
Type=oneshot
ExecStart=/bin/sh -c 'echo never | tee /sys/kernel/mm/transparent_hugepage/enabled > /dev/null'
[Install]
WantedBy=basic.target" | sudo tee /etc/systemd/system/disable-transparent-huge-pages.service
sudo systemctl daemon-reload
sudo systemctl enable disable-transparent-huge-pages
sudo systemctl start disable-transparent-huge-pages

# see releases via:
# https://opensearch.org/lines/2x.html

# verify prereqs are present
sudo apt-get update && sudo apt-get -y install lsb-release ca-certificates curl gnupg2
# download signing key
curl -o- https://artifacts.opensearch.org/publickeys/opensearch.pgp | sudo gpg --dearmor --batch --yes -o /usr/share/keyrings/opensearch-keyring
# create repository file
echo "deb [signed-by=/usr/share/keyrings/opensearch-keyring] https://artifacts.opensearch.org/releases/bundle/opensearch/2.x/apt stable main" | sudo tee /etc/apt/sources.list.d/opensearch-2.x.list
# install opensearch
sudo apt-get update
sudo OPENSEARCH_INITIAL_ADMIN_PASSWORD=$(tr -dc A-Z-a-z-0-9_@#%^-_=+ < /dev/urandom  | head -c${1:-32}) apt-get -y install opensearch

echo "Install Completed"
echo "NOTE: You may need to start/restart service opensearch:"
echo "systemctl restart opensearch"
