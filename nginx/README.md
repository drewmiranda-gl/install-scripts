# Install

```sh
sudo apt update && sudo apt install nginx -y
```

# Configuration Examples

## UDP

NOTES:
- this goes directly in `nginx.conf` and exists outside of `http {}`
- This requires the `stream` module, which is enabled by default (tested Ubuntu Server 22.04)

```
stream {
    upstream ipfix_backend_servers {
        server 192.168.0.11:4739;
        server 192.168.0.12:4739;
        server 192.168.0.13:4739;
    }

    server {
        listen 4739 udp;
        proxy_pass ipfix_backend_servers;
        proxy_responses 1;  # optional: tune for expected response behavior
    }

    upstream syslog_backend_servers {
        server 192.168.0.11:5514;
        server 192.168.0.12:5514;
        server 192.168.0.13:5514;
    }

    server {
        listen 5514 udp;
        proxy_pass syslog_backend_servers;
        proxy_responses 1;  # optional: tune for expected response behavior
    }
}
```