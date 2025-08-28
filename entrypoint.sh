#!/bin/bash

# Define the path for the persistent configuration directory.
CONFIG_DIR="/opt/retropie/configs"

# Check if the 'all' subdirectory (a key part of the default config) is missing.
# This indicates that this is the first time the container is running with an empty volume.
if [ ! -d "${CONFIG_DIR}/all" ]; then
  echo "First run detected: Populating default configurations..."
  # Copy the default configs from the backup location into the empty volume.
  cp -a /opt/retropie/configs.bak/. "${CONFIG_DIR}"
fi

# Now that the configs are guaranteed to be in place, execute EmulationStation.
# The 'exec' command replaces this script with the emulationstation process.
exec /opt/retropie/supplementary/emulationstation/emulationstation
