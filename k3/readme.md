# Install k3

```sh
curl -sfL https://get.k3s.io | sh -
```

OR install and Join an existing Pod:

```sh
# Obtain token from primary node:
#  cat /var/lib/rancher/k3s/server/node-token
curl -sfL https://get.k3s.io | K3S_URL=https://<master-host>:6443 K3S_TOKEN=<token> sh -
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

```sh
# as root
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
```

