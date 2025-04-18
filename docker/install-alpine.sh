# install docker
apk add docker
# install docker compose
apk add docker-cli-compose
# docker as root
rc-update add docker default
service docker start
