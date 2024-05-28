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
echo https://github.com/prometheus/mysqld_exporter/releases/
echo e.g.
echo "wget https://...."
read -p "Confirmation 1 of 2: Press [Enter] key to continue..."
read -p "Confirmation 2 of 2: Press [Enter] key to continue..."


for file in mysqld_exporter-*linux-amd64.tar.gz; do tar -zxf "$file"; done
cd=$(ls -d mysqld_exporter-*linux-amd64)
cd $cd
sudo cp -f mysqld_exporter /usr/local/bin/

sudo tee /etc/systemd/system/mysqld_exporter.service<<EOF
[Unit]
Description=Mysqld Exporter
After=network.target
[Service]
User=root
Group=root
Type=simple
ExecStart=/usr/bin/mysqld_exporter --mysqld.address $(/usr/bin/hostname):3306 --config.my-cnf /root/mysqld_exporter.cnf --collect.binlog_size
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl start mysqld_exporter
sudo systemctl enable mysqld_exporter
