#!/bin/bash

DIR=`cd "$(dirname "${BASH_SOURCE[0]}")" && pwd`

RED='\e[31m'
NC='\e[0m'
YELLOW='\e[33m'

HTML_DIR='/var/www/html'
PMA_URL='https://files.phpmyadmin.net/phpMyAdmin/5.2.3/phpMyAdmin-5.2.3-all-languages.zip'
PMA_TEMP_ZIP="/tmp/phpmyadmin.zip"
PMA_TARGET_DIR="/var/www/html/phpMyAdmin"

echo -e "${YELLOW}=====[Setup WebServer]=====${NC}"

# Download phpMyAdmin
wget -O "${PMA_TEMP_ZIP}" "${PMA_URL}"
unzip -q "${PMA_TEMP_ZIP}" -d /tmp/pma_temp
mkdir -p "${PMA_TARGET_DIR}"
mv /tmp/pma_temp/phpMyAdmin-5.2.3-all-languages/* "${PMA_TARGET_DIR}"
rm -rf /tmp/pma_temp "${PMA_TEMP_ZIP}"
cp "${PMA_TARGET_DIR}/config.sample.inc.php" "${PMA_TARGET_DIR}/config.inc.php"

# Copy site1 and site2
mkdir -p "${HTML_DIR}/site1" "${HTML_DIR}/site1"
cp -r "$DIR/source/html/site1" "${HTML_DIR}/site1" || \
	echo -e "${RED}[ERROR]${NC} site1/ not found" 
cp -r "$DIR/source/html/site2" "${HTML_DIR}/site2" || \
	echo -e "${RED}[ERROR]${NC} site2/ not found" 

# restart apache2
systemctl restart apache2.service

#mysql_secure_installatio

