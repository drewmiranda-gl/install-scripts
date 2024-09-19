# Minimum config for install

## Set Admin Password

You will be prompted to input a password. This will set the password used by the default ‘admin’ user account.

```sh
sudo cp /etc/graylog/server/server.conf server.conf.bak
echo -n "Enter admin Password: " && tmppw=$(head -1 </dev/stdin | tr -d '\n' | sha256sum | cut -d" " -f1) && sudo sed -i "s/root_password_sha2 =.*/root_password_sha2 = $tmppw/g" /etc/graylog/server/server.conf

```

## Set password secret (this is used to encrypt passwords for local graylog users)

```sh
tmppw=$(openssl rand -hex 32)
sudo sed -i "s/password_secret =.*/password_secret = $tmppw/g" /etc/graylog/server/server.conf
tmppw=abc

```

## Bind HTTP server to listen for external connections. Otherwise the Graylog server will only be accessible form the server itself.

```sh
sudo sed -i 's/#http_bind_address = 127.0.0.1.*/http_bind_address = 0.0.0.0:9000/g' /etc/graylog/server/server.conf

```

## Configure Opensearch server address

```sh
echo -n "Enter IP of Opensearch Server: " && tmpip=$(head -1 </dev/stdin) && sudo sed -i "s/#elasticsearch_hosts = .*/elasticsearch_hosts = http\:\/\/$tmpip\:9200/g" /etc/graylog/server/server.conf

```

## Configure memory/heap usage

---
⚠️ **NOTE**

The below command will set graylog-server to use 2GB of HEAP.

---

```sh
sudo sed -i 's/-Xmx[0-9]\+g /-Xmx2g /g' /etc/default/graylog-server && sudo sed -i 's/-Xms[0-9]\+g /-Xms2g /g' /etc/default/graylog-server

```

## Enable Service and Start

```sh
sudo systemctl daemon-reload
sudo systemctl enable graylog-server
sudo systemctl start graylog-server

```

## Verify Completion

```sh
curl localhost:9000/api/

```

Should return something like:

```
{"cluster_id":"<clusterid>","node_id":"<nodeid>","version":"<version>"}
```

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
