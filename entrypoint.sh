#!/bin/bash

echo "Entrypoint starting..."

# Start a D-Bus session for controller support
#eval "$(dbus-launch --sh-syntax)"

# --- Bootstrap Logic ---
# Check if /opt/retropie/configs is empty and copy defaults if it is.
if [ -z "$(ls -A /opt/retropie/configs)" ]; then
   echo "INFO: /opt/retropie/configs is empty. Bootstrapping default configs..."
   echo "I wuz there" > /opt/retropie/configs/hi.txt
   cp -a /opt/retropie/configs.bak/. /opt/retropie/configs/
   # sudo $RETROPIE_SETUP/retropie_packages.sh emulationstation clear_input
fi

# Check if ~/.emulationstation is empty and copy defaults if it is.
#if [ -z "$(ls -A /home/pie/.emulationstation)" ]; then
#   echo "INFO: /home/pie/.emulationstation is empty. Bootstrapping default ES configs..."
#   cp /opt/retropie/configs/all/emulationstation/es_systems.cfg /home/pie/.emulationstation/
#fi

echo "Starting EmulationStation..."
echo "Running as $(whoami)"
# Use tini to handle signals and prevent zombie processes
#exec /usr/bin/tini -g -- emulationstation
emulationstation
