#!/bin/bash

ADDRESS=$(hostname -I | awk '{print $1}')

RED='\e[31m'
NC='\e[0m'
YELLOW='\e[33m'
GREEN='\e[32m'

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
			echo "[${GREEN}V${NC}]清除所有廣播"
			exit 0
			;;
		-h|--help)
			echo "[${RED}X${NC}] Usage: $0 [-a IP] [-n Name] | [-k Kill all]"
			echo "Example: $0 -a 10.167.214.72 example"
			exit 0
			;;
		*)
			echo "Usage: $0 [-a IP] [-n Name] | [-k Kill all]"
			echo "Example: $0 -a 10.167.214.72 example"
			exit 1
			;;
	esac
done

if [[ -z $NAME ]]; then
	echo -e "[${RED}X${NC}] Must setup Name."
	echo "Usage: $0 [-a IP] [-n Name]"
	echo "Example: $0 -a 10.167.214.72 example"
	exit 1
fi

# 如果NAME沒有輸入.local自動補上.local
if [[ "$NAME" != *.local ]]; then
	NAME="${NAME}.local"
fi

# 如果存在子域名 e.g. site1.se218.local 終止
# 檢查 . 的數量，如果有兩個以上的 . 則視為包含子域名
DOT_COUNT=$(awk -F"." '{print NF-1}' <<< "$NAME")
if [[ $DOT_COUNT -gt 1 ]]; then
	echo -e "[${RED}X${NC}]只允許輸入根域名(e.g. se218-site1.local)"  #無效域名
	exit 1
fi

DNS_RESULT=$(timeout 0.5 getent ahosts "$NAME" | awk '{print $1}' | head -n 1)

if [[ -n $DNS_RESULT ]]; then
	echo -e "[${RED}X${NC}]網域已經被$DNS_RESULT註冊走了，請換一個。"
	exit 1
fi

avahi-publish-address -R "$NAME" "$ADDRESS" &

echo -e "[${GREEN}V${NC}]成功把$NAME指向$ADDRESS。"
