#!/bin/bash

echo "Entrypoint starting..."

# Start a D-Bus session for controller support
#eval "$(dbus-launch --sh-syntax)"

# --- Bootstrap Logic ---
# Check if /opt/retropie/configs is empty and copy defaults if it is.
if [ -z "$(ls -A /opt/retropie/configs)" ]; then
   echo "INFO: /opt/retropie/configs is empty. Bootstrapping default configs..."
   cp -a /opt/retropie/configs.bak/. /opt/retropie/configs/
   echo "I wuz here" > /opt/retropie/configs/hi.txt
   # sudo $RETROPIE_SETUP/retropie_packages.sh emulationstation clear_input
fi

echo "Starting EmulationStation..."
echo "Running as $(whoami)"
# Use tini to handle signals and prevent zombie processes
#exec /usr/bin/tini -g -- emulationstation
emulationstation
