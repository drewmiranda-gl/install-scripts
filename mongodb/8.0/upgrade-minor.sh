#!/bin/bash

root_check() {
    get_curusr=$(whoami)
    if [ $get_curusr == "root" ]
    then
        ok="okhere"
    else
        echo "ERROR! Please run as root."
        echo "Try: 'sudo su' to elevate and then run install script again."
	echo "OR sudo bash $0"
        exit 1
    fi
}
root_check

sudo apt update
rm -f out_apt_upg_mongo
apt list --upgradable | grep mongo > out_apt_upg_mongo
Lines=$(cat out_apt_upg_mongo)
concat=""
while IFS= read -r line; do
    pkgtoupg=$(echo "$line" | grep -oPo "^(.*?)\/" | grep -oPo "^([\w\-]+)")
    echo $pkgtoupg
    concat="$concat$pkgtoupg "
done <<< "$Lines"
sudo apt install $concat
