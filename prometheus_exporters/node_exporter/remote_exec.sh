#!/bin/bash

ssh drew@<hostname> "
rm -f install-node_exporter-ubu22.sh \
    && wget https://raw.githubusercontent.com/drewmiranda-gl/install-scripts/refs/heads/main/prometheus_exporters/node_exporter/install-node_exporter-ubu22.sh \
    && sudo bash install-node_exporter-ubu22.sh
"
