# Introduction

This document covers the basics of upgrading a self-managed MongoDB node from 6 to 7. Please rememeber to make a backup of your mongo database and/or snapshot your server/vm.

These steps have been adapted from mongo's own documentation.

See https://www.mongodb.com/docs/v7.0/tutorial/upgrade-revision/

Please take care to review [Compatibility Changes in MongoDB 7.0](https://www.mongodb.com/docs/v7.0/release-notes/7.0-compatibility/)

# Ensure Compatibility set to 6.0

```sh
mongosh --quiet --eval 'db.adminCommand( { getParameter: 1, featureCompatibilityVersion: 1 } )'
```

IF output is NOT

```json
{ featureCompatibilityVersion: { version: '6.0' }, ok: 1 }
```

SET correct compatibility version:

```sh
db.adminCommand( { setFeatureCompatibilityVersion: "6.0" } )
```

# Install Repo for 7.0

```sh
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | \
   sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg \
   --dearmor
```

Only for Ubuntu 20 (Focal)
```
# for reference, via https://www.mongodb.com/docs/v7.0/tutorial/install-mongodb-on-ubuntu/
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
```

Only for Ubuntu 22 (Jammy)

```
# for reference, via https://www.mongodb.com/docs/v7.0/tutorial/install-mongodb-on-ubuntu/
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
```

```sh
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
mongosh --quiet --eval 'db.adminCommand( { setFeatureCompatibilityVersion: "7.0", confirm: true } )'
```

Verify compatibility version is updated:

```sh
mongosh --quiet --eval 'db.adminCommand( { getParameter: 1, featureCompatibilityVersion: 1 } )'
```

Should output something like

```json
{ featureCompatibilityVersion: { version: '7.0' }, ok: 1 }
```

# Cleanup

Remove old apt list file

```sh
sudo rm -f /etc/apt/sources.list.d/mongodb-org-6.0.list 2>/dev/null
```