# Intro

This is useful when you install `graylog-enterprise`
because you may accidentally forget and then when you update by
installing `graylog-sever` it will remove `graylog-enterprise`

# Ubuntu

```shell
echo "Package: graylog-server 
Pin: release *
Pin-Priority: -1" | sudo tee /etc/apt/preferences.d/never_install.pref
```