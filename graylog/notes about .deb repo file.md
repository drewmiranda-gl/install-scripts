# Introduction

On Debian based systems (including Ubuntu), Graylog uses .deb` files to install the package repository.

This package, when installed, will create the following file:

`/etc/apt/sources.list./graylog.list`

NOTE: `graylog-6.0-repository_latest.deb` is used as an example in the sections below. To find the latest .deb files, see https://packages.graylog2.org/packages

# Installation

```shell
dpkg -i graylog-6.0-repository_latest.deb
```

# Removal

NOTE: if you manually remove `/etc/apt/sources.list./graylog.list` and then re-run the install command (e.g. `dpkg -i`), this file will NOT be recreated. You must first uninstall/remove the repo package.

To remove:

```shell
sudo apt remove -y graylog-6.0-repository
sudo apt-get clean && sudo apt purge -y graylog-6.0-repository
```

# Searching for repo packages

In the event you are not sure which version of the Graylog repo package is installed:

```shell
apt list --installed | grep -i graylog | grep -i repo
```

This should return something like:

```
graylog-6.0-repository/now 1-1 all [installed,local]
```

Where `graylog-6.0-repository` is the package name.

# Find Residual Config packages

If the repo package is uninstalled (e.g. `apt remove`), the package will still appear when using `apt list`.

To search for Residual Config packages:

```
dpkg -l | grep '^rc' | awk '{print $2}'
```