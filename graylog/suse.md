# Meta

* [Repo files](https://packages.graylog2.org/packages)
* [Enterprise Linux/RHEL full binaries](https://packages.graylog2.org/el)

# Graylog-server

See https://go2docs.graylog.org/current/downloading_and_installing_graylog/suse_installation.htm

```shell
echo '[graylog]
name=graylog
baseurl=https://packages.graylog2.org/repo/el/stable/6.0/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/GPG-KEY-graylog
repo_gpgcheck=0' | sudo tee /etc/zypp/repos.d/graylog.repo
```

Refresh zypper repositories
```shell
sudo zypper --gpg-auto-import-keys ref
```

Install
```shell
sudo zypper install graylog-enterprise
```

## Cannot Enable `graylog-server`

If you receive an error when attempting to `sudo systemctl enable graylog-server`:

```
ln: failed to create symbolic link '/etc/init.d/rc2.d/S50graylog-server': No such file or directory
```

Use the following command to delete the conflicting file

```shell
sudo rm /etc/init.d/graylog-server
```

# Graylog Forwarder

Install OpenJDK

```shell
sudo zypper install java-17-openjdk-headless
```

Create Repo File
```shell
echo '[graylog-forwarder]
name=graylog-forwarder
baseurl=https://packages.graylog2.org/repo/el/forwarder-stable/6/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/GPG-KEY-graylog
repo_gpgcheck=0' | sudo tee /etc/zypp/repos.d/graylog-forwarder.repo
```

Refresh zypper repositories
```shell
sudo zypper --gpg-auto-import-keys ref
```

Install
```shell
sudo zypper install graylog-forwarder
```

NOTE: if you are using `.rpm` files and want to upgrade by installing a newer `.rpm` rile:
```shell
sudo rpm -U --replacefiles --replacepkgs graylog-forwarder-6.0-6.noarch.rpm
```

NOTE: to uninstall:
```shell
sudo rpm -e graylog-forwarder
```