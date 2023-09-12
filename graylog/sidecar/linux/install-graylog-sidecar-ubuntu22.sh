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

wget https://packages.graylog2.org/repo/packages/graylog-sidecar-repository_1-5_all.deb
dpkg -i graylog-sidecar-repository_1-5_all.deb 
apt-get update
apt-get install graylog-sidecar

# Set API URL
echo -ne "Enter Graylog API\nExample: http://hostname.domain.tld:port/api/\nNOTE: must include trailing slash / at end\nAPI Url: " && tmp=$(head -1 </dev/stdin | sed -r 's/\//\\\//g') && sudo sed -i "s/.*server_url:.*/server_url: \"$tmp\"/g" /etc/graylog/sidecar/sidecar.yml

# Set API Token
echo -n "Enter Graylog API Token: " && tmp=$(head -1 </dev/stdin) && sudo sed -i "s/.*server_api_token:.*/server_api_token: \"$tmp\"/g" /etc/graylog/sidecar/sidecar.yml

graylog-sidecar -service install
systemctl enable graylog-sidecar
systemctl start graylog-sidecar
