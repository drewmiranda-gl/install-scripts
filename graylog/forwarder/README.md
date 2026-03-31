# Upgrading Forwarder

Upgrading Graylog Forwarder is similiar to upgrading `graylog-server` (or `graylog-enterprise`): 

1. Update the repo
2. Install via your package manager (e.g. `apt`, `yum`)

## Java and JDK

One very important difference between upgrading Graylog and Graylog Forwarder is that Forwarder does NOT bundle its required Java Runtime (e.g. JVM). This means YOU must ensure you not only install the minimum required version, but also verify that the targeted `java` is the correct version.

1. **Ensure** the proper targeted JVM is **installed**<br>(**these commands require elevated priveleges, use `sudo` where applicable**)
    - RHEL Based
        - `yum install -y java-21-openjdk-headless`
    - Debian Based
        - `apt-get install -y openjdk-21-jdk-headless`
2. **Verify** java version
    - `java --version`
3. IF an older version is returned, and assuming your system uses `update-alternatives`
    - verify linked path uses `update-alternatives`
        - `ls -al $(which java)`
            - should return something like `/usr/bin/java -> /etc/alternatives/java` though the actual path may vary (e.g. may be `/bin/java` or something else)
    - IF `update-alternatives` is used, use it to update the link to the latest java version:
        - `update-alternatives --config java`
        - Choose the selection that targets the latest java version
4. **Reverify** java version
    - `java --version`

Note that providing a fully automated and scriptable way to update `update-alternatives` is out of scope for this document.