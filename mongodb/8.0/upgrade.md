# Ensure Compatibility set to 7.0

```sh
mongosh --quiet --eval 'db.adminCommand( { getParameter: 1, featureCompatibilityVersion: 1 } )'
```

IF output is NOT

```
{ featureCompatibilityVersion: { version: '7.0' }, ok: 1 }
```

SET correct compatibility version:

```sh
db.adminCommand( { setFeatureCompatibilityVersion: "7.0" } )
```

# Install Repo for 7.0

Updated gpg key
```sh
curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | \
   sudo gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg \
   --dearmor
```

Ubuntu Server 22 Jammy
```sh
# for reference, via https://www.mongodb.com/docs/manual/tutorial/install-mongodb-on-ubuntu/
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/8.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list
```

Ubuntu Server 24 Noble
```sh
# for reference, via https://www.mongodb.com/docs/manual/tutorial/install-mongodb-on-ubuntu/
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list
```

Apt Update
```sh
sudo apt update
```

# Perform Upgrade

Execute `upgrade-minor.sh`

Set compatibility version to latest:

```sh
mongosh --quiet --eval 'db.adminCommand( { setFeatureCompatibilityVersion: "8.0", confirm: true } )'
```

Verify:

```sh
mongosh --quiet --eval 'db.adminCommand( { getParameter: 1, featureCompatibilityVersion: 1 } )'
```