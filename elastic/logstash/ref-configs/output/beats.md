See https://www.elastic.co/guide/en/logstash/current/plugins-outputs-logstash.html

```
output {
  logstash {
    hosts => "10.0.0.123:9801"
    ssl_enabled
         => false
  }
}
```