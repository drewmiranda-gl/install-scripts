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

sudo docker pull prom/prometheus
sudo docker stop prom
sudo docker rm prom
chown -R nobody:nogroup /etc/prometheus/data
sudo docker run -d -p 9090:9090 --name=prom -v /root/prometheus.yml:/prometheus/prometheus.yml -v /etc/prometheus/data:/prometheus prom/prometheus --storage.tsdb.retention.time=90d --storage.tsdb.path=/prometheus
sudo docker update --restart unless-stopped prom