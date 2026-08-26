If you wish to have Graylog/Data Node fully **automate** the initial **first run (pre-flight)**, configure `selfsigned_startup = true` in Graylog’s config (e.g. `server.conf`)

----

Data Node is a graylog service that is used with Graylog (graylog-server). It acts as the indexer and is used in place of OpenSearch (or Elasticsearch). It connects to the same MongoDB database as Graylog (graylog-server) and is managed and configured by Graylog.

Its main benefits are:

* Because a specific version of OpenSearch will be coupled to each release of Data Node, this allows for tighter integration between OpenSearch and Graylog. We can be certain what features and capabilities are provided by OpenSearch and graylog can make full use of those.
* Provisioning and Configuring indexer nodes can be done via Graylog
* Configuration of security and TLS certificates for OpenSearch is handled by data node