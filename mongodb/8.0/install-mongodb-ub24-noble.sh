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

# for reference, via https://www.mongodb.com/docs/manual/tutorial/install-mongodb-on-ubuntu/
curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | \
   sudo gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg \
   --dearmor

echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list

sudo apt update
sudo apt install -y mongodb-org mongodb-mongosh
