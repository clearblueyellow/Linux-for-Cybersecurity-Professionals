#!/bin/bash

# Basic Incident Response Data Collector

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_DIR="IR_COLLECTION_${TIMESTAMP}"
CURRENT_USER=$(whoami)

# Check if running as root, as some commands require it for full output
if; then
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
    sudo ss -tulnp # sudo for process names
    echo -e "\n=== Established Connections (ss -antp) ==="
    sudo ss -antp # sudo for process names
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
    echo -e "\n=== Sudoers File (content of /etc/sudoers - requires root) ==="
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
(
    echo "=== Last 100 lines of /var/log/auth.log (or secure) ==="
    if [ -f /var/log/auth.log ]; then sudo tail -n 100 /var/log/auth.log; fi
    if [ -f /var/log/secure ]; then sudo tail -n 100 /var/log/secure; fi
    
    echo -e "\n=== Last 100 lines of /var/log/syslog (or messages) ==="
    if [ -f /var/log/syslog ]; then sudo tail -n 100 /var/log/syslog; fi
    if [ -f /var/log/messages ]; then sudo tail -n 100 /var/log/messages; fi
    
    echo -e "\n=== Kernel Ring Buffer (dmesg | tail -n 100) ==="
    dmesg | tail -n 100
) > "$OUTPUT_DIR/06_log_snippets.txt"

echo "[*] Collecting Current User's Bash History..."
# Note: This only gets the current user's history from memory.
# For persistent history, ~/.bash_history would be targeted (but might not be up-to-date).
(
    echo "=== Current session bash history (for user $CURRENT_USER) ==="
    history
) > "$OUTPUT_DIR/07_bash_history_current_user.txt"

# Optional: Crontab entries
echo "[*] Collecting Crontab Entries..."
(
    echo "=== System-wide crontab (/etc/crontab) ==="
    if [ -f /etc/crontab ]; then cat /etc/crontab; fi
    echo -e "\n=== Cron jobs in /etc/cron.d/ ==="
    if [ -d /etc/cron.d/ ]; then sudo ls -la /etc/cron.d/; for f in /etc/cron.d/*; do echo -e "\n--- Content of $f ---"; sudo cat "$f"; done; fi
    echo -e "\n=== Cron jobs in /etc/cron.hourly/ (list) ==="
    if [ -d /etc/cron.hourly/ ]; then sudo ls -la /etc/cron.hourly/; fi
    echo -e "\n=== Cron jobs in /etc/cron.daily/ (list) ==="
    if [ -d /etc/cron.daily/ ]; then sudo ls -la /etc/cron.daily/; fi
    echo -e "\n=== Cron jobs in /etc/cron.weekly/ (list) ==="
    if [ -d /etc/cron.weekly/ ]; then sudo ls -la /etc/cron.weekly/; fi
    echo -e "\n=== Cron jobs in /etc/cron.monthly/ (list) ==="
    if [ -d /etc/cron.monthly/ ]; then sudo ls -la /etc/cron.monthly/; fi
    echo -e "\n=== Current user's crontab (crontab -l for $CURRENT_USER) ==="
    crontab -l 2>/dev/null |
| echo "No crontab for $CURRENT_USER"
    # To list root's crontab (if script is run as root or with sudo)
    if; then
        echo -e "\n=== Root user's crontab (crontab -l for root) ==="
        sudo crontab -l 2>/dev/null |
| echo "No crontab for root"
    fi
) > "$OUTPUT_DIR/08_cron_information.txt"


echo "-------------------------------------------------"
echo "Basic incident data collection complete."
echo "Output saved in directory: $OUTPUT_DIR"
echo "Please secure this data appropriately."
