#!/bin/bash
USE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$USE" -gt 80 ]; then
  echo "Disk usage critical: $USE%"
fi
