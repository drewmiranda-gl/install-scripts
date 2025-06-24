#!/bin/sh
# ======================
# REQUIRES CURL!
# apk add curl
#
# rm install-node_exporter-alpine.sh; wget https://raw.githubusercontent.com/drewmiranda-gl/install-scripts/refs/heads/main/prometheus_exporters/node_exporter/install-node_exporter-alpine.sh && sh install-node_exporter-alpine.sh
# =====================

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

echo ""
echo ""
echo ""
echo "===================================="
echo -e "${BLUE}Node Exporter install/upgrade script${ENDCOLOR}"
echo "===================================="
echo ""

get_architecture() {
    arch=$(uname -m)

    # Translate if the architecture is x86_64
    if [[ "$arch" == "x86_64" ]]; then
        echo "amd64"
    else
        echo -e "${RED}Unexpected Architecture${ENDCOLOR}: ${BLUE}${arch}${ENDCOLOR}"
        # exit
    fi
}

ARCH=$(get_architecture)

ABS_PATH_BSE=$(dirname "$0")
cd "$(dirname "$0")"
echo -e "Host: ${BLUE}$(hostname)${ENDCOLOR}"
echo -e "Architecture ${YELLOW}${ARCH}${ENDCOLOR}"
echo -e "Current Working Dir: ${BLUE}$(pwd)${ENDCOLOR}"
echo -e "Absolute Path Base: ${BLUE}${ABS_PATH_BSE}${ENDCOLOR}"
echo ""

CURVER=$(curl --silent https://api.github.com/repos/prometheus/node_exporter/releases | grep -oE '"name": .*' | head -n 1 | grep -oE '[0-9]\.[0-9]\.[0-9]')
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

echo -e "Creating .service file: ${BLUE}/etc/systemd/system/node_exporter.service${ENDCOLOR}"
# /etc/init.d/

echo '#!/sbin/openrc-run

name="Node Exporter"
command="/usr/local/bin/node_exporter"
pidfile="/run/${RC_SVCNAME}.pid"
command_background=true' | tee /etc/init.d/node_exporter > /dev/null 2>&1

chmod +x /etc/init.d/node_exporter
rc-update add node_exporter default
# to remove
# rc-update del node_exporter
service node_exporter start