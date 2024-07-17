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

# =============================================================================
# DataNode

# Configure the kernel parameters at runtime
# See https://opensearch.org/docs/latest/install-and-configure/install-opensearch/index/#important-settings
sudo sysctl -w vm.max_map_count=262144
echo 'vm.max_map_count=262144' | sudo tee -a /etc/sysctl.conf

wget https://packages.graylog2.org/repo/packages/graylog-6.0-repository_latest.deb
sudo dpkg -i graylog-6.0-repository_latest.deb
sudo apt update --allow-releaseinfo-change && sudo apt install -y graylog-datanode

# admin password
tmppw=$(echo "admin" | tr -d '\n' | sha256sum | cut -d" " -f1)
sudo sed -i "s/root_password_sha2 =.*/root_password_sha2 = $tmppw/g" /etc/graylog/datanode/datanode.conf

tmppw=$(openssl rand -hex 32)
sudo sed -i "s/password_secret =.*/password_secret = $tmppw/g" /etc/graylog/datanode/datanode.conf
tmppw=abc

sudo systemctl daemon-reload
sudo systemctl enable graylog-datanode
sudo systemctl start graylog-datanode


# =============================================================================
# MongoDB

# for reference, via https://www.mongodb.com/docs/manual/tutorial/install-mongodb-on-ubuntu/
# Install MongoDB 6
curl -fsSL https://pgp.mongodb.com/server-6.0.asc | \
   sudo gpg -o /usr/share/keyrings/mongodb-server-6.0.gpg \
   --dearmor
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-6.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
sudo apt update --allow-releaseinfo-change
sudo apt install -y mongodb-org mongodb-mongosh

# Enable MongoDB service
sudo systemctl daemon-reload
sudo systemctl enable mongod.service
sudo systemctl start mongod.service

# =============================================================================
# Graylog
sudo apt update --allow-releaseinfo-change && sudo apt install -y graylog-enterprise

sudo cp /etc/graylog/server/server.conf server.conf.bak
sudo sed -i "s/root_password_sha2 =.*/root_password_sha2 = $(cat /etc/graylog/datanode/datanode.conf | grep -P "root_password_sha2 = .*" | sed 's/root_password_sha2 =[[:blank:]]*//g')/g" /etc/graylog/server/server.conf
sudo sed -i "s/password_secret =.*/password_secret = $(cat /etc/graylog/datanode/datanode.conf | grep -P "password_secret = .*" | sed 's/password_secret =[[:blank:]]*//g')/g" /etc/graylog/server/server.conf

sudo sed -i 's/#http_bind_address = 127.0.0.1.*/http_bind_address = 0.0.0.0:9000/g' /etc/graylog/server/server.conf

sudo systemctl daemon-reload
sudo systemctl enable graylog-server
sudo systemctl start graylog-server

echo "Please run to obtain first run password:"
echo 'cat /var/log/graylog-server/server.log | grep -P "Initial configuration is accessible at"'
