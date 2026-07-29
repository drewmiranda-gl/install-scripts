# Introduction

This document covers the basics of upgrading a self-managed MongoDB node from 5 to 6. Please rememeber to make a backup of your mongo database and/or snapshot your server/vm.

These steps have been adapted from [mongo's own documentation](https://www.mongodb.com/docs/v6.0/tutorial/upgrade-revision/).

Please take care to review [Compatibility Changes in MongoDB 6.0](https://www.mongodb.com/docs/v6.0/release-notes/6.0-compatibility/)

# Potential Upgrade Issues

## fork: true

If you upgrade an existing instance of MongoDB to MongoDB 6.0.5, that instance may fail to start if `fork: true` is set in the `mongod.conf` file.

The upgrade issue affects all MongoDB instances that use `.deb` or `.rpm` installation packages. Installations that use the tarball (`.tgz)` release or other package types are not affected. For more information, see [SERVER-74345](https://jira.mongodb.org/browse/SERVER-74345).

To remove the `fork: true` setting, run these commands from a system terminal:

```sh
systemctl stop mongod.service
sudo sed -i.bak '/fork: true/d' /etc/mongod.conf
systemctl start mongod.service
```

# Ensure Compatibility set to 5.0

```sh
mongosh --quiet --eval 'db.adminCommand( { getParameter: 1, featureCompatibilityVersion: 1 } )'
```

IF output is NOT

```json
{ featureCompatibilityVersion: { version: '5.0' }, ok: 1 }
```

SET correct compatibility version:

```sh
db.adminCommand( { setFeatureCompatibilityVersion: "5.0" } )
```

# Install Repo for 6.0

```sh
curl -fsSL https://pgp.mongodb.com/server-6.0.asc | \
   sudo gpg -o /usr/share/keyrings/mongodb-server-6.0.gpg \
   --dearmor
```

Only for Ubuntu 20 (Focal)
```
# for reference, via https://www.mongodb.com/docs/v6.0/tutorial/install-mongodb-on-ubuntu/
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-6.0.gpg ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
```

Only for Ubuntu 22 (Jammy)

```
# for reference, via https://www.mongodb.com/docs/v6.0/tutorial/install-mongodb-on-ubuntu/
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-6.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
```

```
sudo apt update
```

# Perform Upgrade

Install updated binary files:

```sh
sudo apt install mongodb-org-database-tools-extra mongodb-org-database mongodb-org-mongos mongodb-org-server mongodb-org-shell mongodb-org-tools mongodb-org
```

NOTE: the above list is obtained by running:

```sh
apt list --upgradable | grep mongo
```

Restart MongoD to run new version:

```sh
sudo systemctl restart mongod
```

After restart, verify service is active (running):

```sh
systemctl status mongod --no-pager
```

Set compatibility version to latest:

```sh
mongosh --quiet --eval 'db.adminCommand( { setFeatureCompatibilityVersion: "6.0" } )'
```

Verify compatibility version is updated:

```sh
mongosh --quiet --eval 'db.adminCommand( { getParameter: 1, featureCompatibilityVersion: 1 } )'
```

Should output something like

```json
{ featureCompatibilityVersion: { version: '6.0' }, ok: 1 }
```

# Cleanup

Remove old apt list file

```sh
sudo rm -f /etc/apt/sources.list.d/mongodb-org-5.0.list 2>/dev/null
```