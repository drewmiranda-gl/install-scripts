#!/bin/bash

RED="\e[31m"
# ${RED}

GREEN="\e[32m"
# ${GREEN}

BLUE="\e[34m"
# ${BLUE}

YELLOW="\e[33m"
# ${YELLOW}

ENDCOLOR="\e[0m"
# ${ENDCOLOR}

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

  echo ""
  echo ""
  echo -e "Connecting to ${GREEN}$HOST${ENDCOLOR}..."
  ssh drew@${HOST} "
  rm -f install-node_exporter-ubu22.sh \
      && wget --quiet https://raw.githubusercontent.com/drewmiranda-gl/install-scripts/refs/heads/main/prometheus_exporters/node_exporter/install-node_exporter-ubu22.sh \
      && sudo bash install-node_exporter-ubu22.sh
  "

done