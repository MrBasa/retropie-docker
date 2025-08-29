#!/bin/bash
# This script completely tears down and rebuilds the RetroPie container.
# WARNING: This will delete all saved games, configs, and ROMs.

#echo "Stopping and removing existing containers and volumes..."
#podman-compose down -v

#echo "Removing the container image..."
#podman rmi retropie

# --- Step 1: Full Cleanup ---
echo "Performing full cleanup..."
if sudo podman ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    sudo podman stop "$CONTAINER_NAME" >/dev/null 2>&1
    sudo podman rm "$CONTAINER_NAME" >/dev/null 2>&1
    echo "$CONTAINER_NAME Removed!"
fi
if sudo podman image exists "$IMAGE_NAME"; then
    sudo podman rmi -f "$IMAGE_NAME" >/dev/null 2>&1
    echo "$IMAGE_NAME Removed!"
fi

# --- Step 2: Build ---
echo "Starting fresh build and deploying..."
podman-compose --pod-args '--userns keep-id' up -d --build
