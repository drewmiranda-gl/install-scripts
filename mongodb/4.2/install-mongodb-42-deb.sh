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

# https://www.mongodb.com/docs/v4.2/tutorial/install-mongodb-on-ubuntu/
# Ubuntu 18

sudo apt-get install gnupg

curl -fsSL https://pgp.mongodb.com/server-4.2.asc | \
   sudo gpg -o /usr/share/keyrings/mongodb-server-4.2.gpg \
   --dearmor

echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-4.2.gpg ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.2.list

sudo apt-get update

sudo apt-get install -y mongodb-org

sudo systemctl daemon-reload
sudo systemctl enable mongod
sudo systemctl start mongod
