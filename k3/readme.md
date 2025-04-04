# Install k3

```sh
curl -sfL https://get.k3s.io | sh -
```

OR install and Join an existing Pod:

```sh
# Obtain token from primary node:
#  cat /var/lib/rancher/k3s/server/node-token
curl -sfL https://get.k3s.io | K3S_URL=https://URL:6443 K3S_TOKEN=<token> sh -
```

Set `KUBECONFIG`

```sh
# profile
echo "export KUBECONFIG=/etc/rancher/k3s/k3s.yaml" >> ~/.bashrc
# root
echo "KUBECONFIG=/etc/rancher/k3s/k3s.yaml" | sudo tee -a /etc/environment
```

## Uninstall

```sh
/usr/local/bin/k3s-uninstall.sh
```

# Install Helm

