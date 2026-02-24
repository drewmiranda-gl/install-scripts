# Using Windows Event Forwarding/Collection with Graylog

This guide will cover topics relating to:

- configuring a Windows Event Collection (WEC) server
- configuring Windows Event Forwarding (WEF) to forward events to the above WEC server
- configuring Graylog Sidecar (Running on the WEC server) to forward events to Graylog

## Terminology

- WEC
    - [Windows Event Collector](https://learn.microsoft.com/en-us/windows/win32/wec/windows-event-collector)
        - A dedicated windows server that receives Windows Events forwarded by windows clients (both Windows and Windows Server)
- WEF
    - [Windows Event Forwarding](https://learn.microsoft.com/en-us/windows/security/operating-system-security/device-management/use-windows-event-forwarding-to-assist-in-intrusion-detection)
        - A built-in, out of the box mechanism for windows to forward event logs to a central WEC server. Can be configured and managed via Active Directory Group Policy, which is strongly reccomended.

## WEF/WEC

The following guide has been tested and validated to work. It can be followed as presented.

https://michaelwaterman.nl/2024/06/29/step-by-step-guide-to-windows-event-forwarding-and-ntlmv1-monitoring/

One important note is that following the steps exactly as prescribed, in the order as writen, may not allow you to successfuly receive events on your WEC server. If you have done everything correctly and still are not receiving any events on your WEC server, restart the "Windows Remote Management (WS-Management)" (`WinRM`) service.

## Graylog Sidecar

Below is an example Graylog Sidecar config, as configured inside of the Graylog Web UI.

```yaml
# Required settings
fields_under_root: true
fields.collector_node_id: ${sidecar.nodeName}
fields.gl2_source_collector: ${sidecar.nodeId}


output.logstash:
   hosts: ["${user.graylog_host}:5044"]
path:
  data: ${sidecar.spoolDir!"C:\\Program Files\\Graylog\\sidecar\\cache\\winlogbeat"}\data
  logs: ${sidecar.spoolDir!"C:\\Program Files\\Graylog\\sidecar"}\logs
tags:
 - windows
winlogbeat:
  event_logs:
    - name: Application
      ignore_older: 1h
    - name: System
      ignore_older: 1h
    - name: Security
      ignore_older: 1h
    - name: ForwardedEvents
      ignore_older: 24h
```

The important bit that instructs winlogbeat to ship Forwarded Events is:

```yaml
winlogbeat:
  event_logs:
    - name: ForwardedEvents
      ignore_older: 24h
```

It is important to note that forwarded events (originally from WEF clients sent to WEC server) shipped from a WEC server to Graylog will have the event's source displayed as the WEC server. However, the `winlogbeat_host_name` attribute does contain the true log source hostname.

It is reccomended to have a Graylog Pipeline rule overwrite `source` with the value from `winlogbeat_host_name`

Example:

```groovy
rule "Restore correct source hostname for WEF to WEC events"
when
    has_field("winlogbeat_host_name")
    && lowercase(to_string($message.winlogbeat_host_name)) != lowercase(to_string($message.source))
then
    set_field("wec_host", to_string($message.source));
    set_field("source", to_string($message.winlogbeat_host_name));
end
```