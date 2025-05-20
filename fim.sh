#!/bin/bash

# Simple File Integrity Checker

# First, create a baseline: ./fim.sh --baseline /etc /usr/bin/myapp
# Second, verify files (whenever needed): ./fim.sh --verify
# Note: May need to run in sudo.

#!/bin/bash

# Simple File Integrity Checker

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASELINE_FILE="$SCRIPT_DIR/fim_baseline.sha256"
RESULTS_FILE="$SCRIPT_DIR/FIM Results"

MODE="$1" # --baseline or --verify
TARGET_DIRS=("${@:2}") # All arguments after the first one

# --- Function to generate checksums for specified directories/files ---
generate_checksums() {
    local output_file="$1"
    shift # Remove output_file from arguments, remaining are targets
    local targets=("$@")

    echo "Generating checksums for: ${targets[*]}"
    > "$output_file"

    for target in "${targets[@]}"; do
        if [ -d "$target" ]; then
            find "$target" -type f -print0 | xargs -0 sha256sum >> "$output_file"
        elif [ -f "$target" ]; then
            sha256sum "$target" >> "$output_file"
        else
            echo "Warning: Target '$target' is not a valid file or directory. Skipping."
        fi
    done

    # Optional: sort the output for consistent order
    # sort "$output_file" -o "$output_file"

    echo "Checksum generation complete. Output to $output_file"
}

# --- Main logic ---
case "$MODE" in
    --baseline)
        if [ ${#TARGET_DIRS[@]} -eq 0 ]; then
            echo "Error: No target directories or files specified for baseline."
            echo "Usage: $0 --baseline /path/to/dir1 /path/to/file1..."
            exit 1
        fi
        generate_checksums "$BASELINE_FILE" "${TARGET_DIRS[@]}"
        echo "Baseline created in $BASELINE_FILE"
        ;;

    --verify)
        if [ ! -f "$BASELINE_FILE" ]; then
            echo "Error: Baseline file '$BASELINE_FILE' not found. Please create a baseline first." | tee "$RESULTS_FILE"
            echo "Usage: $0 --baseline /path/to/dir1..." | tee -a "$RESULTS_FILE"
            exit 1
        fi

        echo "Verifying file integrity against '$BASELINE_FILE'..." | tee "$RESULTS_FILE"
        sha256sum -c "$BASELINE_FILE" | tee -a "$RESULTS_FILE"

        if [ ${PIPESTATUS[0]} -ne 0 ]; then
            echo "❌ One or more files have been modified or are missing!" | tee -a "$RESULTS_FILE"
            exit 1
        else
            echo "✅ All files passed integrity check." | tee -a "$RESULTS_FILE"
        fi
        ;;

    *)
        echo "Invalid mode: $MODE"
        echo "Usage:"
        echo "  $0 --baseline /path/to/dir1 /path/to/file1..."
        echo "  $0 --verify"
        exit 1
        ;;
esac
