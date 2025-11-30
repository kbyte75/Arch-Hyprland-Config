#!/usr/bin/env bash

get_class() {
    hyprctl activewindow -j | jq -r '.class // "DESKTOP"' | tr '[:lower:]' '[:upper:]'
}

# Initial
echo "$(get_class)"
