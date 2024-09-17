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

# =============================================================================
# Docker (to run older mongo and elasticsearch)
# 
# NOTE:
#   - Ubuntu 22 cannot run MongoDB <6
#   - Elasticsearch no longer publish install files for unsupported/end of life versions (e.g. 6.8 7.10)
# 
sudo apt update --allow-releaseinfo-change
sudo apt-get install -y ca-certificates curl gnupg lsb-release

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update --allow-releaseinfo-change
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-compose

sudo mkdir -p /opt/docker/graylog-lab/

echo "services:
  mongodb:
    container_name: graydock-mongo
    deploy:
      resources:
        limits:
          memory: 256m
    image: mongo:4.2
    ports:
    - 27017:27017
    restart: unless-stopped
    volumes:
    - ./storage/graydock-mongo/mongodb:/data/db
  opensearch:
    container_name: graydock-opensearch
    environment:
      DISABLE_INSTALL_DEMO_CONFIG: 'true'
      DISABLE_SECURITY_PLUGIN: 'true'
      OPENSEARCH_JAVA_OPTS: -Xms1g -Xmx1g -Dlog4j2.formatMsgNoLookups=true
      action.auto_create_index: 'false'
      bootstrap.memory_lock: 'true'
      discovery.type: single-node
      http.host: 0.0.0.0
    image: docker.elastic.co/elasticsearch/elasticsearch-oss:6.8.23
    ports:
    - 9200:9200
    - 9300:9300
    restart: unless-stopped
    ulimits:
      memlock:
        hard: -1
        soft: -1
      nofile:
        hard: 65536
        soft: 65536
    volumes:
    - ./storage/graydock-opensearch/opensearchdata:/usr/share/opensearch/data
version: '3.8'" | sudo tee /opt/docker/graylog-lab/graylog-lab-depend-docker-compose.yml

sudo docker compose -f /opt/docker/graylog-lab/graylog-lab-depend-docker-compose.yml up -d

# =============================================================================
# Graylog
wget https://packages.graylog2.org/repo/packages/graylog-3.3-repository_latest.deb
sudo dpkg -i graylog-3.3-repository_latest.deb
sudo apt update && sudo apt install -y graylog-server graylog-integrations-plugins graylog-enterprise-plugins graylog-enterprise-integrations-plugins openjdk-8-jre-headless

sudo cp /etc/graylog/server/server.conf server.conf.bak
tmppw=$(echo "admin" | tr -d '\n' | sha256sum | cut -d" " -f1)
sudo sed -i "s/root_password_sha2 =.*/root_password_sha2 = $tmppw/g" /etc/graylog/server/server.conf

tmppw=$(openssl rand -hex 32)
sudo sed -i "s/password_secret =.*/password_secret = $tmppw/g" /etc/graylog/server/server.conf
tmppw=abc

tmp_ip_bind=$(ip route get 1.2.3.4 | awk '{print $7}' | head -n 1)
sudo sed -i "s/#http_bind_address = 127.0.0.1.*/http_bind_address = ${tmp_ip_bind}:9000/g" /etc/graylog/server/server.conf

tmpip=127.0.0.1
sudo sed -i "s/#elasticsearch_hosts = .*/elasticsearch_hosts = http\:\/\/$tmpip\:9200/g" /etc/graylog/server/server.conf

sudo systemctl daemon-reload
sudo systemctl enable graylog-server
sudo systemctl start graylog-server
