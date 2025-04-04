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

## Multi Node

The following will use the root account and requires the ability to login via root. This may not be appropriate in production environments.

Using https://github.com/alexellis/k3sup

```sh
# set a password for root user
sudo passwd root
```

```sh
# unlock root user
sudo passwd -u root
```

```sh
# Modify ssh config to allow root login
# sudo vi /etc/ssh/sshd_config
# PermitRootLogin yes
sudo sed -i '/^#PermitRootLogin prohibit-password$/!b;n;/^PermitRootLogin yes$/!a PermitRootLogin yes' /etc/ssh/sshd_config
sudo systemctl restart sshd
```

FIRST MASTER NODE
```sh
# --host            node name
# --user            user to use for communication
# --cluster         run as a cluster
# --tls-san         subject alt name for cert
# --k3s-extra-args  set roles, such as disallowing pod workloads
k3sup install \
	--host=k3-m1 \
	--user=root \
	--cluster \
	--tls-san k3-lb.geek4u.net \
 	--k3s-extra-args="--node-taint node-role.kubernetes.io/master=true:NoSchedule"
```

JOIN ADDITIONAL MASTER NODES, e.g. 2,3

```sh
k3sup join \
  --host=k3-m2 \
  --server-user=root \
  --server-host=k3-m1.geek4u.net \
  --user=root \
  --server \
  --k3s-extra-args="--node-taint node-role.kubernetes.io/master=true:NoSchedule"

k3sup join \
  --host=k3-m3 \
  --server-user=root \
  --server-host=k3-m1.geek4u.net \
  --user=root \
  --server \
  --k3s-extra-args="--node-taint node-role.kubernetes.io/master=true:NoSchedule"
```

JOIN WORKER NODES

```sh
k3sup join \
	--host=k3-w1 \
	--server-user=root \
	--server-host=k3-m1.geek4u.net \
	--user=root

k3sup join \
	--host=k3-w2 \
	--server-user=root \
	--server-host=k3-m1.geek4u.net \
	--user=root
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