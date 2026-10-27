#!/bin/bash
set -e

case "$OSTYPE" in
  darwin*|bsd*)
    # echo "Detected OS: MacOS (${OSTYPE})"
    # CLICOLOR=1
    # export CLICOLOR=1
    # export TERM="xterm-256color"
    # autoload -U colors && colors
    RED="\x1B[31m"
    GREEN="\x1B[32m"
    BLUE="\x1B[34m"
    YELLOW="\x1B[33m"
    ENDCOLOR="\x1B[0m"
    ;;
  *)
    RED="\e[31m"
    GREEN="\e[32m"
    BLUE="\e[34m"
    YELLOW="\e[33m"
    ENDCOLOR="\e[0m"
  ;;
esac

# For Ubuntu Server 24 LTS

# Installs
#   - Prereq OS settings
#   - MongoDB 8
#   - Graylog Data Node 7.3
#   - Graylog Enterprise 7.3

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

# Disk Space Check
target="/"
BYTES_REQ_STRING="10G"
min_bytes=$(numfmt --from=iec "$BYTES_REQ_STRING") || exit 2

avail_bytes=$(( $(df -Pk "$target" | awk 'NR==2 {print $4}') * 1024 ))

echo -e "${YELLOW}Checking for available disk space...${ENDCOLOR}"
if (( avail_bytes < min_bytes )); then
  echo -e "${RED}FAIL${ENDCOLOR}: ${YELLOW}$(numfmt --to=iec "$avail_bytes") free${ENDCOLOR} on ${BLUE}$target${ENDCOLOR}, need ${RED}$BYTES_REQ_STRING${ENDCOLOR}" >&2
  exit 1
else
    echo -e "${GREEN}OK${ENDCOLOR}: ${YELLOW}$(numfmt --to=iec "$avail_bytes") free${ENDCOLOR} on ${BLUE}$target${ENDCOLOR}"
fi


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

sudo systemctl daemon-reload && sudo systemctl start disable-transparent-huge-pages --now
# =============================================================================

# =============================================================================
# MongoDB

# for reference, via https://www.mongodb.com/docs/v8.0/administration/install-community/
curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | \
   sudo gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg \
   --dearmor

echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list

sudo apt update && \
    sudo apt install -y mongodb-org mongodb-mongosh && \
    sudo systemctl daemon-reload && \
    sudo systemctl enable mongod.service --now

# =============================================================================
# DataNode

wget https://packages.graylog2.org/repo/packages/graylog-7.3-repository_latest.deb
sudo dpkg -i graylog-7.3-repository_latest.deb
sudo apt update --allow-releaseinfo-change && sudo apt install -y graylog-datanode

# admin password
tmppw=$(echo "admin" | tr -d '\n' | sha256sum | cut -d" " -f1)
sudo sed -i "s/root_password_sha2 =.*/root_password_sha2 = $tmppw/g" /etc/graylog/datanode/datanode.conf

tmppw=$(openssl rand -hex 32)
sudo sed -i "s/password_secret =.*/password_secret = $tmppw/g" /etc/graylog/datanode/datanode.conf
tmppw=abc

sudo systemctl daemon-reload && sudo systemctl enable graylog-datanode --now

# =============================================================================
# Graylog
# required for reporting
sudo apt-get install -y fontconfig fonts-dejavu
sudo apt install -y graylog-enterprise

sudo cp /etc/graylog/server/server.conf server.conf.bak
sudo sed -i "s/root_password_sha2 =.*/root_password_sha2 = $(cat /etc/graylog/datanode/datanode.conf | grep -P "root_password_sha2 = .*" | sed 's/root_password_sha2 =[[:blank:]]*//g')/g" /etc/graylog/server/server.conf
sudo sed -i "s/password_secret =.*/password_secret = $(cat /etc/graylog/datanode/datanode.conf | grep -P "password_secret = .*" | sed 's/password_secret =[[:blank:]]*//g')/g" /etc/graylog/server/server.conf

sudo sed -i 's/#http_bind_address = 127.0.0.1.*/http_bind_address = 0.0.0.0:9000/g' /etc/graylog/server/server.conf

echo "selfsigned_startup = true" | sudo tee -a /etc/graylog/server/server.conf

sudo systemctl daemon-reload && sudo systemctl enable graylog-server --now

