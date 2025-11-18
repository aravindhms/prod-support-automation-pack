#!/bin/bash
find /var/log -name "*.log" -mtime +7 -delete
echo "Old logs cleaned."
