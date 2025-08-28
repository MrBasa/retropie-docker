#!/bin/bash

# A script to clean up, prepare directories, and build the RetroPie image from scratch.

CONTAINER_NAME="retropie"

# --- Step 1: Cleanup ---
# Check if a container with the name already exists and remove it.
if sudo podman ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "Found existing container '$CONTAINER_NAME'. Cleaning it up..."
    sudo podman stop "$CONTAINER_NAME" >/dev/null 2>&1
    sudo podman rm "$CONTAINER_NAME"
fi

# --- Step 2: Prepare Directories ---
DIRS=(
    "retropie-data/configs"
    "retropie-data/configs-all"
    "retropie-data/bios"
    "retropie-data/roms"
    "retropie-data/saves"
    "retropie-data/states"
)

for dir in "${DIRS[@]}"; do
    if [ ! -d "$dir" ]; then
        echo "Creating missing directory: $dir"
        mkdir -p "$dir"
    fi
done

# --- Step 3: Build Image (with --no-cache) ---
echo "Building container image '$CONTAINER_NAME' from scratch..."
# The --no-cache flag forces a complete rebuild, ignoring old layers.
sudo podman build --no-cache -t "$CONTAINER_NAME" .

# Check the exit code of the build command.
if [ $? -eq 0 ]; then
    echo "Build successful. Image '$CONTAINER_NAME' is ready."
else
    echo "Build failed."
fi
