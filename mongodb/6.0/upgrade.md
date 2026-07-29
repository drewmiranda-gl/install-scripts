# Introduction

This document covers the basics of upgrading a self-managed MongoDB node. Please rememeber to make a backup of your mongo database and/or snapshot your server/vm.

These steps have been adapted from mongo's own documentation.

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

NOTE: the following is specifically for **Ubuntu 22 (Jammy)**

```sh
curl -fsSL https://pgp.mongodb.com/server-6.0.asc | \
   sudo gpg -o /usr/share/keyrings/mongodb-server-6.0.gpg \
   --dearmor
```

Only for Ubuntu 20 (Focal)
```
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-6.0.gpg ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
```

Only for Ubuntu 22 (Jammy)

```
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-6.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
```

```
sudo apt update
```

# Perform Upgrade

Install updated binary files:

```sh
sudo apt install mongodb-org mongodb-org-database-tools-extra mongodb-org-database mongodb-org-shell mongodb-org-tools mongodb-org-server mongodb-org-mongos
```

NOTE: the above list is obtained by running:

```sh
apt list --upgradable | grep mongo
```


Restart MongoD to run new version:

```sh
sudo systemctl restart mongod
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