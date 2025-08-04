#!/bin/bash

# Change to the script's directory
cd "$(dirname "$0")"

# Check if snapd is installed
if ! command -v snap &>/dev/null; then
  zenity --error --title="Snapd Missing" \
    --text="Snapd is not installed. Please install it first:\n\nsudo apt install snapd"
  exit 1
fi

# Install the snap package
if [[ -f layerbase_1.0.0_arm64.snap ]]; then
  gnome-terminal -- bash -c "echo Installing Layerbase...; sudo snap install --dangerous layerbase_1.0.0_arm64.snap; echo Press Enter to exit; read"
else
  zenity --error --title="File Missing" \
    --text="The file 'layerbase_1.0.0_arm64.snap' was not found in this folder."
  exit 1
fi
