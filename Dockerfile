# Use a slim, modern Debian base image for performance
FROM debian:bookworm-slim

# Set environment variables to non-interactive to prevent prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Define a list of dependencies for easy modification.
RUN apt-get update && apt-get install -y --no-install-recommends \
    gnupg \
    sudo \
    # Core build and download tools
    build-essential \
    cmake \
    git \
    wget \
    ca-certificates \
    dialog \
    pkg-config \
    \
    # Audio, video, and controller libraries (SDL2)
    libsdl2-dev \
    libsdl2-mixer-dev \
    libsdl2-image-dev \
    \
    # System and hardware libraries
    libasound2-dev \
    libudev-dev \
    libevdev-dev \
    libdbus-1-dev \
    libbluetooth-dev \
    joystick \
    \
    # Python dependencies
    python3-dev \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Create system groups, create the 'pie' user, and grant passwordless sudo.
RUN groupadd --system input && \
    groupadd --system bluetooth && \
    useradd -m -s /bin/bash pie && \
    usermod -a -G sudo,input,video,audio,dialout,plugdev,tty,bluetooth pie && \
    echo "pie ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/pie-nopasswd

# Switch to the 'pie' user
USER pie
WORKDIR /home/pie

# Clone the RetroPie-Setup script
RUN git clone --depth=1 https://github.com/RetroPie/RetroPie-Setup.git

# Set the working directory for the setup script
WORKDIR /home/pie/RetroPie-Setup

# Install RetroPie core, main packages, AND the EmulationStation frontend
RUN sudo ./retropie_packages.sh setup core && \
    sudo ./retropie_packages.sh setup main && \
    sudo ./retropie_packages.sh emulationstation

# Set the entrypoint to the absolute path of the EmulationStation binary
WORKDIR /home/pie
ENTRYPOINT [ "emulationstation" ]
