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

# see releases via:
# https://opensearch.org/lines/2x.html

# verify prereqs are present
sudo apt-get update && sudo apt-get -y install lsb-release ca-certificates curl gnupg2

# download signing key
curl -o- https://artifacts.opensearch.org/publickeys/opensearch.pgp | sudo gpg --dearmor --batch --yes -o /usr/share/keyrings/opensearch-keyring

# create repository file
echo "deb [signed-by=/usr/share/keyrings/opensearch-keyring] https://artifacts.opensearch.org/releases/bundle/opensearch-dashboards/2.x/apt stable main" | sudo tee /etc/apt/sources.list.d/opensearch-dashboards-2.x.list

# install opensearch
sudo apt-get update && sudo apt-get -y install opensearch-dashboards

# Bind Publicly
sudo tee /etc/opensearch-dashboards/opensearch_dashboards.yml<<EOF
---
server.port: 5601
server.host: "0.0.0.0"
opensearch.hosts: ["http://127.0.0.1:9200"]
opensearch.ssl.verificationMode: none
opensearch.username: kibanaserver
opensearch.password: kibanaserver
EOF

# remove the security plugin so we can login
# sudo rm -rf /usr/share/opensearch-dashboards/plugins/securityDashboards

# enable and start service
sudo systemctl daemon-reload
sudo systemctl enable opensearch-dashboards
sudo systemctl start opensearch-dashboards
echo -e "${BLUE}opensearch-dashboards${NC} should now be accessible on TCP Port :${GREEN}5601${NC}"
echo -e "${YELLOW}username${NC}: ${GREEN}kibanaserver${NC}"
echo -e "${YELLOW}password${NC}: ${GREEN}kibanaserver${NC}"
