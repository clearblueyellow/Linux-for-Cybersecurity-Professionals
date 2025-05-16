#!/bin/bash

# Script for real-time log monitoring for specific keywords

# Prompt for log file path
read -p "Enter the full path to the log file to monitor: " LOG_FILE

# Check if log file exists and is readable
if [! -f "$LOG_FILE" ]; then
    echo "Error: Log file '$LOG_FILE' not found."
    exit 1
fi
if [! -r "$LOG_FILE" ]; then
    echo "Error: Log file '$LOG_FILE' is not readable."
    exit 1
fi

# Prompt for keywords
read -p "Enter keywords to monitor (comma-separated, e.g., Failed,Error,Denied): " KEYWORDS_INPUT

if; then
    echo "Error: No keywords provided."
    exit 1
fi

# Convert comma-separated keywords into a grep-compatible regex pattern (e.g., keyword1|keyword2)
KEYWORDS_REGEX=$(echo "$KEYWORDS_INPUT" | sed 's/,/|/g')

echo "Monitoring '$LOG_FILE' for keywords: $KEYWORDS_INPUT (Press Ctrl+C to stop)"
echo "----------------------------------------------------------------------"

# Use tail -f to follow the log file and pipe to grep
# --line-buffered: Flushes output on every line
# -E: Interpret PATTERNS as extended regular expressions (for '|')
# -i: Ignore case distinctions
tail -f "$LOG_FILE" | grep --line-buffered -E -i "$KEYWORDS_REGEX" | while IFS= read -r line; do
    echo " Keyword Matched: $line"
done
