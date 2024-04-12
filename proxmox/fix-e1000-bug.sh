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

sudo tee /etc/systemd/system/fix-e1000e.service<<EOF
[Unit]
Description="Fix for ethernet hang errors"
After=network.target
 
[Service]
User=root
Group=root
Type=oneshot
ExecStart=/usr/sbin/ethtool -K enp0s31f6 gso off gro off tso off tx off rx off rx-vlan-offload off tx-vlan-offload off sg off
 
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl start fix-e1000e
sudo systemctl enable fix-e1000e
