#!/bin/bash

SEARCH_CMD='
if [ ${#1} -lt 2 ]; then exit 0; fi
yay -Ss "$1" --topdown --color=always 2>&1 \
| sed -E "/Query arg too small|Error during AUR search|Showing repo packages|Too many package results|^\s*$/d" \
| paste - - \
| awk "{printf \"%-40s  \t %s\n\", \$1, \$0}" || true
'

rm -f /tmp/arch-browser-selection
fzf --ansi \
    --disabled \
    --header="BROWSE PACKAGES (Tab: Select | Enter: Install)" \
    --prompt="Search > " \
    --bind "start:reload:bash -c '$SEARCH_CMD' -- ''" \
    --bind "change:first+deselect-all+reload:bash -c '$SEARCH_CMD' -- {q}" \
    --preview "PKG=\$(echo {1} | grep -oP '[a-z0-9_-]+/[a-z0-9._-]+' | head -1 | cut -d/ -f2); \
               yay -Si \$PKG 2>/dev/null | bat --color=always --style=plain -l yaml 2>/dev/null || yay -Si \$PKG 2>/dev/null" \
    --preview-window=right:50%:wrap \
    --bind "enter:execute(echo {1} > /tmp/arch-browser-selection)+abort" \
    --bind "ctrl-a:select-all,ctrl-d:deselect-all"

if [ -f /tmp/arch-browser-selection ]; then
    RAW_SELECTION=$(cat /tmp/arch-browser-selection)
    if [ -n "$RAW_SELECTION" ]; then
        PKG_NAME=$(echo "$RAW_SELECTION" | grep -oP '[a-z0-9_-]+/[a-z0-9._-]+' | head -1 | cut -d/ -f2)
        echo "Installing: $PKG_NAME"
        yay -S $PKG_NAME
    fi
    rm /tmp/arch-browser-selection
fi