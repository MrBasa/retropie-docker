#!/bin/bash

# A script to perform a full cleanup, prepare directories, and build the RetroPie image.

CONTAINER_NAME="retropie"
IMAGE_NAME="retropie"

# --- Step 1: Full Cleanup ---
echo "Performing full cleanup..."

# Check for and remove the existing container.
if sudo podman ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "   - Found existing container '$CONTAINER_NAME'. Removing it..."
    sudo podman stop "$CONTAINER_NAME" >/dev/null 2>&1
    sudo podman rm "$CONTAINER_NAME" >/dev/null 2>&1
fi

# Check for and remove the existing image.
if sudo podman image exists "$IMAGE_NAME"; then
    echo "   - Found existing image '$IMAGE_NAME'. Removing it..."
    sudo podman rmi "$IMAGE_NAME" >/dev/null 2>&1
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

# --- Step 3: Build Image ---
echo "Building container image '$IMAGE_NAME' from scratch..."
# We use --no-cache to ensure a completely fresh build, avoiding old layers.
sudo podman build --no-cache -t "$IMAGE_NAME" .

# Check the exit code of the build command.
if [ $? -eq 0 ]; then
    echo "Build successful. Image '$IMAGE_NAME' is ready."
else
    echo "Build failed."
fi
