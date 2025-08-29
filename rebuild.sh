#!/bin/bash
# This script completely tears down and rebuilds the RetroPie container.
# WARNING: This will delete all saved games, configs, and ROMs.

echo "Stopping and removing existing containers and volumes..."
podman-compose down -v

echo "Removing the container image..."
podman rmi retropie

echo "Starting fresh build and deploying..."
podman-compose up -d --build
