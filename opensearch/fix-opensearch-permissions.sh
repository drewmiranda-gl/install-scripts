#!/bin/bash

root_check() {
    get_curusr=$(whoami)
    if [ $get_curusr == "root" ]
    then
        ok="okhere"
    else
        echo "ERROR! Please run as root."
        echo "Try: 'su' to elevate and then run install script again."
	echo "OR bash $0"
        exit 1
    fi
}
root_check

chown -R opensearch:opensearch /usr/share/opensearch
chown -R opensearch:opensearch /etc/opensearch
chown -R opensearch:opensearch /var/lib/opensearch
chown -R opensearch:opensearch /var/log/opensearch
chown -R opensearch:opensearch /var/run/opensearch
chown -R opensearch:opensearch /dev/shm/performanceanalyzer
