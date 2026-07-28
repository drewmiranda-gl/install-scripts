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
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-6.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list

sudo apt update
```

# Perform Upgrade

Execute `upgrade-minor.sh`

NOTE: the above script does the following:
1. generate a list of installed mongo packages that are eligble for upgrade
   * `list --upgradable | grep mongo`
2. Runs an upgrade command for the packages found from above
   * `sudo apt install package1 pacakge2 package3`

Note that the reason we cannot document an explicit list of packages is that the list of items may change (items added, items removed) or the names of packages may change.

For reference only, here are a list of mongo package names.

```
mongodb-org
mongodb-mongosh
mongodb-database-tools
mongodb-org-database
mongodb-org-database-tools-extra
mongodb-org-mongos
mongodb-org-server
mongodb-org-shell
mongodb-org-tools
```

Restart MongoD to run new version:

```sh
sudo systemctl restart mongod
```

Set compatibility version to latest:

```sh
mongosh --quiet --eval 'db.adminCommand( { setFeatureCompatibilityVersion: "6.0", confirm: true } )'
```

Verify compatibility version is updated:

```sh
mongosh --quiet --eval 'db.adminCommand( { getParameter: 1, featureCompatibilityVersion: 1 } )'
```

Should output something like

```json
{ featureCompatibilityVersion: { version: '6.0' }, ok: 1 }
```