#!/bin/bash

# Script to list firewall rules (iptables or UFW)

echo "Firewall Rule Lister"
echo "--------------------"

# Check for UFW
if command -v ufw &> /dev/null; then
    echo "[*] UFW (Uncomplicated Firewall) detected."
    UFW_STATUS=$(sudo ufw status | head -n 1)
    echo "UFW Status: $UFW_STATUS"

    if]; then
        echo ""
        echo "[+] UFW Rules (Numbered):"
        sudo ufw status numbered
        echo ""
        echo "[+] UFW Rules (Verbose):"
        sudo ufw status verbose
    elif]; then
        echo "UFW is inactive. Showing configured rules (if any)..."
        sudo ufw show added
    else
        echo "Could not determine UFW status or UFW is not configured."
    fi
    echo "--------------------"
fi

# Check for iptables
# Even if UFW is used, iptables is the backend, but direct iptables rules might exist.
if command -v iptables &> /dev/null; then
    echo ""
    echo "[*] iptables rules:"
    echo "Note: If UFW is active, these rules are likely managed by UFW."
    
    echo ""
    echo "[+] iptables Filter Table Rules (INPUT, FORWARD, OUTPUT chains):"
    sudo iptables -L -n -v --line-numbers
    echo ""

    echo "[+] iptables NAT Table Rules:"
    sudo iptables -t nat -L -n -v --line-numbers
    echo ""
    
    echo "[+] iptables Mangle Table Rules:"
    sudo iptables -t mangle -L -n -v --line-numbers
    echo ""

else
    if! command -v ufw &> /dev/null; then # If neither UFW nor iptables found
         echo "Error: Neither UFW nor iptables found on this system."
         exit 1
    fi
fi

echo "Firewall rule listing complete."
