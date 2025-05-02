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
NC='\e[0m' # No Color
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

printf "${RED}WARNING! This will ERASE the entire contents of Mongo Graylog and Data Node OpenSearch${NC}\n"
echo "This cannot be undone!"
echo -e "${YELLOW}MAKE Sure you STOP ALL graylog and datanode services before continuing...${NC}"
echo "sudo systemctl stop graylog-server"
echo "sudo systemctl stop graylog-datanode"
read -p "Confirmation 1 of 2: Press [Enter] key to confirm..."
read -p "Confirmation 2 of 2: Press [Enter] key to confirm..."

if [ -f "/lib/systemd/system/mongod.service" ]; then
    echo -e "${BLUE}MongoD found${NC}, ${RED}Deleting Graylog db${NC}"
    mongosh graylog --eval 'db.dropDatabase()'
fi

if [ -f "/lib/systemd/system/mongod.service" ]; then
    echo -e "${BLUE}Datanode found${NC}, ${RED}Deleting Data Dirs${NC}"
    
    echo -e "Deleting ${BLUE}/var/lib/graylog-datanode/opensearch/config/*${NC}"
    rm -rf /var/lib/graylog-datanode/opensearch/config/*

    echo -e "Deleting ${BLUE}/var/lib/graylog-datanode/opensearch/data/*${NC}"
    rm -rf /var/lib/graylog-datanode/opensearch/data/*
fi