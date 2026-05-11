#!/bin/bash

RED='\e[31m'
NC='\e[0m'
YELLOW='\e[33m'
GREEN='\e[32m'

# Ensure script is run as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}[X]${NC} 請以 root 身分執行此腳本 (使用 sudo)。"
    exit 1
fi

echo -e "${YELLOW}=====[  開始自動安裝流程  ]=====${NC}"

# Ensure git is installed
if ! command -v git &> /dev/null; then
    echo -e "${YELLOW}[i]${NC} 未安裝 Git，正在為您安裝..."
    apt update && apt install -y git
fi

# Define installation directory
INSTALL_DIR="/opt/0512-server-setup"

# Clean up existing directory if it exists
if [ -d "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}[i]${NC} 發現已存在的安裝目錄，正在移除舊檔案..."
    rm -rf "$INSTALL_DIR"
fi

# 1. Clone the repository
echo -e "${GREEN}[i]${NC} 正在下載專案原始碼..."
git clone https://github.com/adez360/0512.git "$INSTALL_DIR"
if [ $? -ne 0 ]; then
    echo -e "${RED}[X]${NC} 下載專案失敗，退出安裝。"
    exit 1
fi

# 2. Enter directory and set permissions
cd "$INSTALL_DIR" || exit 1
chmod +x *.sh

# 3. Execute scripts sequentially with prompts

# Bootstrap
echo -e "${YELLOW}是否要執行 bootstrap.sh (系統初始化)?${NC} [Y/n]"
read -p "->" CHOICE_BOOTSTRAP
CHOICE_BOOTSTRAP=${CHOICE_BOOTSTRAP:-Y}
if [[ "$CHOICE_BOOTSTRAP" =~ ^[Yy](es)?$ ]]; then
    echo -e "${GREEN}[i]${NC} 正在執行 bootstrap.sh..."
    ./bootstrap.sh
    if [ $? -ne 0 ]; then
        echo -e "${RED}[X]${NC} bootstrap.sh 執行失敗，退出安裝。"
        exit 1
    fi
    echo -e "${GREEN}[V]${NC} bootstrap.sh 執行完成。"
else
    echo -e "${YELLOW}[i]${NC} 跳過 bootstrap.sh。"
fi

# Create Users
echo -e "${YELLOW}是否要執行 create-users.sh (建立使用者)?${NC} [Y/n]"
read -p "->" CHOICE_USERS
CHOICE_USERS=${CHOICE_USERS:-Y}
if [[ "$CHOICE_USERS" =~ ^[Yy](es)?$ ]]; then
    echo -e "${GREEN}[i]${NC} 正在執行 create-users.sh..."
    ./create-users.sh
    if [ $? -ne 0 ]; then
        echo -e "${RED}[X]${NC} create-users.sh 執行失敗，退出安裝。"
        exit 1
    fi
    echo -e "${GREEN}[V]${NC} create-users.sh 執行完成。"
else
    echo -e "${YELLOW}[i]${NC} 跳過 create-users.sh。"
fi

# Setup Web
echo -e "${YELLOW}是否要執行 setup-web.sh (設定 WebServer)?${NC} [Y/n]"
read -p "->" CHOICE_WEB
CHOICE_WEB=${CHOICE_WEB:-Y}
if [[ "$CHOICE_WEB" =~ ^[Yy](es)?$ ]]; then
    echo -e "${GREEN}[i]${NC} 正在執行 setup-web.sh..."
    ./setup-web.sh
    if [ $? -ne 0 ]; then
        echo -e "${RED}[X]${NC} setup-web.sh 執行失敗，退出安裝。"
        exit 1
    fi
    echo -e "${GREEN}[V]${NC} setup-web.sh 執行完成。"
else
    echo -e "${YELLOW}[i]${NC} 跳過 setup-web.sh。"
fi

echo -e "${YELLOW}=====[  所有安裝流程結束  ]=====${NC}"
echo -e "專案目錄保留於: ${GREEN}$INSTALL_DIR${NC}"
