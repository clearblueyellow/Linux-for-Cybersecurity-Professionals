#!/bin/bash

# Script to list firewall rules (iptables or UFW) with color output and file logging

# Timestamp and log file path
TIMESTAMP=$(date "+%Y-%m-%d_%H-%M-%S")
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/Firewall Rules List - $TIMESTAMP.txt"

# Colors
GREEN="\e[1;32m"
BLUE="\e[1;34m"
RED="\e[1;31m"
YELLOW="\e[1;33m"
NC="\e[0m" # No Color

# Logging function: colors to screen, plain text to file
log() {
    local COLOR_TEXT="$1"
    local PLAIN_TEXT
    # Strip ANSI escape sequences for file output
    PLAIN_TEXT=$(echo -e "$COLOR_TEXT" | sed 's/\x1b\[[0-9;]*m//g')
    echo -e "$COLOR_TEXT"
    echo "$PLAIN_TEXT" >> "$LOG_FILE"
}

log "${BLUE}Firewall Rule Lister${NC}"
log "${BLUE}--------------------${NC}"

# Check for UFW
if command -v ufw &> /dev/null; then
    log "${GREEN}[*] UFW (Uncomplicated Firewall) detected.${NC}"
    UFW_STATUS=$(sudo ufw status | head -n 1)
    log "${YELLOW}UFW Status: $UFW_STATUS${NC}"

    if [[ "$UFW_STATUS" == "Status: active" ]]; then
        log ""
        log "${GREEN}[+] UFW Rules (Numbered):${NC}"
        sudo ufw status numbered | tee -a "$LOG_FILE"
        log ""
        log "${GREEN}[+] UFW Rules (Verbose):${NC}"
        sudo ufw status verbose | tee -a "$LOG_FILE"
    elif [[ "$UFW_STATUS" == "Status: inactive" ]]; then
        log "${YELLOW}UFW is inactive. Showing configured rules (if any)...${NC}"
        sudo ufw show added | tee -a "$LOG_FILE"
    else
        log "${RED}Could not determine UFW status or UFW is not configured.${NC}"
    fi
    log "${BLUE}--------------------${NC}"
fi

# Check for iptables
if command -v iptables &> /dev/null; then
    log ""
    log "${GREEN}[*] iptables rules:${NC}"
    log "${YELLOW}Note: If UFW is active, these rules are likely managed by UFW.${NC}"
    
    log ""
    log "${GREEN}[+] iptables Filter Table Rules (INPUT, FORWARD, OUTPUT chains):${NC}"
    sudo iptables -L -n -v --line-numbers | tee -a "$LOG_FILE"
    log ""

    log "${GREEN}[+] iptables NAT Table Rules:${NC}"
    sudo iptables -t nat -L -n -v --line-numbers | tee -a "$LOG_FILE"
    log ""
    
    log "${GREEN}[+] iptables Mangle Table Rules:${NC}"
    sudo iptables -t mangle -L -n -v --line-numbers | tee -a "$LOG_FILE"
    log ""

else
    if ! command -v ufw &> /dev/null; then
        log "${RED}Error: Neither UFW nor iptables found on this system.${NC}"
        exit 1
    fi
fi

log "${BLUE}Firewall rule listing complete.${NC}"
log "${BLUE}Output saved to: $LOG_FILE${NC}"
