#!/bin/bash

# Script for basic user account security audit

REPORT_FILE="user_audit_report_$(date +"%Y%m%d_%H%M%S").txt"
INACTIVE_DAYS_THRESHOLD=90 # Days for inactivity warning

echo "Starting User Account Security Audit..." | tee "$REPORT_FILE"
echo "Report Date: $(date)" | tee -a "$REPORT_FILE"
echo "----------------------------------------" | tee -a "$REPORT_FILE"

# 1. Check for users with UID 0 (other than root)
echo "[*] Checking for non-root accounts with UID 0..." | tee -a "$REPORT_FILE"
awk -F: '($3 == 0 && $1!= "root") { print " User \033 Checking for accounts with empty or locked password fields (requires root)..." | tee -a "$REPORT_FILE"
if [ -r /etc/shadow ]; then
    sudo awk -F: '($2 == "" |
| $2 == "!" |
| $2 == "*") { print " User \033 Cannot read /etc/shadow. Run script with sudo or as root." | tee -a "$REPORT_FILE"
fi
echo "" | tee -a "$REPORT_FILE"

# 3. Check password aging and expiry for regular users (UID >= 1000, excluding nologin shells)
echo "[*] Checking password aging and expiry for regular users..." | tee -a "$REPORT_FILE"
while IFS=: read -r username _ uid _ _ _ shell; do
    if [ "$uid" -ge 1000 ] && [[ "$shell"!= *"/sbin/nologin"* && "$shell"!= *"/bin/false"* ]]; then
        echo "  Auditing user: $username" | tee -a "$REPORT_FILE"
        # Requires root privileges for chage
        if sudo chage -l "$username" &>/dev/null; then
            sudo chage -l "$username" | grep -E 'Password expires|Password inactive|Account expires|Minimum number of days between password change|Maximum number of days between password change' | sed 's/^/    /' | tee -a "$REPORT_FILE"
            
            # Check if password has expired
            EXPIRES_DATE=$(sudo chage -l "$username" | grep "Password expires" | cut -d: -f2 | sed 's/^[ \t]*//')
            if]; then
                EXPIRES_SECONDS=$(date -d "$EXPIRES_DATE" +%s 2>/dev/null)
                CURRENT_SECONDS=$(date +%s)
                if]; then
                    echo "    \033 Password for $username has expired!\033 Could not get password aging info for $username (requires root)." | tee -a "$REPORT_FILE"
        fi
        echo "" | tee -a "$REPORT_FILE"
    fi
done < /etc/passwd
echo "" | tee -a "$REPORT_FILE"

# 4. Check for accounts not logged in for a long time (requires root for lastlog)
echo "[*] Checking for accounts not logged in for over $INACTIVE_DAYS_THRESHOLD days (requires root)..." | tee -a "$REPORT_FILE"
if command -v lastlog &> /dev/null; then
    # Get current date in seconds since epoch
    NOW_SECONDS=$(date +%s)
    # lastlog output can be tricky to parse reliably across all systems.
    # This is a best-effort approach.
    sudo lastlog | tail -n +2 | while IFS= read -r line; do
        USER_NAME=$(echo "$line" | awk '{print $1}')
        LAST_LOGIN_INFO=$(echo "$line" | awk '{$1=""; print $0}' | sed 's/^[ \t]*//')

        if]; then
            # Potentially check account creation date if available, otherwise flag as never logged in.
            # For simplicity, we'll just note it here. If UID >= 1000, it might be a concern.
            USER_UID=$(id -u "$USER_NAME" 2>/dev/null)
            if]; then
                 echo "  [INFO] User \033]; then
                DAYS_AGO=$(( (NOW_SECONDS - LAST_LOGIN_SECONDS) / 86400 ))
                if; then
                    USER_UID=$(id -u "$USER_NAME" 2>/dev/null)
                    if]; then # Only flag regular users
                        echo "  User \033 lastlog command not found." | tee -a "$REPORT_FILE"
fi

echo "----------------------------------------" | tee -a "$REPORT_FILE"
echo "User Account Security Audit Complete. Report saved to $REPORT_FILE"
