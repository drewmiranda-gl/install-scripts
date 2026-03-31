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

# Resolve WARN log entry
# 
#  WARN  [AbstractTcpTransport] receiveBufferSize (SO_RCVBUF) for input should be >= X but is Y.
# 
# The maximum socket receive buffer size which may be set by using the SO_RCVBUF socket option
# Applies immediately, does not persist after a reboot
sudo sysctl -w net.core.rmem_max=1048576
# persists on reboot, but does not apply immediately
echo 'net.core.rmem_max=1048576' | sudo tee -a /etc/sysctl.conf

# Requires Java 21
yum install -y java-21-openjdk-headless

rpm -ivh https://downloads.graylog.org/repo/packages/graylog-forwarder-repository-7-1.noarch.rpm
yum install -y graylog-forwarder

echo -ne "Enter Graylog forwarder_server_hostname: " && tmp=$(head -1 </dev/stdin) && \
    sed -i "s/^forwarder_server_hostname.*/forwarder_server_hostname = $tmp/g" /etc/graylog/forwarder/forwarder.conf

echo -ne "Enter Graylog forwarder_grpc_api_token: " && tmp=$(head -1 </dev/stdin) && \
    sed -i "s/^forwarder_grpc_api_token.*/forwarder_grpc_api_token = $tmp/g" /etc/graylog/forwarder/forwarder.conf

echo "Don't forget to enable/start your forwarder:"
echo 'sudo systemctl enable graylog-forwarder'
echo 'sudo systemctl start graylog-forwarder'
