#!/bin/bash
# v0.0.3

# This script runs as root to prepare the container environment at runtime.

# --- GPU Permissions Fix ---
# Get the Group ID (GID) of the render device mounted from the host.
# This is the most reliable way to get the correct GID.
RENDER_GID=$(stat -c '%g' /dev/dri/renderD128)

# Create a 'render' group inside the container with the same GID.
# This check prevents errors if the group already exists.
if ! getent group render >/dev/null && ! getent group ${RENDER_GID} >/dev/null; then
    groupadd -g ${RENDER_GID} render
fi

# Add the 'pie' user to the newly created render group.
# This grants the user permission to access the GPU.
usermod -a -G render pie

# --- Data Volume Permissions Fix ---
# Set the ownership of the data volume to the 'pie' user.
chown -R pie:pie /data

# --- Launch Application ---
# Drop privileges and execute the main command as the 'pie' user.
# 'exec' replaces this script with the emulationstation process.
exec sudo -u pie /opt/retropie/supplementary/emulationstation/emulationstation
