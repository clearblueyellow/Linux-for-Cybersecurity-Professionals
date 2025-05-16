#!/bin/bash

# Basic Incident Response Data Collector

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_DIR="IR_COLLECTION_${TIMESTAMP}"
CURRENT_USER=$(whoami)

# Check if running as root, as some commands require it for full output
if [ "$EUID" -ne 0 ]; then
  echo "Warning: This script is not run as root. Some information may be incomplete."
  echo "Consider running with sudo."
fi

mkdir -p "$OUTPUT_DIR"
echo "Incident data will be collected in: $OUTPUT_DIR"
echo "-------------------------------------------------"

echo "[*] Collecting System Identification..."
(
    echo "Collection Timestamp: $(date)"
    echo "Hostname: $(hostname)"
    echo "Kernel Info: $(uname -a)"
    echo "Uptime: $(uptime)"
    echo "Current User: $CURRENT_USER (Script run as)"
) > "$OUTPUT_DIR/01_system_identification.txt"

echo "[*] Collecting Network Information..."
(
    echo "=== IP Configuration (ip a) ==="
    ip a
    echo -e "\n=== Listening Sockets (ss -tulnp) ==="
    sudo ss -tulnp
    echo -e "\n=== Established Connections (ss -antp) ==="
    sudo ss -antp
    echo -e "\n=== Routing Table (route -n) ==="
    route -n
    echo -e "\n=== DNS Configuration (/etc/resolv.conf) ==="
    cat /etc/resolv.conf
) > "$OUTPUT_DIR/02_network_information.txt"

echo "[*] Collecting Running Processes..."
(
    echo "=== All Processes (ps auxwww) ==="
    ps auxwww
    echo -e "\n=== Process Tree (pstree -p) ==="
    pstree -p
) > "$OUTPUT_DIR/03_running_processes.txt"

echo "[*] Collecting User Information..."
(
    echo "=== Who is Logged In (who) ==="
    who
    echo -e "\n=== Who is Logged In & What They Are Doing (w) ==="
    w
    echo -e "\n=== Last 50 Logins (last -n 50) ==="
    last -n 50
    echo -e "\n=== Sudoers File (/etc/sudoers) ==="
    if [ -r /etc/sudoers ]; then
        sudo cat /etc/sudoers
    else
        echo "Cannot read /etc/sudoers."
    fi
) > "$OUTPUT_DIR/04_user_information.txt"

echo "[*] Collecting Disk and Memory Usage..."
(
    echo "=== Disk Usage (df -h) ==="
    df -h
    echo -e "\n=== Memory Usage (free -m) ==="
    free -m
    echo -e "\n=== Mounted Filesystems (/proc/mounts) ==="
    cat /proc/mounts
) > "$OUTPUT_DIR/05_disk_memory_usage.txt"

echo "[*] Collecting Recent Log Entries..."
