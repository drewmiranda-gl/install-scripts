#!/bin/bash

HOSTS_FILE="$1"

# Check if filename is passed as an argument
if [ $# -ne 1 ]; then
  echo "Usage: $0 <hostnames_file>"
  exit 1
fi

# Open file descriptor 3 for reading from the file
exec 3< "$HOSTS_FILE"

# Check if the file exists
if [ ! -f "$HOSTS_FILE" ]; then
  echo "File not found: $HOSTS_FILE"
  exit 1
fi

while IFS= read -r HOST <&3; do
  [ -z "$HOST" ] && continue

  echo "Connecting to $HOST..."
  ssh drew@${HOST} "
  rm -f install-node_exporter-ubu22.sh \
      && wget https://raw.githubusercontent.com/drewmiranda-gl/install-scripts/refs/heads/main/prometheus_exporters/node_exporter/install-node_exporter-ubu22.sh \
      && sudo bash install-node_exporter-ubu22.sh
  "

done