#!/bin/bash

root_check() {
    get_curusr=$(whoami)
    if [ $get_curusr == "root" ]
    then
        ok="okhere"
    else
        echo "ERROR! Please run as root."
        echo "Try: 'sudo su' to elevate and then run install script again."
	echo "OR bash $0"
        exit 1
    fi
}
root_check

# echo please download release from
# echo https://prometheus.io/download/#node_exporter
# echo e.g.
# echo "wget https://...."
# read -p "Confirmation 1 of 2: Press [Enter] key to continue..."
# read -p "Confirmation 2 of 2: Press [Enter] key to continue..."

CURVER=$(curl --silent https://api.github.com/repos/prometheus/node_exporter/releases | grep -oP '"name": .*' | head -n 1 | grep -oP '[0-9]\.[0-9]\.[0-9]')
DLURL="https://github.com/prometheus/node_exporter/releases/download/v${CURVER}/node_exporter-${CURVER}.linux-amd64.tar.gz"
wget $DLURL

for file in node_exporter-*linux-amd64.tar.gz; do tar -zxf "$file"; done
cd=$(ls -d node_exporter-*linux-amd64)
cd $cd
cp -f node_exporter /usr/local/bin/

useradd -rs /bin/false node_exporter

tee /etc/systemd/system/node_exporter.service<<EOF
[Unit]
Description=Node Exporter
After=network.target
 
[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter
 
[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl restart node_exporter
systemctl enable node_exporter
