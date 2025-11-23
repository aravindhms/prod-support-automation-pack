#!/bin/bash

# Process Restarter Script
# Checks if a process is running. If not, attempts to restart it.
# Usage: ./process_restarter.sh <process_name> "<start_command>"

PROCESS_NAME=$1
START_CMD=$2
LOG_FILE="restart_log.log"

if [ -z "$PROCESS_NAME" ] || [ -z "$START_CMD" ]; then
    echo "Usage: $0 <process_name> \"<start_command>\""
    exit 1
fi

# Check if process is running
if pgrep -x "$PROCESS_NAME" > /dev/null; then
    echo "$(date): Process '$PROCESS_NAME' is running."
else
    echo "$(date): Process '$PROCESS_NAME' is NOT running. Attempting to restart..." | tee -a "$LOG_FILE"
    
    # Execute start command
    eval "$START_CMD"
    
    # Verify if it started
    sleep 2
    if pgrep -x "$PROCESS_NAME" > /dev/null; then
        echo "$(date): Successfully restarted '$PROCESS_NAME'." | tee -a "$LOG_FILE"
    else
        echo "$(date): FAILED to restart '$PROCESS_NAME'." | tee -a "$LOG_FILE"
        exit 1
    fi
fi
