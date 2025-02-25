#!/bin/bash

# https://www.elastic.co/guide/en/beats/filebeat/current/filebeat-installation-configuration.html

curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-8.8.2-x86_64.rpm
sudo rpm -vi filebeat-8.8.2-x86_64.rpm

# /usr/share/filebeat/bin/filebeat
