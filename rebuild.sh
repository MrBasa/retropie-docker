#!/bin/bash
# This script completely tears down and rebuilds the RetroPie container.

CONTAINER_NAME="retropie"
IMAGE_NAME="retropie"

# --- Step 1: Full Cleanup ---
echo "Performing full cleanup..."
if podman ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "Stopping and removing existing containers and volumes..."
    # podman-compose down -v
    podman stop "$CONTAINER_NAME" >/dev/null 2>&1
    podman rm "$CONTAINER_NAME" >/dev/null 2>&1
    echo "$CONTAINER_NAME Removed!"
fi
if podman image exists "$IMAGE_NAME"; then
    echo "Removing the container image..."
    podman rmi -f "$IMAGE_NAME" >/dev/null 2>&1
    echo "$IMAGE_NAME Removed!"
fi

# --- Step 2: Build ---
echo "Starting fresh build and deploying..."
#podman build --security-opt seccomp=unconfined -t retropie .
podman-compose --pod-args '--userns keep-id' up -d --build
