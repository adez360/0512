#!/bin/bash

ADDRESS=$(hostname -I | awk '{print $1}')

while [[ "$#" -gt 0 ]]; do
	case $1 in
		-a|--address)
			ADDRESS="$2"
			shift 2
			;;
		-n|--name)
			NAME="$2"
			shift 2
			;;
		-k|--kill)
			pkill -f avahi-publish-address
			echo "清除所有廣播"
			exit 0
			;;
		-h|--help)
			echo "[ERROR] Usage: $0 [-a IP] [-n Name] | [-k Kill all]"
			echo "Example: $0 -a 10.167.214.72 example.local"
			exit 0
			;;
		*)
			echo "Usage: $0 [-a IP] [-n Name] | [-k Kill all]"
			echo "Example: $0 -a 10.167.214.72 example.local"
			exit 1
			;;
	esac
done

if [[ -z $NAME ]]; then
	echo "[Error] Must setup Name."
	echo "Usage: $0 [-a IP] [-n Name]"
	echo "Example: $0 -a 10.167.214.72 example.local"
	exit 1
fi

DNS_RESULT=$(timeout 0.5 getent ahosts "$NAME" | awk '{print $1}' | head -n 1)

if [[ -n $DNS_RESULT ]]; then
	echo "網域已經被$DNS_RESULT註冊走了，請換一個。"
	exit 1
fi

avahi-publish-address -R "$NAME" "$ADDRESS" 2>/dev/null &

echo "成功把$NAME指向$ADDRESS。"
