#!/bin/bash

echo "Entrypoint starting..."

# Start a D-Bus session for controller support
eval "$(dbus-launch --sh-syntax)"

# --- Bootstrap Logic ---
# Check if /opt/retropie/configs is empty and copy defaults if it is.
if [ -z "$(ls -A /opt/retropie/configs)" ]; then
   echo "INFO: /opt/retropie/configs is empty. Bootstrapping default configs..."
   cp -a /opt/retropie/configs.bak/. /opt/retropie/configs/
fi

# Check if ~/.emulationstation is empty and copy defaults if it is.
if [ -z "$(ls -A /home/pie/.emulationstation)" ]; then
   echo "INFO: /home/pie/.emulationstation is empty. Bootstrapping default ES configs..."
   # EmulationStation often pulls configs from the main configs dir,
   # but we can pre-create key files or copy a template if needed.
   # For now, ensuring the directory exists is the main goal.
   # If specific files are needed, they would be copied here.
   : # This is a placeholder, as ES usually self-populates.
fi

# Ensure the core RetroPie subdirectories exist inside the container volume
mkdir -p /home/pie/RetroPie/roms
mkdir -p /home/pie/RetroPie/BIOS
mkdir -p /home/pie/RetroPie/saves
mkdir -p /home/pie/RetroPie/states

echo "Starting EmulationStation..."
# Use tini to handle signals and prevent zombie processes
exec /usr/bin/tini -g -- emulationstation
