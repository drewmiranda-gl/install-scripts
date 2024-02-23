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

# stop service
echo "Stopping OpenSearch service..."
systemctl stop opensearch

echo "Deleting OpenSearch service"
# delete service
rm -f /lib/systemd/system/opensearch.service
rm -f /etc/init.d/opensearch
systemctl daemon-reload

# remove folders
echo "Deleting /usr/share/opensearch"
rm -rf /usr/share/opensearch

echo "Deleting /etc/opensearch"
rm -rf /etc/opensearch

echo "Deleting /var/lib/opensearch"
rm -rf /var/lib/opensearch

echo "Deleting /var/log/opensearch"
rm -rf /var/log/opensearch

echo "Deleting /var/run/opensearch"
rm -rf /var/run/opensearch

echo "Review/verification of deleted items:"
systemctl status opensearch --no-pager
ls /lib/systemd/system/opensearch.service
ls /etc/init.d/opensearch
ls /usr/share/opensearch
ls /etc/opensearch
ls /var/lib/opensearch
ls /var/log/opensearch
ls /var/run/opensearch
