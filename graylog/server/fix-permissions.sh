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

chown -R graylog:graylog /var/log/graylog-server
chown -R graylog:graylog /var/lib/graylog-server
chown -R graylog:graylog /etc/graylog/
chown -R graylog:graylog /usr/share/graylog-server
