#!/bin/bash

DIR=`cd "$(dirname "${BASH_SOURCE[0]}")" && pwd`

RED='\e[31m'
NC='\e[0m'
YELLOW='\e[33m'
GREEN='\e[32m'

HTML_DIR='/var/www/html'
PMA_URL='https://files.phpmyadmin.net/phpMyAdmin/5.2.3/phpMyAdmin-5.2.3-all-languages.zip'
PMA_TEMP_ZIP="/tmp/phpmyadmin.zip"
PMA_TARGET_DIR="/var/www/html/phpMyAdmin"

echo -e "${YELLOW}=====[Setup WebServer]=====${NC}"

# Ask Y/n to download phpMyAdmin
echo -e "${YELLOW}是否要下載phpMyAdmin?${NC} (Yes/no/skip) [Y/n/s]"
read -p "->" PMA_CHOICE
PMA_CHOICE=${PMA_CHOICE:-Y}

if [[ "$PMA_CHOICE" =~ ^[Yy](es)?$ ]]; then
    # Download phpMyAdmin
    echo -e "${GREEN}正在下載並安裝 phpMyAdmin...${NC}"
    wget -O "${PMA_TEMP_ZIP}" "${PMA_URL}"
    unzip -q "${PMA_TEMP_ZIP}" -d /tmp/pma_temp
    mkdir -p "${PMA_TARGET_DIR}"
    mv /tmp/pma_temp/phpMyAdmin-5.2.3-all-languages/* "${PMA_TARGET_DIR}"
    rm -rf /tmp/pma_temp "${PMA_TEMP_ZIP}"
    cp "${PMA_TARGET_DIR}/config.sample.inc.php" "${PMA_TARGET_DIR}/config.inc.php"
    echo -e "[${GREEN}V${NC}] phpMyAdmin 安裝完成。"
else
    echo -e "[${YELLOW}i${NC}] 跳過 phpMyAdmin 安裝。"
fi

# Copy site1 and site2
mkdir -p "${HTML_DIR}/site1" "${HTML_DIR}/site2"
cp -r "$DIR/source/html/site1" "${HTML_DIR}/site1" || \
        echo -e "${RED}[X]${NC} site1/ not found" 
cp -r "$DIR/source/html/site2" "${HTML_DIR}/site2" || \
        echo -e "${RED}[X]${NC} site2/ not found" 

# Configure Apache virtual hosts
echo -e "${YELLOW}請輸入要廣播的根域名稱(e.g. se218.local):${NC}"
read -p "->" DOMAIN_NAME
if [ -z "$DOMAIN_NAME" ]; then
    echo -e "${RED}[X]${NC} Domain name cannot be empty."
    exit 1
fi

if [[ "$DOMAIN_NAME" != *.local ]]; then
    DOMAIN_NAME="${DOMAIN_NAME}.local"
fi

# Register domains via mDNS
if [ -f "$DIR/mDNS.sh" ]; then
    "$DIR/mDNS.sh" -n "${DOMAIN_NAME}-1"
    "$DIR/mDNS.sh" -n "${DOMAIN_NAME}-2"
else
    echo -e "${RED}[ERROR]${NC} mDNS.sh not found in $DIR"
fi

APACHE_CONF_DIR="/etc/apache2/sites-enabled"
mkdir -p "${APACHE_CONF_DIR}"
sed -e "s/site1.g3.local/site1.${DOMAIN_NAME}/g" \
    -e "s/site2.g3.local/site2.${DOMAIN_NAME}/g" \
    -e "s|DocumentRoot /var/www/html/site1$|DocumentRoot /var/www/html/site2|2" \
    "$DIR/source/sites-enabled/001-main.conf" > "${APACHE_CONF_DIR}/001-main.conf"

echo "[${GREEN}V${NC}] 已設定apache2虛擬主機至 site1.${DOMAIN_NAME} 及 site2.${DOMAIN_NAME} 。"

# restart apache2
systemctl restart apache2.service


#mysql_secure_installation
