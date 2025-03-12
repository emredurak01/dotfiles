#!/bin/bash

# Script to hide desktop entries

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No color

# Directory for local .desktop overrides
LOCAL_APPS="$HOME/.local/share/applications"
SYSTEM_APPS="/usr/share/applications"

# Ensure the local applications directory exists
mkdir -p "$LOCAL_APPS"

# Get all desktop entries
mapfile -t entries < <(find "$SYSTEM_APPS" -maxdepth 1 -name "*.desktop" -exec basename {} \; | sort | uniq)

# Display desktop entries
clear
echo -e "${CYAN}Available Desktop Entries:${NC}"
for i in "${!entries[@]}"; do
    filename="${entries[$i]}"
    system_file="$SYSTEM_APPS/$filename"
    local_file="$LOCAL_APPS/$filename"
    
    # Determine which file to check
    if [[ -f "$local_file" ]]; then
        file="$local_file"
    else
        file="$system_file"
    fi
    
    # Check if NoDisplay=true is set
    if [[ -f "$local_file" && $(grep -m1 '^NoDisplay=true' "$local_file") ]]; then
        echo -e "${RED}$((i+1))) $filename [HIDDEN]${NC}"
    else
        echo -e "${GREEN}$((i+1))) $filename [VISIBLE]${NC}"
    fi
done

echo -e "${YELLOW}Select numbers to toggle visibility (separate with space, or 'q' to quit):${NC}"
read -r -a choices

# Exit if user chooses 'q'
if [[ "${choices[0]}" == "q" ]]; then
    exit 0
fi

for choice in "${choices[@]}"; do
    # Validate choice
    if ! [[ "$choice" =~ ^[0-9]+$ ]] || (( choice < 1 || choice > ${#entries[@]} )); then
        echo -e "${RED}Invalid selection: $choice${NC}"
        continue
    fi

    # Get selected file
    index=$((choice - 1))
    filename="${entries[$index]}"
    system_file="$SYSTEM_APPS/$filename"
    local_file="$LOCAL_APPS/$filename"

    # Copy file to local applications directory if not already present
    if [[ ! -f "$local_file" ]]; then
        cp "$system_file" "$local_file"
    fi

    # Check if NoDisplay is already set and toggle it
    if grep -q '^NoDisplay=true' "$local_file"; then
        sed -i '/^NoDisplay=true/d' "$local_file"
        echo -e "${GREEN}$filename is now VISIBLE.${NC}"
    elif grep -q '^NoDisplay=false' "$local_file"; then
        sed -i 's/^NoDisplay=false/NoDisplay=true/' "$local_file"
        echo -e "${RED}$filename is now HIDDEN.${NC}"
    else
        sed -i '/\[Desktop Entry\]/a NoDisplay=true' "$local_file"
        echo -e "${RED}$filename is now HIDDEN.${NC}"
    fi
done

# Refresh desktop database
update-desktop-database "$LOCAL_APPS"
