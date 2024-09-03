# How to sort out nonsense with docker interfaces and IPs

Get list of docker interfaces

```sh
sudo docker network ls
```

Iterate each to get IP

```sh
sudo docker network inspect b88c51ad9270 --format '{{json .IPAM.Config}}'
```

Compare with ips:

```sh
hostname -I
```

Exclude:
* Docker IPs
* IPv6
* 127.