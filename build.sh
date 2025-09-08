#!/bin/bash
#
# This script builds and manages the RetroPie container.
#
# USAGE:
#   ./build.sh              - Builds the container, using cache for speed.
#   ./build.sh full-rebuild - Cleans everything and builds from scratch.
#   ./build.sh clean        - Removes the container and unused images.
#

# Exit immediately if a command exits with a non-zero status.
set -euo pipefail

# --- Step 1: Verify and Load Configuration ---
echo "▶️ Loading configuration from .env file..."
# Corrected the filename back to .env
if [ ! -f default.env ]; then
    echo "❌ Error: .env file not found!"
    exit 1
fi

# Use set -a to automatically export all variables sourced from the .env file.
set -a
source default.env
set +a

# --- Functions ---

# Function to perform a full cleanup
full_cleanup() {
    echo "🧹 Performing full cleanup..."

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
}

# Function for a partial/quick cleanup
quick_cleanup() {
    echo "🧹 Performing cleanup..."
    # Stop and remove the container if it exists, but leave the image cache alone.
    if podman ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        echo "   - Stopping and removing existing container..."
        podman stop "${CONTAINER_NAME}" && podman rm "${CONTAINER_NAME}"
    fi
}


# --- Main Script Logic ---

# Default to 'build' if no argument is provided
COMMAND=${1:-build}

case "$COMMAND" in
    full-rebuild)
        echo "▶️ Starting full-rebuild..."
        full_cleanup
        echo "▶️ Starting fresh build with no cache..."
        podman-compose '--userns keep-id --group-add keep-groups' up --build --no-cache -d | tee build.log
        echo "✅ Full rebuild completed successfully!"
        ;;

    clean)
        echo "▶️ Cleaning up..."
        full_cleanup
        echo "✅ Cleanup completed successfully!"
        ;;

    build|*)
        echo "▶️ Starting standard build..."
        quick_cleanup
        echo "▶️ Building and deploying with cache..."
        podman-compose --pod-args '--userns keep-id --group-add keep-groups' up --build -d | tee build.log
        echo "✅ Standard build completed successfully!"
        ;;
esac
