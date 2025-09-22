#!/bin/bash

DOCKER_DAEMON_FILE="/etc/docker/daemon.json"
TMP_FILE="${DOCKER_DAEMON_FILE}.tmp"

echo "Please run as ROOT"
echo "This script will add '\"ipv6\": false' to ${DOCKER_DAEMON_FILE}"
echo "This will disable IPv6 for docker/docker containers"
read -p "Confirmation 1 of 2: This will restart the docker service and will restart all docker containers..."
read -p "Confirmation 2 of 2: This will restart the docker service and will restart all docker containers..."


echo "Docker Daemon File: ${DOCKER_DAEMON_FILE}"
if [ -f "${DOCKER_DAEMON_FILE}" ]; then
    echo "File exists!"
    cat $DOCKER_DAEMON_FILE
    grep -e '"ipv6": false' ${DOCKER_DAEMON_FILE} >/dev/null 2>&1
    ret=$?
    if [ "$ret" != "0" ] ; then
        echo "Adding \"ipv6\": false to ${DOCKER_DAEMON_FILE}"
        # check if existing json is valid valid
        cat ${DOCKER_DAEMON_FILE} | jq >/dev/null 2>&1
        ret=$?
        if [ "$ret" != "0" ] ; then
            echo '{"ipv6": false}' | jq > ${DOCKER_DAEMON_FILE}
        else
            jq '. += {"ipv6": false}' ${DOCKER_DAEMON_FILE} > ${TMP_FILE}
            mv -f ${TMP_FILE} ${DOCKER_DAEMON_FILE}
        fi


        echo "Restarting Docker..."
        systemctl restart docker
    else
        echo 'Already configured: "ipv6": false'
    fi
else
    echo "Docker Daemon File does not exist at: ${DOCKER_DAEMON_FILE}"
    echo "Adding \"ipv6\": false to ${DOCKER_DAEMON_FILE}"
    echo '{"ipv6": false}' | jq > ${DOCKER_DAEMON_FILE}


    echo "Restarting Docker..."
    systemctl restart docker
fi

# {
#   "metrics-addr": "0.0.0.0:9323",
#   "ipv6": false
# }