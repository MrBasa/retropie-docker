# retropie-docker
Project for creating a Retro Pie container.

## 1. Host Setup (Required First Step)

This project uses host-bind mounts to manage your data. Before launching the container, you must create the required directories on your Raspberry Pi.

Run the following commands from your terminal:

```bash
# Create all necessary directories
mkdir -p ~/RetroPie/configs
mkdir -p ~/RetroPie/roms
mkdir -p ~/RetroPie/BIOS
mkdir -p ~/RetroPie/saves
mkdir -p ~/RetroPie/states

# Set correct ownership for the rootless container
# This assumes your user is 'pie' with UID 1000
sudo chown -R 1000:1000 /opt/retropie/configs
