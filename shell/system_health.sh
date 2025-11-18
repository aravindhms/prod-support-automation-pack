#!/bin/bash

echo "=== SYSTEM HEALTH CHECK ==="
echo "Timestamp: $(date)"

echo ""
echo "--- CPU Usage ---"
top -bn1 | grep "Cpu(s)"

echo ""
echo "--- Memory Usage ---"
free -h

echo ""
echo "--- Disk Usage ---"
df -h

echo ""
echo "--- Network Check ---"
if ping -c 2 google.com >/dev/null 2>&1; then
    echo "Internet: OK"
else
    echo "Internet: FAIL"
fi
