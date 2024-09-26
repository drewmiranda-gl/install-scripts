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

echo PLEASE NOTE:
echo you MUST configure json exporter config using
echo /usr/local/bin/json_exporter_config.yml
read -p "Confirmation 1 of 2: Press [Enter] key to continue..."
read -p "Confirmation 2 of 2: Press [Enter] key to continue..."

CURVER=$(curl --silent https://api.github.com/repos/prometheus-community/json_exporter/releases | grep -oP '"name": .*' | head -n 1 | grep -oP '[0-9]\.[0-9]\.[0-9]')
DLURL="https://github.com/prometheus-community/json_exporter/releases/download/v${CURVER}/json_exporter-${CURVER}.linux-amd64.tar.gz"
wget $DLURL

for file in json_exporter-*.linux-amd64.tar.gz; do tar -zxf "$file"; done
cd=$(ls -d json_exporter-*.linux-amd64)
cd $cd

sudo cp -f json_exporter /usr/local/bin/

sudo useradd --system prometheus

sudo tee /etc/systemd/system/json_exporter.service<<EOF
[Unit]
Description=Prometheus JSON Exporter Service
After=network.target

[Service]
Type=simple
User=prometheus
ExecStart=/usr/local/bin/json_exporter --config.file="/usr/local/bin/json_exporter_config.yml"

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
# sudo systemctl start json_exporter
# sudo systemctl enable json_exporter

echo Listening on TCP 7979 by default
