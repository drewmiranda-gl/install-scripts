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
	echo "OR bash $0"
        exit 1
    fi
}
root_check

echo ""
echo ""
echo ""
echo "===================================="
echo -e "${BLUE}Node Exporter install/upgrade script${ENDCOLOR}"
echo "===================================="
echo ""

ARCH=$(dpkg --print-architecture)

ABS_PATH_BSE=$(dirname "$0")
cd "$(dirname "$0")"
echo -e "Host: ${BLUE}$(hostname)${ENDCOLOR}"
echo -e "Architecture ${YELLOW}${ARCH}${ENDCOLOR}"
echo -e "Current Working Dir: ${BLUE}$(pwd)${ENDCOLOR}"
echo -e "Absolute Path Base: ${BLUE}${ABS_PATH_BSE}${ENDCOLOR}"
echo ""

# echo please download release from
# echo https://prometheus.io/download/#node_exporter
# echo e.g.
# echo "wget https://...."
# read -p "Confirmation 1 of 2: Press [Enter] key to continue..."
# read -p "Confirmation 2 of 2: Press [Enter] key to continue..."

CURVER=$(curl --silent https://api.github.com/repos/prometheus/node_exporter/releases | grep -oP '"name": .*' | head -n 1 | grep -oP '[0-9]\.[0-9]\.[0-9]')
DLURL="https://github.com/prometheus/node_exporter/releases/download/v${CURVER}/node_exporter-${CURVER}.linux-${ARCH}.tar.gz"
echo -e "Downloading ${BLUE}${CURVER}${ENDCOLOR} via ${DLURL}"
wget --quiet $DLURL

FILETGZ="node_exporter-*linux-${ARCH}.tar.gz"
FILEDIR="node_exporter-*linux-${ARCH}"

echo -e "${BLUE}Extracting...${ENDCOLOR}"
for file in $FILETGZ; do tar -zxf "$file"; done
cd=$(ls -d $FILEDIR | tail -n 1)

echo -e "Changing working dir: ${BLUE}${cd}${ENDCOLOR}"
cd $cd

echo -e "Copying node_exporter to: ${BLUE}/usr/local/bin/${ENDCOLOR}"
cp -f node_exporter /usr/local/bin/

echo -e "Adding user: ${BLUE}node_exporter${ENDCOLOR}"
useradd -rs /bin/false node_exporter

echo -e "Creating .service file: ${BLUE}/etc/systemd/system/node_exporter.service${ENDCOLOR}"
echo '[Unit]
Description=Node Exporter
After=network.target
 
[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter
 
[Install]
WantedBy=multi-user.target' | sudo tee /etc/systemd/system/node_exporter.service > /dev/null 2>&1

echo -e "${BLUE}Reloading...${ENDCOLOR}"
systemctl daemon-reload
echo -e "Restart ${BLUE}node_exporter${ENDCOLOR}"
systemctl restart node_exporter
echo -e "enable ${BLUE}node_exporter${ENDCOLOR}"
systemctl enable node_exporter
