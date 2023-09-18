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

apt update
apt-get install -y openjdk-17-jdk-headless

wget https://packages.graylog2.org/repo/packages/graylog-forwarder-repository_5-1_all.deb && \
    dpkg -i graylog-forwarder-repository_5-1_all.deb && \
    apt-get update && \
    apt-get install -y graylog-forwarder

sed -i '/^LimitNOFILE=64000.*/a AmbientCapabilities=CAP_NET_BIND_SERVICE' /usr/lib/systemd/system/graylog-forwarder.service && \
    systemctl daemon-reload

echo -ne "Enter Graylog forwarder_server_hostname: " && tmp=$(head -1 </dev/stdin) && \
    sed -i "s/^forwarder_server_hostname.*/forwarder_server_hostname = $tmp/g" /etc/graylog/forwarder/forwarder.conf

echo -ne "Enter Graylog forwarder_grpc_api_token: " && tmp=$(head -1 </dev/stdin) && \
    sed -i "s/^forwarder_grpc_api_token.*/forwarder_grpc_api_token = $tmp/g" /etc/graylog/forwarder/forwarder.conf
