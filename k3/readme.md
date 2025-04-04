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

# Instal k9s

```sh
# https://github.com/derailed/k9s/releases
DLURL=$(curl --silent https://api.github.com/repos/derailed/k9s/releases | grep -i "k9s_linux_amd64.deb" | head -n 2 | grep -i "browser_download_url" | sed -E 's/.*"browser_download_url": "(.*)"/\1/')
FILENAMEONLY=$(basename ${DLURL})
wget $DLURL
dpkg -i $FILENAMEONLY
```

Open k9s at least once to pre-populate config file: `~/.config/k9s/config.yaml`

Change logger options if you wish:

```
k9s:
  logger:
    tail: 
    buffer: 
```