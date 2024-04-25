# Stop and Disable Elasticsearch
sudo systemctl stop elasticsearch
sudo systemctl disable elasticsearch

# START OpenSearch Install START ==============================================
# Install OpenSearch 1.x
# verify prereqs are present
sudo apt-get update && sudo apt-get -y install lsb-release ca-certificates curl gnupg2

# download signing key
curl -o- https://artifacts.opensearch.org/publickeys/opensearch.pgp | sudo gpg --dearmor --batch --yes -o /usr/share/keyrings/opensearch-keyring

# create repository file
echo "deb [signed-by=/usr/share/keyrings/opensearch-keyring] https://artifacts.opensearch.org/releases/bundle/opensearch/1.x/apt stable main" | sudo tee /etc/apt/sources.list.d/opensearch-1.x.list

# install opensearch
sudo apt-get update
sudo apt-get -y install opensearch
# END OpenSearch Install END ==================================================

# Change Owner of existing data dir to OpenSearch
sudo chown -R opensearch:opensearch /var/lib/elasticsearch

# Configure OpenSearch

sudo cp /etc/opensearch/opensearch.yml /etc/opensearch/opensearch.yml.bak

echo "cluster.name: graylog
node.name: ${HOSTNAME}
path.data: /var/lib/elasticsearch
path.logs: /var/log/opensearch
transport.host: 0.0.0.0
network.host: 0.0.0.0
http.port: 9200
discovery.type: single-node
action.auto_create_index: false
plugins.security.disabled: true
indices.query.bool.max_clause_count: 32768" | sudo tee /etc/opensearch/opensearch.yml

# required settings
sudo sysctl -w vm.max_map_count=262144
echo 'vm.max_map_count=262144' | sudo tee -a /etc/sysctl.conf

# Enable and Start OpenSearch
sudo systemctl enable opensearch
sudo systemctl start opensearch