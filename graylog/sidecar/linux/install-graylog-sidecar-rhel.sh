#!/bin/bash

REPO_BASE="https://packages.graylog2.org"
LATEST_REPO_URL=$(curl "${REPO_BASE}/packages" 2>/dev/null | grep "graylog-sidecar-repository" | grep -oP 'href=".*"' | grep "rpm" | sort -r | head -n 1 | sed 's/^href="//' | sed 's/"$//')

sudo rpm -Uvh "${REPO_BASE}${LATEST_REPO_URL}"
sudo yum install -y graylog-sidecar

# Set API URL
echo -ne "Enter Graylog API\nExample: http://hostname.domain.tld:port/api/\nNOTE: must include trailing slash / at end\nAPI Url: " && tmp=$(head -1 </dev/stdin | sed -r 's/\//\\\//g') && sudo sed -i "s/.*server_url:.*/server_url: \"$tmp\"/g" /etc/graylog/sidecar/sidecar.yml

# Set API Token
echo -n "Enter Graylog API Token: " && tmp=$(head -1 </dev/stdin) && sudo sed -i "s/.*server_api_token:.*/server_api_token: \"$tmp\"/g" /etc/graylog/sidecar/sidecar.yml

sudo graylog-sidecar -service install
sudo systemctl enable graylog-sidecar --now