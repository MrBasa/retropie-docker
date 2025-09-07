#!/bin/bash
#
# This script completely tears down and rebuilds the RetroPie container.
#

# Exit immediately if a command exits with a non-zero status.
set -euo pipefail

# --- Step 1: Verify and Load Configuration ---
echo "▶️ Loading configuration from .env file..."
if [ ! -f .env ]; then
    echo "❌ Error: .env file not found!"
    exit 1
fi

# Use set -a to automatically export all variables sourced from the .env file.
set -a
source .env
set +a

# --- Step 2: Verify Variables are Loaded ---
echo "✅ Configuration loaded. Verifying variables..."
echo "   - Username (UNAME): ${UNAME}"
echo "   - User ID (PUID):   ${PUID}"
echo "   - Group ID (PGID):  ${PGID}"
echo "   - CONTAINER_NAME:   ${CONTAINER_NAME}"
echo "   - IMAGE_NAME:       ${IMAGE_NAME}"

# Check if essential variables are empty. If the echo above shows a blank UNAME, this will catch it.
if [ -z "${UNAME}" ] || [ -z "${PUID}" ] || [ -z "${PGID}" ]; then
    echo "❌ Error: One or more required variables (UNAME, PUID, PGID) is not set in the .env file."
    exit 1
fi

# --- Step 3: Full Cleanup ---
echo "▶️ Performing full cleanup..."

# Stop and remove the container if it exists
if podman ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "   - Stopping and removing existing container..."
    podman stop "${CONTAINER_NAME}" && podman rm "${CONTAINER_NAME}"
fi

# Remove the image if it exists
if podman image exists "${IMAGE_NAME}"; then
    echo "   - Removing existing image..."
    podman rmi "${IMAGE_NAME}"
fi

# Prune any dangling/unused images to save space
echo "   - Pruning unused images..."
podman image prune -f

# --- Step 2: Build & Deploy ---
echo "▶️ Starting fresh build and deploying..."
# Build the image ONCE with the necessary security option.
podman-compose --pod-args '--userns keep-id' up --build -d | tee build.log

echo "✅ Script completed successfully!"
