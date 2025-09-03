# mongod.conf

```sh
vi /etc/mongod.conf
```

```yaml
systemLog:
  destination: file
  logAppend: true
  path: /var/log/mongodb/mongod.log
  logRotate: reopen
```

Important part is adding `logRotate: reopen`

You can use a `sed` command to automation this:

```sh
cat /etc/mongod.conf | grep "logRotate" || sudo sed -i '/^[[:space:]]*systemLog:/,/^[^[:space:]]/ {
    /logRotate:[[:space:]]*reopen/! {
        /path:/a\ \ logRotate: reopen
    }
}' /etc/mongod.conf
```

This requires restarting `mongod`

```sh
# make sure you stepdown the primary!
# rs.stepDown()
sudo systemctl restart mongod
```

# logrotate

```sh
echo "/var/log/mongodb/*.log {
    rotate 30
    size 50M
    compress
    dateext
    missingok
    notifempty
    sharedscripts
    postrotate
        /bin/kill -SIGUSR1 \`cat /var/lib/mongodb/mongod.lock 2> /dev/null\` 2> /dev/null || true
    endscript
}
" | sudo tee /etc/logrotate.d/mongod
```

Verify config works, do a dry run:

```sh
sudo logrotate -d /etc/logrotate.d/mongod
```

To force mongo to "rotate" its log file immediately, via `mongosh`:

```sh
db.adminCommand({ logRotate: 1 })
```