#!/bin/bash
SERVICES=(nginx sshd)
for S in "${SERVICES[@]}"; do
  systemctl is-active --quiet $S && echo "$S OK" || echo "$S DOWN"
done
