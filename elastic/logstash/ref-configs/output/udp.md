```
output {
 if "input_udp_5140" in [tags] {
    udp {
      id => "output_udp_5140"
      port => "5140"
      host => "graylog.geek4u.net"
      codec => line {
        format => "%{[message]}"
      }
    }
  }
}
```