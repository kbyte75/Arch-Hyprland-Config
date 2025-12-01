#!/usr/bin/env bash
hyprctl activewindow -j | jq -r '.class // "DESKTOP"' | tr '[:lower:]' '[:upper:]'