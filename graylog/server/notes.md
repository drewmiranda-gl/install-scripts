# Quick test of < 4

Graylog docker images only go back to v4.0.1. Unfortunately this means that quickly testing older versions of graylog (< 4) require a non docker install.

Quick notes on how to do this quickly:

## Prerequisites

Update everything: 

```
sudo apt-get update && sudo apt-get upgrade
```

Using docker:

```yml
services:
  mongodb:
    container_name: graydock-mongo
    deploy:
      resources:
        limits:
          memory: 256m
    image: mongo:4.2
    ports:
    - 27021:27017
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
version: '3.8'
```

Additional:

```
sudo apt-get install -y openjdk-8-jre-headless uuid-runtime pwgen
```

## Install Graylog

1. Find version via https://packages.graylog2.org/debian/pool/stable
2. Download the applicable graylog-server_*.deb file
    * `wget ...`
3. Install
    `dpkg -i filename.deb`

## Configure

[Borrowing from myself](https://github.com/Graylog2/se-poc-docs/blob/main/src/On%20Prem%20POC/installing%20graylog-server.md)...

Set admin password:

```
sudo cp /etc/graylog/server/server.conf server.conf.bak
echo -n "Enter admin Password: " && tmppw=$(head -1 </dev/stdin | tr -d '\n' | sha256sum | cut -d" " -f1) && sudo sed -i "s/root_password_sha2 =.*/root_password_sha2 = $tmppw/g" /etc/graylog/server/server.conf
```

Set password secret:

```
tmppw=$(openssl rand -hex 32)
sudo sed -i "s/password_secret =.*/password_secret = $tmppw/g" /etc/graylog/server/server.conf
tmppw=abc
```

Bind IP to actual IP of server. Typically we'd use `0.0.0.0`, however, docker network interfaces cause issues with this.

```
tmp_get_real_ip=$(ip route get 1.2.3.4 | awk '{print $7}' | grep -oP [0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\})
sudo sed -i "s/.*http_bind_address = [[:digit:]].[[:digit:]].[[:digit:]].[[:digit:]].*/http_bind_address = $tmp_get_real_ip:9000/g" /etc/graylog/server/server.conf
```

## Start Graylog

```
sudo systemctl start graylog-server
```
