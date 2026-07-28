# Introduction

> The Uncomplicated Firewall (ufw) is a frontend for iptables and is particularly well-suited for host-based firewalls. ufw provides a framework for managing netfilter, as well as a command-line interface for manipulating the firewall. ufw aims to provide an easy to use interface for people unfamiliar with firewall concepts, while at the same time simplifies complicated iptables commands to help an administrator who knows what he or she is doing. ufw is an upstream for other distributions and graphical frontends.
>
> --https://wiki.ubuntu.com/UncomplicatedFirewall

By default:
- ufw is disabled
- no rules are configured
- if ufw is enbabled, and no rules are configured, ALL external inbound network traffic is blocked
- all INCOMING network traffic without an explicit allow rule is blocked
- all OUTGOING network traffic is allowed

# How to go about enabling ufw and configuring rules

## Assess what ports your server is listening on

Use `ss` to assess what ports are lisetning for connections:

```sh
(echo "PORT PROCESSES"; sudo ss -tulpn | grep "LISTEN" | awk '{n=split($5,a,":"); sub(/^users:/,"",$NF); print a[n], $NF}') | column -t
```

If you have issues with the above command you can try a more bare version, though the output isn't as neatly formatted:

```sh
sudo ss -tulpn | grep "LISTEN"
```

This will output a list of ports and processes. make a list of any ports that need to be reached by device on the network. A firewall rule is required for each port you want to allow.

Some examples:

```sh
# Graylog Web Interface default HTTP port
# allows TCP port 9000
sudo ufw allow 9000/tcp
```

## Enabling ufw

Temporarily enable ufw for only 30 seconds, then disable it again. This allows you to verify you can still reach the device with the firewall enabled. If you lose connectivity, the firewall will be disabled and you can add the appropriate firewall rule.

```sh
sudo bash -c 'sleep 30 && ufw disable' &
disown
sudo ufw enable
```

If the above test is successful: enable ufw permanently with

```sh
sudo ufw enable
```

## Verify status of ufw

When ufw is enabled, we can view the status of the configure firewall rules using:

```sh
sudo ufw status numbered
```

# Common Commands

## View Status

```sh
sudo ufw status
```

Common outputs:

* `Status: inactive`
    * firewall is inactive
    * no rules are applied. even if rules are added they will not apply until ufw is "enabled"
* `Status: active`
    * firewall is active

## Enable/Disable

Enable UFW

```sh
sudo ufw enable
```

**NOTE**: by default, there are NO firewall riles and ufw, if enabled, will block ALL incoming network requests. Be sure to add applicable allow firewall rules before enabling ufw.

Disable

```sh
sudo ufw disable
```

## Configure ALLOW rules

ssh

```sh
sudo ufw allow ssh/tcp
```
