#!/bin/bash
tail -fn0 "$1" | grep --line-buffered -E "$2"
