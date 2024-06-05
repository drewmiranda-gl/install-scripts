# Intro

The following is experimental and meant for testing or other non production uses.

This page walks through a proof of concept of booting graylog forwarder on pfSense's FreeBSD

Its important to note that pfSense is an entire operating system and is built on FreeBSD. This means we cannot use quality of life capabilities such as a package manager to install Graylog Forwarder. Instead, we will need to use the tarball and execute this using `java` from OpenJDK.

# Prereqs

## FreeBSD pkg repo

Graylog (and Graylog Forwarder) are built using Java, they require OpenJDK in order to "boot". Graylog packages now include their own bundled version of the jdk and no longer require separate install.

However, as we are installing on pfSense, which is build on FreeBSD, we must install OpenJDK to satisfy this requirement. We will install openjdk17.

For more information installing FreeBSD pacakges on pfsense, see [Using software from FreeBSD](https://docs.netgate.com/pfsense/en/latest/recipes/freebsd-pkg-repo.html) from Netgate's public documentation.

To get started, enable FreeBSD packages in the following files:

* `/usr/local/etc/pkg/repos/pfSense.conf`
* `/usr/local/etc/pkg/repos/FreeBSD.conf`

And change

```
FreeBSD: { enabled: no }
```

to

```
FreeBSD: { enabled: yes }
```

For reference, i've also seen recommendations to configure `/usr/local/etc/pkg/repos/FreeBSD.conf` as such:

```
FreeBSD: {
  url: "pkg+http://pkg.FreeBSD.org/${ABI}/latest",
  mirror_type: "srv",
  signature_type: "fingerprints",
  fingerprints: "/usr/share/keys/pkg",
  enabled: yes
}
```

I'm noting this for reference but will remove if this is superfluous.

## Install openjdk17

```
# update repos
pkg update

# install openjdk
pkg install openjdk17
```

## Proc Path

Graylog Forwarder will throw an error if `/proc` does not exist.

```
mkdir /proc
```

# Install and Configure Graylog Forwarder

## Download and extract

no idea how to actually do this without being employed here :)

```
curl -O -L <url>
```

```
gzip -d <filename.tgz.gz>
```

```
tar -xf <filename.tgz>
```

## log4j2.xml

## forwarder.conf

## Execute

Example for reference:

```
/usr/local/bin/java -Xms1g -Xmx1g -XX:-OmitStackTraceInFastThrow -Djdk.tls.acknowledgeCloseNotify=true -Dlog4j2.formatMsgNoLookups=true -Dlog4j.configurationFile=file:///root/tmp/log4j2.xml -jar /root/tmp/graylog-forwarder.jar run -f /root/tmp/forwarder.conf
```