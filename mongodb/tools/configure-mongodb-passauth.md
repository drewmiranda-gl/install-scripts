# Introduction

This document covers the basics of configuring a MongoDB database to require password authentication.

# Create a MongoD User

The first thing we need to do is create a MongoD user. For full documentation see [db.createUser()](https://www.mongodb.com/docs/manual/reference/method/db.createUser/).

While you can create a user with any name and permissions, my primary focus and use of MongoD is Graylog so that is what I will be using for my examples.

NOTE: be sure to replace `<password>` with the secure random password of your choosing. Make a note of this password as we will need it later.

```js
use admin;
```

```js
db.createUser({
  user: "graylog",
  pwd: "<password>",
  roles: [
      {role: "readWrite", db: "graylog"}
      , { role: "clusterMonitor", db: "admin" }
      , { role: "clusterMonitor", db: "graylog" }
    ]
});
```

After the user has been created, you should see something like `{ ok: 1 }`

To verify the user was created successfully, view all users using `show users`

# Enable authorization for MongoD

## Update MongoD configuration file

NOTE: the following assumes you have a default, out of the box, `mongod.conf` file.

As a root/priveleged user, edit your `mongod.conf` (default: `/etc/mongod.conf`)

and replace

`#security:`

with

```
security:
  authorization: "enabled"
```

**Alternatively**, you can also run the following sed command.

```sh
# make a backup of the exstign mongod.conf file and enable authorization
sudo cp /etc/mongod.conf /etc/mongod.conf.$(date +"%Y-%m-%d_%H-%M-%S").orig && sudo sed -i 's/^#security:$/security:\n  authorization: "enabled"/' /etc/mongod.conf
```

Verify the file has been properly updated:

```sh
sudo cat /etc/mongod.conf | grep -A 1 "security"
```

Should output:

```
security:
  authorization: "enabled"
```

NOTE: At this point, we have not restarted the MongoD service. Until we restart the MongoD service, the above MongoD configuration change will not take effect.

## Update Graylog configuration file.

As a root/priveleged user, edit your `server.conf` (default: `/etc/graylog/server/server.conf`). See also [Default File Locations](https://go2docs.graylog.org/current/setting_up_graylog/default_file_locations.html).

Update your `mongodb_uri` to include the updated mongod connection uri. This will now include the user/password you created/configured earlier.

Updated example:

```
mongodb_uri = mongodb://graylog:<password>@<mongo-server-hostname>:27017/graylog?authSource=admin
```

Note that the word Graylog appears twice above.

1. The first occurance is the username used to authenticate with mongod
2. The second occurance is the database we are both connected to and authenticating against.

After you update your Graylog config file, verify the setting using

```sh
sudo cat /etc/graylog/server/server.conf | grep "^mongodb_uri"
```

Restart Graylog service to apply the changes you made.

```sh
sudo systemctl restart graylog-server
```

NOTE: at this point we still have not enabled enforcement of password authorization for mongod.

## Restart MongoD Service

At this point you should have completed the following:

1. Created a `graylog` user in your MongoD database server
2. Updated your Graylog config to authenticate (which at this time is optional) to mongod using the user's password
3. Restarted Graylog to apply the changes

The last step is to restart the MongoD service so that our first change becomes enforced and users cannot query the Graylog MongoD database without authorization/authentication.

```sh
sudo systemctl restart mongod
``

# Appendix

## Delete a MongoD user

```js
use graylog
db.dropUser("graylog")
```

## Add Roles to user

```js
db.grantRolesToUser('<username>', [{ role: 'dbAdmin', db: 'graylog' }])
```