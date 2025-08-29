# Use a slim, modern Debian base image for performance
FROM debian:bookworm-slim

# --- Add an argument for the Render GID ---
ARG RENDER_GID

# Set environment variables to non-interactive to prevent prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Install all necessary dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gnupg sudo build-essential cmake git wget ca-certificates dialog \
    pkg-config libsdl2-dev libsdl2-mixer-dev libsdl2-image-dev \
    libasound2-dev libudev-dev libevdev-dev libdbus-1-dev \
    libbluetooth-dev joystick python3-dev python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Create the 'pie' user and grant necessary permissions
# --- FIX IS HERE: Create a 'render' group with the correct GID ---
RUN groupadd --system input && \
    groupadd --system bluetooth && \
    groupadd -g ${RENDER_GID} render && \
    useradd -m -s /bin/bash pie && \
    usermod -a -G sudo,input,video,audio,dialout,plugdev,tty,bluetooth,render pie && \
    echo "pie ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/pie-nopasswd

# Switch to the 'pie' user for the main setup
USER pie
WORKDIR /home/pie

# Clone and run the RetroPie setup script
RUN git clone --depth=1 https://github.com/RetroPie/RetroPie-Setup.git
WORKDIR /home/pie/RetroPie-Setup
RUN sudo ./retropie_packages.sh setup core && \
    sudo ./retropie_packages.sh setup main && \
    sudo ./retropie_packages.sh emulationstation

# Switch back to root to rearrange files for a clean volume mount strategy
USER root

# Create a single, top-level directory that will be our only mount point for persistent data.
RUN mkdir /data

# Move the data generated during the build into subdirectories inside /data.
RUN mv /home/pie/.emulationstation /data/configs && \
    mv /opt/retropie/configs /data/configs-all && \
    mv /home/pie/RetroPie /data/RetroPie

# Remove the original directories and replace them with symbolic links.
RUN rm -rf /home/pie/.emulationstation /opt/retropie/configs /home/pie/RetroPie && \
    ln -s /data/configs /home/pie/.emulationstation && \
    ln -s /data/configs-all /opt/retropie/configs && \
    ln -s /data/RetroPie /home/pie/RetroPie

# Set the final user and entrypoint
USER pie
WORKDIR /home/pie
ENTRYPOINT [ "/opt/retropie/supplementary/emulationstation/emulationstation" ]
