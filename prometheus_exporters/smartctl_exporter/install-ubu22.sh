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

# echo please download release from
# echo https://github.com/prometheus-community/smartctl_exporter/releases/tag/v0.12.0
# echo e.g.
# echo "wget https://...."
# read -p "Confirmation 1 of 2: Press [Enter] key to continue..."
# read -p "Confirmation 2 of 2: Press [Enter] key to continue..."

CURVER=$(curl --silent https://api.github.com/repos/prometheus-community/smartctl_exporter/releases | grep -oP '"name": .*' | grep -P 'linux-amd64' | head -n 1 | grep -oP '\d+\.\d+\.\d+')
DLURL="https://github.com/prometheus-community/smartctl_exporter/releases/download/v${CURVER}/smartctl_exporter-${CURVER}.linux-amd64.tar.gz"
wget $DLURL

for file in smartctl_exporter-*linux-amd64.tar.gz; do tar -zxf "$file"; done
cd=$(ls -d smartctl_exporter-*linux-amd64)
cd $cd
sudo cp -f smartctl_exporter /usr/local/bin/

sudo tee /etc/systemd/system/smartctl_exporter.service<<EOF
[Unit]
Description=Smartctl Exporter
After=network.target
StartLimitIntervalSec=30
StartLimitBurst=3

[Service]
User=root
Group=root
Type=simple
ExecStart=/usr/local/bin/smartctl_exporter
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl start smartctl_exporter
sudo systemctl enable smartctl_exporter

echo Listening on TCP 9633 by default
