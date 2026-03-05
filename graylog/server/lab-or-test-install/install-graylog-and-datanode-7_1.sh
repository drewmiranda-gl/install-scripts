#!/bin/bash

# For Ubuntu Server 24 LTS

# Installs
#   - Prereq OS settings
#   - MongoDB 8
#   - Graylog Data Node 7.1 (OpenSearch 2.19.3)
#   - Graylog Enterprise 7.1

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

# Configure the kernel parameters at runtime
# See https://opensearch.org/docs/latest/install-and-configure/install-opensearch/index/#important-settings
# Prevent startup error: vm.max_map_count is too low
sudo sysctl -w vm.max_map_count=262144
echo 'vm.max_map_count=262144' | sudo tee -a /etc/sysctl.conf
# mongo hates swapping
sudo sysctl -w vm.swappiness=0
echo 'vm.swappiness = 0' | sudo tee -a /etc/sysctl.conf

# =============================================================================
# Address the following startup warning
# > We suggest setting the contents of sysfsFile to 0

sudo mkdir -p "/etc/systemd/system/mongod.service.d/"
echo "[Service]
Environment=GLIBC_TUNABLES=glibc.pthread.rseq=0" | sudo tee /etc/systemd/system/mongod.service.d/override.conf

# echo 0 | sudo tee /sys/kernel/mm/transparent_hugepage/khugepaged/max_ptes_none

echo "[Unit]
Description=Disable Transparent Hugepages (THP)
DefaultDependencies=no
After=sysinit.target local-fs.target
Before=mongod.service
[Service]
Type=oneshot
ExecStart=/bin/sh -c 'echo never | tee /sys/kernel/mm/transparent_hugepage/enabled > /dev/null && echo never | tee /sys/kernel/mm/transparent_hugepage/defrag && echo 0 | sudo tee /sys/kernel/mm/transparent_hugepage/khugepaged/max_ptes_none > /dev/null'
[Install]
WantedBy=basic.target" | sudo tee /etc/systemd/system/disable-transparent-huge-pages.service

sudo systemctl daemon-reload
sudo systemctl start disable-transparent-huge-pages
sudo systemctl enable disable-transparent-huge-pages
# =============================================================================

# =============================================================================
# MongoDB

# for reference, via https://www.mongodb.com/docs/v8.0/administration/install-community/
curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | \
   sudo gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg \
   --dearmor

echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list

sudo apt update
sudo apt install -y mongodb-org mongodb-mongosh

# Enable MongoDB service
sudo systemctl daemon-reload
sudo systemctl enable mongod.service
sudo systemctl start mongod.service

# =============================================================================
# DataNode

wget https://packages.graylog2.org/repo/packages/graylog-7.1-repository_latest.deb
sudo dpkg -i graylog-7.1-repository_latest.deb
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
# Graylog
# required for reporting
sudo apt-get install fontconfig fonts-dejavu
sudo apt update --allow-releaseinfo-change && sudo apt install -y graylog-enterprise

sudo cp /etc/graylog/server/server.conf server.conf.bak
sudo sed -i "s/root_password_sha2 =.*/root_password_sha2 = $(cat /etc/graylog/datanode/datanode.conf | grep -P "root_password_sha2 = .*" | sed 's/root_password_sha2 =[[:blank:]]*//g')/g" /etc/graylog/server/server.conf
sudo sed -i "s/password_secret =.*/password_secret = $(cat /etc/graylog/datanode/datanode.conf | grep -P "password_secret = .*" | sed 's/password_secret =[[:blank:]]*//g')/g" /etc/graylog/server/server.conf

sudo sed -i 's/#http_bind_address = 127.0.0.1.*/http_bind_address = 0.0.0.0:9000/g' /etc/graylog/server/server.conf

sudo systemctl daemon-reload
sudo systemctl enable graylog-server
sudo systemctl start graylog-server

# echo "Please run to obtain first run password:"
# echo 'cat /var/log/graylog-server/server.log | grep -P "Initial configuration is accessible at"'
echo "Waiting for 5 seconds to allow Graylog services to start..."
sleep 5
cat /var/log/graylog-server/server.log | grep -P "Initial configuration is accessible at"
