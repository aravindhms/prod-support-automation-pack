#!/bin/bash

# Log Archiver Script
# Archives logs older than N days into a tar.gz file and deletes the originals.
# Usage: ./log_archiver.sh <log_directory> <retention_days>

LOG_DIR=$1
DAYS=$2
ARCHIVE_DIR="$LOG_DIR/archive"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="archiver.log"

if [ -z "$LOG_DIR" ] || [ -z "$DAYS" ]; then
    echo "Usage: $0 <log_directory> <retention_days>"
    exit 1
fi

if [ ! -d "$LOG_DIR" ]; then
    echo "Error: Directory '$LOG_DIR' does not exist."
    exit 1
fi

# Create archive directory if it doesn't exist
mkdir -p "$ARCHIVE_DIR"

echo "$(date): Starting archival for logs older than $DAYS days in $LOG_DIR" | tee -a "$LOG_FILE"

# Find files older than N days (excluding the archive dir itself)
FILES=$(find "$LOG_DIR" -maxdepth 1 -type f -mtime +$DAYS)

if [ -z "$FILES" ]; then
    echo "$(date): No files found older than $DAYS days." | tee -a "$LOG_FILE"
    exit 0
fi

# Create Archive
ARCHIVE_NAME="logs_archive_${TIMESTAMP}.tar.gz"
tar -czf "$ARCHIVE_DIR/$ARCHIVE_NAME" $FILES

if [ $? -eq 0 ]; then
    echo "$(date): Successfully archived to $ARCHIVE_DIR/$ARCHIVE_NAME" | tee -a "$LOG_FILE"
    
    # Delete original files
    rm $FILES
    echo "$(date): Deleted original files." | tee -a "$LOG_FILE"
else
    echo "$(date): Failed to create archive." | tee -a "$LOG_FILE"
    exit 1
fi
