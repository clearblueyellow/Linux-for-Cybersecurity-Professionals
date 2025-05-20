#!/bin/bash

# Script for basic user account security audit

REPORT_FILE="user_audit_report_$(date +"%Y%m%d_%H%M%S").txt"
INACTIVE_DAYS_THRESHOLD=90 # Days for inactivity warning

# ANSI escape codes for coloring output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Function to echo to screen with colors and to file without colors
log_message() {
    local message="$1"
    local color="$2" # Optional color code
    local no_color_message

    # Remove ANSI escape codes for the file version
    no_color_message=$(echo -e "$message" | sed -r "s/\x1B\[[0-9;]*[mK]//g")

    if [ -n "$color" ]; then
        echo -e "${color}${message}${NC}"
    else
        echo -e "${message}"
    fi
    echo "$no_color_message" >> "$REPORT_FILE"
}

# Initial messages written directly, as they don't have colors at this point
echo "Starting User Account Security Audit..." | tee "$REPORT_FILE"
echo "Report Date: $(date)" | tee -a "$REPORT_FILE"
echo "----------------------------------------" | tee -a "$REPORT_FILE"

# 1. Check for users with UID 0 (other than root)
log_message "\n[*] Checking for non-root accounts with UID 0..."
UID0_USERS=$(awk -F: '($3 == 0 && $1 != "root") { print $1 }' /etc/passwd)
if [ -n "$UID0_USERS" ]; then
    log_message "WARNING: The following non-root accounts have UID 0 (root privileges):" "$RED"
    echo "$UID0_USERS" | sed 's/^/  - /' | tee -a "$REPORT_FILE" # Still use tee here as no colors are involved
else
    log_message "No non-root accounts with UID 0 found." "$GREEN"
fi

# 2. Check for accounts with empty or locked password fields
log_message "\n[*] Checking for accounts with empty or locked password fields (requires root)..."
if [ -r /etc/shadow ]; then
    EMPTY_LOCKED_PASS_USERS=$(sudo awk -F: '($2 == "" || $2 == "!" || $2 == "*") { print $1 }' /etc/shadow 2>/dev/null)
    if [ -n "$EMPTY_LOCKED_PASS_USERS" ]; then
        log_message "WARNING: The following accounts have empty, locked, or disabled passwords:" "$YELLOW"
        echo "$EMPTY_LOCKED_PASS_USERS" | sed 's/^/  - /' | tee -a "$REPORT_FILE"
    else
        log_message "No accounts with empty, locked, or disabled passwords found." "$GREEN"
    fi
else
    log_message "ERROR: Cannot read /etc/shadow. Run script with sudo or as root for full audit." "$RED"
fi

# 3. Check password aging and expiry for regular users (UID >= 1000, excluding nologin shells)
log_message "\n[*] Checking password aging and expiry for regular users..."
found_aging_issues=false

while IFS=: read -r username _ uid _ _ _ shell; do
    if [ "$uid" -ge 1000 ] && [[ "$shell" != *"/sbin/nologin"* && "$shell" != *"/bin/false"* ]]; then
        log_message "  Auditing user: $username"
        if sudo chage -l "$username" &>/dev/null; then
            # Capture chage output, remove colors, and then log
            CHAGE_OUTPUT=$(sudo chage -l "$username" | grep -E 'Password expires|Password inactive|Account expires|Minimum number of days between password change|Maximum number of days between password change' | sed 's/^/    /')
            log_message "$CHAGE_OUTPUT" # Log without explicit color, chage output doesn't have it

            EXPIRES_DATE_RAW=$(sudo chage -l "$username" | grep "Password expires" | cut -d: -f2 | sed 's/^[ \t]*//')
            if [[ "$EXPIRES_DATE_RAW" != "never" && -n "$EXPIRES_DATE_RAW" ]]; then
                EXPIRES_SECONDS=$(date -d "$EXPIRES_DATE_RAW" +%s 2>/dev/null)
                CURRENT_SECONDS=$(date +%s)
                if (( EXPIRES_SECONDS < CURRENT_SECONDS )); then
                    log_message "    WARNING: Password for $username has expired!" "$RED"
                    found_aging_issues=true
                fi
            fi

            INACTIVE_DATE_RAW=$(sudo chage -l "$username" | grep "Password inactive" | cut -d: -f2 | sed 's/^[ \t]*//')
            if [[ "$INACTIVE_DATE_RAW" != "never" && -n "$INACTIVE_DATE_RAW" ]]; then
                 INACTIVE_SECONDS=$(date -d "$INACTIVE_DATE_RAW" +%s 2>/dev/null)
                 CURRENT_SECONDS=$(date +%s)
                 if (( INACTIVE_SECONDS < CURRENT_SECONDS )); then
                     log_message "    WARNING: Password for $username is inactive!" "$RED"
                     found_aging_issues=true
                 fi
            fi

        else
            log_message "    ERROR: Could not get password aging info for $username (requires root)." "$RED"
            found_aging_issues=true
        fi
        echo "" >> "$REPORT_FILE" # Add a blank line for readability in file
        echo "" # Blank line for terminal output
    fi
