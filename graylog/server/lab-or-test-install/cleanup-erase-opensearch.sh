#!/bin/bash

RED='\033[0;31m'
NC='\033[0m' # No Color

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

printf "${RED}WARNING! This will ERASE the entire contents of OpenSearch${NC}\n"
echo "This cannot be undone!"
read -p "Confirmation 1 of 2: Press [Enter] key to confirm..."
read -p "Confirmation 2 of 2: Press [Enter] key to confirm..."

echo "Stopping OpenSearch..."
systemctl stop opensearch
rm -rf /var/lib/opensearch/nodes/0
echo "Starting OpenSearch..."
systemctl start opensearch
