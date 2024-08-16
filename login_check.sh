#!/bin/bash
#set -x
LOG_FILE="/var/log/secure"
LAST_CHECK_FILE="/tmp/last_check_timestamp"
TEMP_FILE="/tmp/falled"
#CURRENT_TIMESTAMP=$(date |awk '{print $2, $3, $4}')

# Create or update the last check timestamp file
if [ ! -f "$LAST_CHECK_FILE" ]; then
     date +"%Y.%m.%d %H:%M:%S" > "$LAST_CHECK_FILE"
fi

LAST_CHECK_TIMESTAMP=$(cat "$LAST_CHECK_FILE")

# Search the log file for failed login attempts since the last check
grep "Failed password" "$LOG_FILE" | while read -r line; do
    # Extract timestamp from log line (adjust as needed)
    LOG_TIME=$(echo "$line" | awk '{print $1, $2, $3}') # Modify according to your log format

    # Convert log timestamp to seconds since epoch
    LOG_TIMESTAMP=$(date -d "$LOG_TIME" +"%Y.%m.%d %H:%M:%S")

    if [[ "$LOG_TIMESTAMP" != "$LAST_CHECK_TIMESTAMP" ]]; then
        echo "$line" >> "$TEMP_FILE"
    fi
done

# Update last check timestamp
echo "$CURRENT_TIMESTAMP" > "$LAST_CHECK_FILE"

# Check if any unauthorized login attempts were detected
if [ -s "$TEMP_FILE" ]; then
    echo "Unauthorized login attempts detected:"
    cat "$TEMP_FILE"
else
    echo "No unauthorized login attempts since the last check."
fi

# Clean up temporary file
rm "$TEMP_FILE"
