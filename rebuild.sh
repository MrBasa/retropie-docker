#!/bin/bash
#
# This script completely tears down and rebuilds the RetroPie container.
#

# Exit immediately if a command exits with a non-zero status.
set -e

# Source environment variables from .env file
source .env

# --- Step 1: Full Cleanup ---
echo "Performing full cleanup..."

# Stop and remove the container if it exists
if podman ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "Stopping and removing existing container..."
    podman stop "${CONTAINER_NAME}" && podman rm "${CONTAINER_NAME}"
    echo "${CONTAINER_NAME} Removed!"
fi

# Remove the image if it exists
if podman image exists "${IMAGE_NAME}"; then
    echo "Removing the container image..."
    podman rmi -f "${IMAGE_NAME}"
    echo "${IMAGE_NAME} Removed!"
fi

# Prune any dangling/unused images to save space
echo "Pruning unused images..."
podman image prune -f

# --- Step 2: Build & Deploy ---
echo "Starting fresh build and deploying..."
# Build the image ONCE with the necessary security option.
podman-compose --pod-args '--userns keep-id' up --build -d | tee build.log
