#!/bin/bash
DIR=$1
while true; do
  inotifywait -e create "$DIR"
  echo "New file arrived in $DIR"
done
