#!/bin/bash

# Script to discover live hosts and perform a basic port scan

# Check if nmap is installed
if ! command -v nmap &> /dev/null; then
    echo "Error: nmap is not installed. Please install nmap and try again."
    exit 1
fi

# Prompt user for network range
read -p "Enter the network range to scan (e.g., 192.168.1.0/24): " NETWORK_RANGE

# Check if network range is empty
# The 'if' statement needs a condition to evaluate.
# -z "$NETWORK_RANGE" checks if the variable is an empty string.
if [ -z "$NETWORK_RANGE" ]; then
    echo "Error: Network range cannot be empty."
    exit 1
fi

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_FILE="network_scan_results_${TIMESTAMP}.txt"

echo "Starting host discovery on $NETWORK_RANGE..." | tee -a "$OUTPUT_FILE"
# Discover live hosts using nmap ping scan and extract IPs
# -sn: Ping Scan - disables port scan
# -oG - : Grepable output to stdout, then filter
LIVE_HOSTS=$(nmap -sn "$NETWORK_RANGE" -oG - | awk '/Up$/{print $2}')

# Check if LIVE_HOSTS is empty
# Similar to the previous 'if', this one also needs a condition.
# -z "$LIVE_HOSTS" checks if the variable is an empty string.
if [ -z "$LIVE_HOSTS" ]; then
    echo "No live hosts found in the range $NETWORK_RANGE." | tee -a "$OUTPUT_FILE"
    exit 0
fi

echo "Live hosts found:" | tee -a "$OUTPUT_FILE"
echo "$LIVE_HOSTS" | tee -a "$OUTPUT_FILE"
echo "-------------------------------------" | tee -a "$OUTPUT_FILE"

echo "Starting basic port scan on discovered hosts..." | tee -a "$OUTPUT_FILE"

for IP in $LIVE_HOSTS; do
    echo "Scanning ports on $IP..." | tee -a "$OUTPUT_FILE"
    # -sT: TCP connect scan
    # -F: Fast mode - Scans fewer ports than the default scan (top 100)
    nmap -sT -F "$IP" | tee -a "$OUTPUT_FILE"
    echo "-------------------------------------" | tee -a "$OUTPUT_FILE"
done

echo "Network scan complete. Results saved to $OUTPUT_FILE"
