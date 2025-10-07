#!/bin/bash

RED="\e[31m"
GREEN="\e[32m"
BLUE="\e[34m"
YELLOW="\e[33m"
ENDCOLOR="\e[0m"

CURDIR=$(pwd)
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")


SSH_KEY_FILE=~/.ssh/id_ed25519.pub

if [ -f "${SSH_KEY_FILE}" ]; then
    echo -e "${GREEN}Key file exists${ENDCOLOR} ${BLUE}$(readlink -f ${SSH_KEY_FILE})${ENDCOLOR}"
    # ~/.ssh/id_ed25519.pub
else
    echo -e "${YELLOW}Key file does NOT exist${ENDCOLOR} ${BLUE}$(readlink -f ${SSH_KEY_FILE})${ENDCOLOR}"
    echo "Generating SSH Key..."
    ssh-keygen -t ed25519 -C "gitlab-user-$(whoami)"
fi

if [ -f "${SSH_KEY_FILE}" ]; then
    echo -e "${GREEN}======== START: Copy key below ========${ENDCOLOR}"
    cat ~/.ssh/id_ed25519.pub
    echo -e "${GREEN}======== END: Copy key above ========${ENDCOLOR}"
fi