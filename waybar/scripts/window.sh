#!/usr/bin/env bash
class=$(hyprctl activewindow -j | jq -r '.class')
[[ $class == "null" || -z $class ]] && echo "| DESKTOP" || echo "| $class" | tr '[:lower:]' '[:upper:]'