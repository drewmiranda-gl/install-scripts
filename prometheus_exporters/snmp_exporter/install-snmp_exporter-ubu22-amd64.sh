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

echo please download release from
echo https://github.com/prometheus/snmp_exporter/releases/
echo e.g.
echo "wget https://...."
read -p "Confirmation 1 of 2: Press [Enter] key to continue..."
read -p "Confirmation 2 of 2: Press [Enter] key to continue..."
wget https://github.com/prometheus/snmp_exporter/releases/download/v0.26.0/snmp_exporter-0.26.0.linux-amd64.tar.gz
for file in snmp_exporter-*linux-amd64.tar.gz; do tar -zxf "$file"; done
cd=$(ls -d snmp_exporter-*linux-amd64)
cd $cd

sudo cp -f snmp_exporter /usr/local/bin/
sudo cp -f snmp.yml /usr/local/bin/

sudo useradd --system prometheus

sudo tee /etc/systemd/system/snmp_exporter.service<<EOF
[Unit]
Description=Prometheus SNMP Exporter Service
After=network.target
StartLimitIntervalSec=30
StartLimitBurst=3

[Service]
Type=simple
User=prometheus
ExecStart=/usr/local/bin/snmp_exporter \
    --config.file="/usr/local/bin/snmp.yml"
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl start snmp_exporter
sudo systemctl enable snmp_exporter

echo Listening on TCP 9116 by default
