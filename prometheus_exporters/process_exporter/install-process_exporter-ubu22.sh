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

REPOOWNER=ncabatoff
REPONAME=process-exporter
DOWNLOAD_PRODUCTNAME=process-exporter
TCP_LISTEN_PORT=9256

echo ""
echo ""
echo ""
echo "===================================="
echo -e "${BLUE}${DOWNLOAD_PRODUCTNAME} install/upgrade script${ENDCOLOR}"
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

CURVER=$(curl --silent "https://api.github.com/repos/${REPOOWNER}/${REPONAME}/releases" | grep -oP '"name": .*' | head -n 1 | grep -oP '[0-9]+\.[0-9]+\.[0-9]+')
DLURL="https://github.com/${REPOOWNER}/${REPONAME}/releases/download/v${CURVER}/${DOWNLOAD_PRODUCTNAME}-${CURVER}.linux-${ARCH}.tar.gz"

echo -e "Downloading ${BLUE}${CURVER}${ENDCOLOR} via ${DLURL}"
wget --quiet $DLURL

# Download default config file
wget --quiet https://raw.githubusercontent.com/drewmiranda-gl/install-scripts/refs/heads/main/prometheus_exporters/process_exporter/process-exporter-config.yml

FILETGZ="${DOWNLOAD_PRODUCTNAME}-*linux-${ARCH}.tar.gz"
FILEDIR="${DOWNLOAD_PRODUCTNAME}-*linux-${ARCH}"

echo -e "${BLUE}Extracting...${ENDCOLOR}"
for file in $FILETGZ; do tar -zxf "$file"; done
cd=$(ls -d $FILEDIR | tail -n 1)

echo -e "Changing working dir: ${BLUE}${cd}${ENDCOLOR}"
cd $cd

echo -e "Copying ${DOWNLOAD_PRODUCTNAME} to: ${BLUE}/usr/local/bin/${ENDCOLOR}"
cp -f ${DOWNLOAD_PRODUCTNAME} /usr/bin/
cd ..

echo -e "Creating .service file: ${BLUE}/etc/systemd/system/${DOWNLOAD_PRODUCTNAME}.service${ENDCOLOR}"

mkdir -p /etc/process-exporter
cp -f process-exporter-config.yml /etc/process-exporter/

# https://github.com/ncabatoff/process-exporter/blob/master/packaging/process-exporter.service
echo "[Unit]
Description=${DOWNLOAD_PRODUCTNAME}
After=network.target
StartLimitIntervalSec=30
StartLimitBurst=3

[Service]
User=root
Type=simple
ExecStart=/usr/bin/${DOWNLOAD_PRODUCTNAME} --config.path /etc/process-exporter/process-exporter-config.yml --web.listen-address=:9256
KillMode=process
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target" | tee /etc/systemd/system/${DOWNLOAD_PRODUCTNAME}.service > /dev/null 2>&1

echo -e "${BLUE}Reloading...${ENDCOLOR}"
sudo systemctl daemon-reload

echo -e "Restart ${BLUE}${DOWNLOAD_PRODUCTNAME}${ENDCOLOR}"
sudo systemctl restart ${DOWNLOAD_PRODUCTNAME}

sudo systemctl enable ${DOWNLOAD_PRODUCTNAME}

echo -e "Listening on TCP port ${YELLOW}${TCP_LISTEN_PORT}${ENDCOLOR}"
