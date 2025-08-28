#!/bin/bash

# This script runs as root when the container starts.

# Set the ownership of all mounted directories to the 'pie' user.
# This is the crucial step that fixes the permission errors, as the volumes
# are initially mounted with root ownership.
chown -R pie:pie /home/pie/.emulationstation \
                 /opt/retropie/configs \
                 /home/pie/RetroPie

# Now, drop privileges and execute the main command (EmulationStation) as the 'pie' user.
# The 'exec' command replaces this script with the new process, ensuring it's the main container process.
exec sudo -u pie /opt/retropie/supplementary/emulationstation/emulationstation
