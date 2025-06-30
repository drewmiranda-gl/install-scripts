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
echo https://github.com/percona/mongodb_exporter/releases
echo e.g.
echo "wget https://...."
read -p "Confirmation 1 of 2: Press [Enter] key to continue..."
read -p "Confirmation 2 of 2: Press [Enter] key to continue..."

debfile=$(ls mongodb_exporter-*.linux-64-bit.deb | sort | head -n 1)
sudo dpkg -i $debfile
sudo systemctl daemon-reload

sudo tee /etc/systemd/system/mongodb_exporter.service<<EOF
[Unit]
Description=MongoDB Exporter
After=network.target
StartLimitIntervalSec=30
StartLimitBurst=3

[Service]
User=mongodb_exporter
Type=simple
ExecStart=/usr/bin/mongodb_exporter \
    --mongodb.uri=mongodb://127.0.0.1:27017 \
    --discovering-mode \
    --collect-all
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl start mongodb_exporter
sudo systemctl enable mongodb_exporter
