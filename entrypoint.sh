#!/bin/bash
# v0.0.4

# This script runs as root to prepare the container environment at runtime.

# Define paths for the persistent data directories.
CONFIGS_DIR="/home/pie/.emulationstation"
CONFIGS_ALL_DIR="/opt/retropie/configs"
RETROPIE_DIR="/home/pie/RetroPie"

# --- Data Volume Initialization ---
# Check if the config directories are empty. If they are, this is the first run.
if [ ! -d "${CONFIGS_ALL_DIR}/all" ]; then
  echo "First run detected: Populating default configurations..."
  # Copy the default configs from the backup location into the empty volume.
  cp -a /opt/retropie/configs.bak/. "${CONFIGS_ALL_DIR}"
fi

# Create other necessary directories if they don't exist.
mkdir -p "${CONFIGS_DIR}"
mkdir -p "${RETROPIE_DIR}"/{roms,BIOS,saves,states}

# --- Permissions Fix ---
# Set the ownership of all mounted directories to the 'pie' user.
chown -R pie:pie "${CONFIGS_DIR}" "${CONFIGS_ALL_DIR}" "${RETROPIE_DIR}"

# --- GPU Permissions Fix ---
# Get the Group ID (GID) of the render device mounted from the host.
RENDER_GID=$(stat -c '%g' /dev/dri/renderD128)
if ! getent group render >/dev/null && ! getent group ${RENDER_GID} >/dev/null; then
    groupadd -g ${RENDER_GID} render
fi
usermod -a -G render pie

# --- Launch Application ---
# Drop privileges and execute the main command as the 'pie' user.
exec sudo -u pie /opt/retropie/supplementary/emulationstation/emulationstation
