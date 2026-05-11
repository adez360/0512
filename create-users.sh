#!/bin/bash
DIR=`cd "$(dirname "${BASH_SOURCE[0]}")" && pwd`
USERS_FILE="$DIR/config/users.list"

while read -r username password; do
        if [ -z "$username" ]; then continue; fi
        echo "Creating user: $username"
        useradd -m -s /bin/zsh "$username"
		usermod -aG sudo "$username"
        echo "$username:$password" | chpasswd
done < "$USERS_FILE"
