#!/bin/bash

RED="\e[31m"
# ${RED}

GREEN="\e[32m"
# ${GREEN}

BLUE="\e[34m"
# ${BLUE}

YELLOW="\e[33m"
# ${YELLOW}

ENDCOLOR="\e[0m"
# ${ENDCOLOR}

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

ARCH=$(dpkg --print-architecture)

ABS_PATH_BSE=$(dirname "$0")
cd "$(dirname "$0")"
echo -e "Host: ${BLUE}$(hostname)${ENDCOLOR}"
echo -e "Architecture ${YELLOW}${ARCH}${ENDCOLOR}"
echo -e "Current Working Dir: ${BLUE}$(pwd)${ENDCOLOR}"
echo -e "Absolute Path Base: ${BLUE}${ABS_PATH_BSE}${ENDCOLOR}"
echo ""

# echo please download release from
# echo https://github.com/prometheus-community/elasticsearch_exporter/releases
# echo e.g.
# echo "wget https://...."
# read -p "Confirmation 1 of 2: Press [Enter] key to continue..."
# read -p "Confirmation 2 of 2: Press [Enter] key to continue..."

# CURVER=$(curl --silent https://api.github.com/repos/prometheus/node_exporter/releases | grep -oP '"name": .*' | head -n 1 | grep -oP '[0-9]\.[0-9]\.[0-9]')
CURVER=$(curl --silent https://api.github.com/repos/prometheus-community/elasticsearch_exporter/releases | grep -oP '"name": .*' | head -n 1 | grep -oP '[0-9]\.[0-9]\.[0-9]')
DLURL="https://github.com/prometheus-community/elasticsearch_exporter/releases/download/v${CURVER}/elasticsearch_exporter-${CURVER}.linux-${ARCH}.tar.gz"
echo -e "Downloading ${BLUE}${CURVER}${ENDCOLOR} via ${DLURL}"
wget --quiet $DLURL

FILETGZ="elasticsearch_exporter-*linux-${ARCH}.tar.gz"
FILEDIR="elasticsearch_exporter-*linux-${ARCH}"

echo -e "${BLUE}Extracting...${ENDCOLOR}"
for file in $FILETGZ; do tar -zxf "$file"; done
cd=$(ls -d $FILEDIR | tail -n 1)

echo -e "Changing working dir: ${BLUE}${cd}${ENDCOLOR}"
cd $cd

echo -e "Copying elasticsearch_exporter to: ${BLUE}/usr/local/bin/${ENDCOLOR}"
sudo cp elasticsearch_exporter /usr/local/bin/

echo -e "Adding user: ${BLUE}elasticsearch_exporter${ENDCOLOR}"
sudo useradd -rs /bin/false elasticsearch_exporter

# If using Graylog Data Node change ExecStart to something like
# /usr/local/bin/elasticsearch_exporter --es.uri=https://127.0.0.1:9200 --es.ssl-skip-verify --es.client-cert=/path/to/cert.crt --es.client-private-key=/path/to/cert.key
echo -e "Creating .service file: ${BLUE}/etc/systemd/system/elasticsearch_exporter.service${ENDCOLOR}"
echo '[Unit]
Description=Node Exporter
After=network.target
StartLimitIntervalSec=30
StartLimitBurst=3

[Service]
User=elasticsearch_exporter
Group=elasticsearch_exporter
Type=simple
ExecStart=/usr/local/bin/elasticsearch_exporter
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target' | sudo tee /etc/systemd/system/elasticsearch_exporter.service > /dev/null 2>&1

sudo systemctl daemon-reload
sudo systemctl start elasticsearch_exporter
sudo systemctl enable elasticsearch_exporter
