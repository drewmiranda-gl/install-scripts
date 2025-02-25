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

# https://www.elastic.co/downloads/past-releases/elasticsearch-6-8-23

# jdk prereq
sudo apt update && sudo apt install -y openjdk-11-jre-headless

# install
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.8.23.deb
sudo dpkg -i elasticsearch-6.8.23.deb

# minimal config
sudo tee -a /etc/elasticsearch/elasticsearch.yml > /dev/null <<EOT
cluster.name: graylog
EOT

# services
sudo systemctl daemon-reload
sudo systemctl enable elasticsearch.service
sudo systemctl restart elasticsearch.service