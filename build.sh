#!/bin/bash

# A final, clean script to prepare the host and build the RetroPie container image.

CONTAINER_NAME="retropie"
IMAGE_NAME="retropie"
DATA_DIR="retropie-data"

# --- Step 1: Full Cleanup ---
# This is a necessary step from our troubleshooting to ensure a clean build.
echo "Performing full cleanup..."
if sudo podman ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    sudo podman stop "$CONTAINER_NAME" >/dev/null 2>&1
    sudo podman rm "$CONTAINER_NAME" >/dev/null 2>&1
fi
if sudo podman image exists "$IMAGE_NAME"; then
    sudo podman rmi "$IMAGE_NAME" >/dev/null 2>&1
fi

# --- Step 2: Prepare Host Directories ---
# This is a necessary one-time setup step.
DIRS=(
    "$DATA_DIR/configs"
    "$DATA_DIR/configs-all"
    "$DATA_DIR/bios"
    "$DATA_DIR/roms"
    "$DATA_DIR/saves"
    "$DATA_DIR/states"
)
for dir in "${DIRS[@]}"; do
    if [ ! -d "$dir" ]; then
        echo "Creating missing directory: $dir"
        mkdir -p "$dir"
    fi
done

# --- Step 3: Build Image ---
echo "Building container image '$IMAGE_NAME'..."
sudo podman build -t "$IMAGE_NAME" .

# Check the exit code of the build command.
if [ $? -eq 0 ]; then
    echo "Build successful. Image '$IMAGE_NAME' is ready."
else
    echo "Build failed."
fi