done < /etc/passwd

if ! $found_aging_issues; then
    log_message "No immediate password aging or expiry issues found for regular users." "$GREEN"
fi


# 4. Check for accounts not logged in for a long time (requires root for lastlog)
log_message "\n[*] Checking for accounts not logged in for over $INACTIVE_DAYS_THRESHOLD days (requires root)..."
found_inactive_users=false
if command -v lastlog &> /dev/null; then
    NOW_SECONDS=$(date +%s)
    INACTIVE_THRESHOLD_SECONDS=$((INACTIVE_DAYS_THRESHOLD * 86400))

    LASTLOG_OUTPUT=$(sudo lastlog 2>/dev/null | tail -n +2)

    if [ -z "$LASTLOG_OUTPUT" ]; then
        log_message "No users found via lastlog (or no login activity recorded)." "$GREEN"
    else
        echo "$LASTLOG_OUTPUT" | while IFS= read -r line; do
            USER_NAME=$(echo "$line" | awk '{print $1}')
            LAST_LOGIN_DATE_STR=$(echo "$line" | awk '{
                for (i=5; i<=NF; i++) {
                    if ($i ~ /Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec/) {
                        if ($(i+2) ~ /^[0-9]{4}$/) {
                            print $i, $(i+1), $(i+2);
                        } else if ($(i+3) ~ /^[0-9]{4}$/) {
                            print $i, $(i+1), $(i+3);
                        } else {
                            print $i, $(i+1), strftime("%Y");
                        }
                        exit;
                    }
                }
            }')

            USER_UID=$(id -u "$USER_NAME" 2>/dev/null)

            if [ "$USER_UID" -ge 1000 ] && [[ "$USER_NAME" != "nobody" && "$USER_NAME" != "nfsnobody" && -n "$USER_NAME" ]]; then
                if [ "$LAST_LOGIN_DATE_STR" == "**Never logged in**" ] || [ -z "$(echo "$LAST_LOGIN_DATE_STR" | xargs)" ]; then
                    log_message "  INFO: User ${USER_NAME} (UID: $USER_UID) has never logged in. Consider if account is needed." "$YELLOW"
                    found_inactive_users=true
                else
                    LAST_LOGIN_SECONDS=$(date -d "$LAST_LOGIN_DATE_STR" +%s 2>/dev/null)

                    if [ -n "$LAST_LOGIN_SECONDS" ]; then
                        DAYS_AGO=$(( (NOW_SECONDS - LAST_LOGIN_SECONDS) / 86400 ))
                        if (( DAYS_AGO > INACTIVE_DAYS_THRESHOLD )); then
                            log_message "  WARNING: User ${USER_NAME} (UID: $USER_UID) has not logged in for ${DAYS_AGO} days." "$YELLOW"
                            found_inactive_users=true
                        fi
                    else
                        log_message "  WARNING: Could not parse last login date for user $USER_NAME: '$LAST_LOGIN_DATE_STR'. Manual check recommended." "$YELLOW"
                        found_inactive_users=true
                    fi
                fi
            fi
        done
    fi

    if ! $found_inactive_users; then
        log_message "No regular users found inactive for over ${INACTIVE_DAYS_THRESHOLD} days." "$GREEN"
    fi
else
    log_message "ERROR: 'lastlog' command not found. Cannot check for inactive accounts." "$RED"
fi

log_message "\n----------------------------------------"
log_message "User Account Security Audit Complete. Report saved to $REPORT_FILE"
log_message "----------------------------------------"
