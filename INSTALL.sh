#!/bin/bash

# Ensure script is run as root
if [ "$EUID" -ne 0 ]; then
    echo -e "\e[31m[ERROR]\e[0m Please run this script as root (use sudo)."
    exit 1
fi

RED='\e[31m'
NC='\e[0m'
YELLOW='\e[33m'
GREEN='\e[32m'

echo -e "${YELLOW}=====[  Starting Auto-Install  ]=====${NC}"

# Ensure git is installed
if ! command -v git &> /dev/null; then
    echo -e "${YELLOW}[INFO]${NC} Git is not installed. Installing git..."
    apt update && apt install -y git
fi

# Define installation directory
INSTALL_DIR="/opt/0512-server-setup"

# Clean up existing directory if it exists
if [ -d "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}[INFO]${NC} Found existing installation directory. Removing it..."
    rm -rf "$INSTALL_DIR"
fi

# 1. Clone the repository
echo -e "${GREEN}>>> Cloning repository...${NC}"
git clone https://github.com/adez360/0512.git "$INSTALL_DIR"
if [ $? -ne 0 ]; then
    echo -e "${RED}[ERROR]${NC} Failed to clone repository. Exiting."
    exit 1
fi

# 2. Enter directory and set permissions
cd "$INSTALL_DIR" || exit 1
chmod +x *.sh

# 3. Execute scripts sequentially
echo -e "${GREEN}>>> Executing bootstrap.sh...${NC}"
./bootstrap.sh
if [ $? -ne 0 ]; then
    echo -e "${RED}[ERROR]${NC} bootstrap.sh failed. Exiting."
    exit 1
fi

echo -e "${GREEN}>>> Executing create-users.sh...${NC}"
./create-users.sh
if [ $? -ne 0 ]; then
    echo -e "${RED}[ERROR]${NC} create-users.sh failed. Exiting."
    exit 1
fi

echo -e "${GREEN}>>> Executing setup-web.sh...${NC}"
./setup-web.sh
if [ $? -ne 0 ]; then
    echo -e "${RED}[ERROR]${NC} setup-web.sh failed. Exiting."
    exit 1
fi

echo -e "${YELLOW}=====[ All Installations Complete ]=====${NC}"
echo -e "The project directory is kept at: ${GREEN}$INSTALL_DIR${NC}"
