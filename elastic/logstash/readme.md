# Install

```shell
# https://www.elastic.co/guide/en/logstash/current/installing-logstash.html
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elastic-keyring.gpg
sudo apt-get install apt-transport-https
echo "deb [signed-by=/usr/share/keyrings/elastic-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-8.x.list
sudo apt-get update && sudo apt-get install logstash
```

Config files automatically loaded from `/etc/logstash/conf.d/*.conf`

Start service `logstash`

# Sample Configs

## Syslog forwarding

```js
input {
  udp {
    id => "input_udp_8560"
    port => 8560
    tags => ["input_udp_8560"]
  }
}
output {
 if "input_udp_8560" in [tags] {
    udp {
      id => "output_udp_8560"
      port => "18560"
      host => "<localIP>"
      codec => line {
        format => "%{[message]}"
      }
    }
  }
}
```

## Syslog forwarding with strip applied

Trims leading and trailing whitespace.

```js
input {
  udp {
    id => "input_udp_5140"
    port => 5140
    tags => ["input_udp_5140"]
  }
}
filter {
    mutate {
        strip => ["message"]
    }
}
output {
 if "input_udp_5140" in [tags] {
    udp {
      id => "output_udp_5140"
      port => "<port>"
      host => "<graylog_host>"
      codec => plain {
        format => "%{[message]}"
      }
    }
  }
}
```