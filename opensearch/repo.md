# 3.x

```
sudo mkdir -p /etc/apt/keyrings
 curl -fsSL https://artifacts.opensearch.org/publickeys/opensearch-release.pgp \
 | sudo gpg --dearmor -o /etc/apt/keyrings/opensearch.gpg

echo "deb [signed-by=/etc/apt/keyrings/opensearch.gpg] https://artifacts.opensearch.org/releases/bundle/opensearch/3.x/apt stable main" \
| sudo tee /etc/apt/sources.list.d/opensearch-3.x.list
```

deb [signed-by=/etc/apt/keyrings/opensearch.gpg] https://artifacts.opensearch.org/releases/bundle/opensearch-dashboards/3.x/apt stable main
deb [signed-by=/usr/share/keyrings/opensearch-keyring] https://artifacts.opensearch.org/releases/bundle/opensearch-dashboards/3.x/apt stable main