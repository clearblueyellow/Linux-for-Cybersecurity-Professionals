#!/bin/bash

# Simple File Integrity Checker

BASELINE_FILE="fim_baseline.sha256"
MODE="$1" # --baseline or --verify
TARGET_DIRS=("${@:2}") # Get all arguments after the first one

# --- Function to generate checksums for specified directories/files ---
generate_checksums() {
    local output_file="$1"
    shift # Remove output_file from arguments, remaining are targets
    local targets=("$@")

    echo "Generating checksums for: ${targets[*]}"
    # Ensure output file is empty or use > to overwrite
    > "$output_file" 

    for target in "${targets[@]}"; do
        if [ -d "$target" ]; then
            # Find all files in directory, calculate checksum, and append
            find "$target" -type f -print0 | xargs -0 sha256sum >> "$output_file"
        elif [ -f "$target" ]; then
            # Calculate checksum for a single file and append
            sha256sum "$target" >> "$output_file"
        else
            echo "Warning: Target '$target' is not a valid file or directory. Skipping."
        fi
    done
    # Sort the baseline for consistent diff later, if needed, though sha256sum -c handles it.
    # sort "$output_file" -o "$output_file" 
    echo "Checksum generation complete. Output to $output_file"
}

# --- Main script logic ---

case "$MODE" in
    --baseline)
        if} -eq 0 ]; then
            echo "Error: No target directories or files specified for baseline."
            echo "Usage: $0 --baseline /path/to/dir1 /path/to/file1..."
            exit 1
        fi
        generate_checksums "$BASELINE_FILE" "${TARGET_DIRS[@]}"
        echo "Baseline created in $BASELINE_FILE"
        ;;

    --verify)
        if; then
            echo "Error: Baseline file '$BASELINE_FILE' not found. Please create a baseline first."
            echo "Usage: $0 --baseline /path/to/dir1..."
            exit 1
        fi

        echo "Verifying file integrity against '$BASELINE_FILE'..."
        
        # sha256sum -c will check each file listed in the baseline file.
        # --quiet: don't print OK for each file
        # --status: don't output anything, status code indicates success (0) or failure (1 or more)
        # We want the output, so we won't use --status or --quiet for this demonstration script.
        
        sha256sum -c "$BASELINE_FILE"
        
        if [ $? -eq 0 ]; then
            echo -e "\033"
        echo "       $0 --verify"
        exit 1
        ;;
esac
