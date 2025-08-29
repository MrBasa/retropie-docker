#!/bin/bash

# A final, clean script to prepare the host and build the RetroPie container image.

CONTAINER_NAME="retropie"
IMAGE_NAME="retropie"
DATA_DIR="retropie-data"

# --- Step 1: Full Cleanup ---
echo "Performing full cleanup..."
if sudo podman ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    sudo podman stop "$CONTAINER_NAME" >/dev/null 2>&1
    sudo podman rm "$CONTAINER_NAME" >/dev/null 2>&1
fi
if sudo podman image exists "$IMAGE_NAME"; then
    sudo podman rmi -f "$IMAGE_NAME" >/dev/null 2>&1
fi

# --- Step 2: Prepare Host Directory ---
if [ ! -d "$DATA_DIR" ]; then
    echo "Creating data directory: $DATA_DIR"
    mkdir -p "$DATA_DIR"
fi

# --- Step 3: Set Permissions ---
# The 'pie' user inside the container needs to own the data volume.
# This command sets the ownership of the host directory to match.
echo "Setting permissions for '$DATA_DIR'..."
sudo chown -R 1000:1000 "$DATA_DIR"

# --- Step 4: Build Image ---
echo "Building container image '$IMAGE_NAME'..."
sudo podman build -t "$IMAGE_NAME" .

if [ $? -eq 0 ]; then
    echo "Build successful. Image '$IMAGE_NAME' is ready."
else
    echo "Build failed."
fi
