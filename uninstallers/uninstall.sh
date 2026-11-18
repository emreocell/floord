
#!/usr/bin/env sh
set -eu

SERVICE_NAME="floor-daemon.service"
SERVICE_FILE="$HOME/.config/systemd/user/$SERVICE_NAME"
CONFIG_PATH="$HOME/.config/floord"
BINARY_PATH="/usr/local/bin/floord"

echo "Uninstalling floord..."

# STOPPING SERVICE
if systemctl --user is-active --quiet "$SERVICE_NAME"; then
    echo "Stopping existing Floord service..."
    systemctl --user stop "$SERVICE_NAME"
    echo "Done."
else
    echo "Service already stopped"
fi

# REMOVING SERVICE FILE
echo "Removing service file..."
rm -f "$SERVICE_FILE"
systemctl --user daemon-reload
echo "Done"

# REMOVING BINARY
echo "Removing binary..."
sudo rm -f "$BINARY_PATH"
echo "Done"

# REMOVING CONFIG FOLDER
echo "Removing configuration folder..."
rm -rf "$CONFIG_PATH"
echo "Done"

echo ""
echo "Floord stopped and uninstalled successfully."
