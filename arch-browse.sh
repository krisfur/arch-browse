#!/bin/bash

# Search Logic (Standard Bottom-Up Layout)
SEARCH_CMD="yay -Ss {q} --topdown --color=always | paste - - | awk '{printf \"%-40s  \t %s\n\", \$1, \$0}'"

rm -f /tmp/arch-browser-selection

fzf --ansi \
    --disabled \
    --header="BROWSE AUR (Start typing...)" \
    --prompt="Search > " \
    --bind "start:reload:$SEARCH_CMD" \
    --bind "change:first+deselect-all+reload:$SEARCH_CMD" \
    --preview "echo {1} | cut -d'/' -f2 | cut -d' ' -f1 | xargs -I % yay -Si % | bat --color=always --style=plain -l yaml" \
    --preview-window=right:50%:wrap \
    --bind "enter:execute(echo {1} > /tmp/arch-browser-selection)+abort" \
    --bind "ctrl-a:select-all,ctrl-d:deselect-all"

# Installation Logic
if [ -f /tmp/arch-browser-selection ]; then
    RAW_SELECTION=$(cat /tmp/arch-browser-selection)
    
    if [ -n "$RAW_SELECTION" ]; then
        PKG_NAME=$(echo "$RAW_SELECTION" | awk '{print $1}' | cut -d'/' -f2)
        echo "Installing: $PKG_NAME"
        yay -S $PKG_NAME
    fi
    rm /tmp/arch-browser-selection
fi
