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

sudo /usr/bin/docker pull grafana/grafana-oss
sudo /usr/bin/docker stop grafana
sudo /usr/bin/docker rm grafana
sudo /usr/bin/docker run -d -p 3000:3000 -e "GF_SERVER_DOMAIN=<your FQDN>" --name=grafana -v grafana-storage:/var/lib/grafana grafana/grafana-oss
sudo /usr/bin/docker update --restart unless-stopped grafana
