See https://github.com/prometheus-community/node-exporter-textfile-collector-scripts

Reccomend using sponge:

```
sudo apt update && sudo apt install moreutils -y
```

configure node_exporter:

```bash
--collector.textfile.directory
```

```bash
# /var/lib/node_exporter/textfiles

sudo mkdir -p /var/lib/node_exporter/textfiles
sudo chown node_exporter:node_exporter -R /var/lib/node_exporter

# systemctl status node_exporter

# --collector.textfile.directory="/var/lib/node_exporter/textfiles"
# */60 * * * * bash /var/lib/node_exporter/smartmon.sh | sponge /var/lib/node_exporter/textfiles/smartmon.prom >/dev/null 2>&1
```