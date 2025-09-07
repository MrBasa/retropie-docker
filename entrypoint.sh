#!/bin/bash

echo "Entrypoint starting..."

# Define the path to the main RetroArch config file
RETROARCH_CONFIG="/opt/retropie/configs/all/retroarch.cfg"

# --- Bootstrap Logic ---
# Check if /opt/retropie/configs is empty and copy defaults if it is.
if [ -z "$(ls -A /opt/retropie/configs)" ]; then
   echo "INFO: /opt/retropie/configs is empty. Bootstrapping default configs..."
   cp -a /opt/retropie/configs.bak/. /opt/retropie/configs/
   echo "Bootstrapped on $(date)" > /opt/retropie/configs/bootstrap.log
fi

# --- NEW: Custom Save/State Directory Logic ---
# This block checks for the existence of the variables from the .env file and
# updates the main retroarch.cfg to point to the correct directories inside the container.
if [ -f "$RETROARCH_CONFIG" ]; then
    echo "INFO: Checking for custom save and state directories..."

    # Define the internal paths based on the docker-compose volume mounts.
    INTERNAL_SAVES_DIR="/home/${UNAME}/RetroPie/saves"
    INTERNAL_STATES_DIR="/home/${UNAME}/RetroPie/states"

    # Check if SAVES_DIR env var is set from the host.
    if [ -n "${SAVES_DIR}" ]; then
        echo "INFO: SAVES_DIR is set. Updating retroarch.cfg..."
        # Use sed to find and replace the savefile_directory line.
        # This works even if the line is commented out.
        sed -i "s~^#\?savefile_directory =.*~savefile_directory = \"${INTERNAL_SAVES_DIR}\"~" "$RETROARCH_CONFIG"
        echo "      -> Save file directory set to: ${INTERNAL_SAVES_DIR}"
    fi

    # Check if STATES_DIR env var is set from the host.
    if [ -n "${STATES_DIR}" ]; then
        echo "INFO: STATES_DIR is set. Updating retroarch.cfg..."
        # Use sed to find and replace the savestate_directory line.
        sed -i "s~^#\?savestate_directory =.*~savestate_directory = \"${INTERNAL_STATES_DIR}\"~" "$RETROARCH_CONFIG"
        echo "      -> Save state directory set to: ${INTERNAL_STATES_DIR}"
    fi
else
    echo "WARNING: $RETROARCH_CONFIG not found. Cannot apply custom save/state paths."
fi
# --- End of New Logic ---

echo "Starting EmulationStation..."
echo "Running as $(whoami)"
# Use tini to handle signals and prevent zombie processes
exec /usr/bin/tini -g -- emulationstation
