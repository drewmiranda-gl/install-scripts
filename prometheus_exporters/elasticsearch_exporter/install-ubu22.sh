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
echo https://github.com/prometheus-community/elasticsearch_exporter/releases
echo e.g.
echo "wget https://...."
read -p "Confirmation 1 of 2: Press [Enter] key to continue..."
read -p "Confirmation 2 of 2: Press [Enter] key to continue..."

for file in elasticsearch_exporter-*linux-amd64.tar.gz; do tar -zxf "$file"; done
cd=$(ls -d elasticsearch_exporter-*linux-amd64)
cd $cd
sudo cp elasticsearch_exporter /usr/local/bin/

sudo useradd -rs /bin/false elasticsearch_exporter

sudo tee /etc/systemd/system/elasticsearch_exporter.service<<EOF
[Unit]
Description=Node Exporter
After=network.target
 
[Service]
User=elasticsearch_exporter
Group=elasticsearch_exporter
Type=simple
ExecStart=/usr/local/bin/elasticsearch_exporter
 
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl start elasticsearch_exporter
sudo systemctl enable elasticsearch_exporter
