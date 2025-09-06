# RetroPie Docker

A containerized setup for [RetroPie](https://retropie.org.uk/) that allows you to run the retro gaming platform in an isolated environment using Docker or Podman. This project is designed to be easy to set up and manage, with persistent storage for all your configurations, ROMs, and save files.

**This is still a work-in-progress. I have yet to test controller configuration and Bluetooth, but everything appears to be working.**
**Auto configuration of the saves and states directories is not implemented yet**

## Features

* **Isolated Environment:** Runs RetroPie in its own container, keeping your host system clean.
* **Persistent Data:** Uses volume mounts to store all your important data (configs, ROMs, BIOS, saves) on the host machine.
* **Non-Root User:** The container runs as a non-root user for improved security.
* **Easy Configuration:** All settings are managed through a simple `.env` file.
* **Automated Setup:** An entrypoint script automatically sets up default configurations on the first run.
* **Hardware Access:** Provides direct access to display, sound, and USB devices for controllers.

## Prerequisites

* A host machine with a graphical environment (e.g., a desktop Linux distribution).
* [Docker](https://www.docker.com/) or [Podman](https://podman.io/).
* If using Podman, you will need `podman-compose`.

## Getting Started

Follow these steps to get your containerized RetroPie instance up and running.

### 1. Clone the Repository

```bash
git clone [https://github.com/mrbasa/retropie-docker.git](https://github.com/mrbasa/retropie-docker.git)
cd retropie-docker
```

### 2. Create Host Directories

This project uses bind mounts to store your data on the host system. You must create these directories before launching the container for the first time.

```bash
# These commands create the directories in the project folder.
# You can change these paths, but be sure to update your .env file accordingly.
mkdir -p ./configs
mkdir -p ./roms
mkdir -p ./bios
mkdir -p ./saves
mkdir -p ./states
```

### 3. Configure Your Environment

Customize the example `.env` file to match your system's configuration.

See the **Configuration** section below for a detailed explanation of each variable in the `.env` file. The most important values to check are `PUID` and `PGID`, which should match your user's ID. You can find them by running the `id` command in your terminal.

### 4. Build and Run

A helper script, `rebuild.sh`, is included to handle the entire process of cleaning up old instances, building the image, and starting the container.

```bash
chmod +x rebuild.sh
./rebuild.sh
```

This script will build the container image and launch it in detached mode. You can view the logs using `podman logs -f retropie`. EmulationStation should start automatically.

## Configuration (.env file)

All user-configurable settings are located in the `.env` file.

| Variable         | Description                                                                                                                             | Default           |
| :--------------- | :-------------------------------------------------------------------------------------------------------------------------------------- | :---------------- |
| `CONTAINER_NAME` | The name assigned to the running container.                                                                                             | `retropie`        |
| `IMAGE_NAME`     | The name assigned to the built container image.                                                                                         | `retropie`        |
| `PUID`           | **(Important)** The user ID that the container will run as. Should match the owner of the volume directories. Find yours with `id -u`.  | `1000`            |
| `PGID`           | **(Important)** The group ID that the container will run as. Should match the owner of the volume directories. Find yours with `id -g`. | `1000`            |
| `UNAME`          | The username for the non-root user inside the container.                                                                                | `pieguy`          |
| `TZ`             | Your local timezone (e.g., `America/New_York`, `Europe/London`).                                                                        | `America/Chicago` |
| `CONFIG_DIR`     | The path on the host for RetroPie's configurations.                                                                                     | `./configs`       |
| `ROMS_DIR`       | The path on the host for your game ROMs.                                                                                                | `./roms`          |
| `BIOS_DIR`       | The path on the host for emulator BIOS files.                                                                                           | `./bios`          |
| `SAVES_DIR`      | The path on the host for in-game save files.                                                                                            | `./saves`         |
| `STATES_DIR`     | The path on the host for emulator save states.                                                                                          | `./states`        |

## Data Persistence (Volume Mappings)

The container is designed to be stateless. All your important data is stored on the host machine via volume mappings defined in `docker-compose.yml`. This ensures that your data persists even if the container is removed or rebuilt.

| Host Path (from `.env`) | Container Path                   | Purpose                                                                                                                               |
| :---------------------- | :------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------ |
| `${CONFIG_DIR}`         | `/opt/retropie/configs`          | Stores all core RetroPie settings, emulator configurations, and controller mappings.                                                  |
| `${ROMS_DIR}`           | `/home/${UNAME}/RetroPie/roms`   | Place your game ROM files here, organized into subdirectories by console (e.g., `./roms/snes`, `./roms/nes`).                         |
| `${BIOS_DIR}`           | `/home/${UNAME}/RetroPie/BIOS`   | Required for some emulators. Place necessary BIOS files in this directory.                                                            |
| `${SAVES_DIR}`          | `/home/pie/RetroPie/saves`       | When you save your progress in a game, the save file is stored here.                                                                  |
| `${STATES_DIR}`         | `/home/pie/RetroPie/states`      | When you use an emulator's "save state" feature, the state file is stored here.                                                       |

## How It Works

### Dockerfile

The `Dockerfile` uses a multi-stage build to create a clean and efficient final image.
* **Stage 1 (builder):** Installs all the build-time dependencies and runs the RetroPie setup script to compile and install the core components.
* **Stage 2 (final):** Starts from a slim Debian base image, installs only the necessary runtime dependencies, and copies the compiled RetroPie application files from the builder stage. This results in a smaller and more secure final image.

### Entrypoint Script

The `entrypoint.sh` script runs every time the container starts.
1.  It first checks if the mapped configuration directory (`/opt/retropie/configs`) is empty.
2.  If it is empty (which happens on the very first run), the script copies a set of default configurations into the directory.
3.  This "bootstrapping" process ensures that EmulationStation has the necessary files to start up correctly the first time.
4.  Finally, it launches EmulationStation.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
