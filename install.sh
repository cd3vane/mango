#!/bin/bash
set -e

echo "Mango Agent Gateway Installer"
echo "=============================="
echo ""

if [[ "$OSTYPE" != "linux-gnu"* ]]; then
	echo "Error: This script is for Linux only"
	exit 1
fi

if ! command -v sudo &> /dev/null; then
	echo "Error: sudo is required"
	exit 1
fi

echo "This script will:"
echo "  1. Build the mango binary"
echo "  2. Install it to /usr/local/bin/mango"
echo "  3. Create a 'mango' system user"
echo "  4. Install systemd service file"
echo "  5. Copy config to /etc/mango/config.yaml"
echo ""
echo "You will be prompted for your sudo password."
echo ""
read -p "Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
	echo "Aborted."
	exit 1
fi

# Build binary
echo "Building mango..."
go build -o mango ./cmd/app
if [ ! -f mango ]; then
	echo "Error: Failed to build mango"
	exit 1
fi

# Install binary
echo "Installing binary to /usr/local/bin/mango..."
sudo mv mango /usr/local/bin/mango
sudo chmod +x /usr/local/bin/mango

# Create system user
echo "Creating 'mango' system user..."
if ! id -u mango &> /dev/null; then
	sudo useradd --system --no-create-home --shell /usr/sbin/nologin mango
	echo "  Created user: mango"
else
	echo "  User 'mango' already exists"
fi

# Install service file
echo "Installing systemd service file..."
sudo cp deploy/mango.service /etc/systemd/system/mango.service
sudo systemctl daemon-reload

# Create config directory and copy config
echo "Setting up configuration..."
sudo mkdir -p /etc/mango
if [ -f config.yaml ]; then
	sudo cp config.yaml /etc/mango/config.yaml
	echo "  Copied config.yaml to /etc/mango/"
else
	echo "  Warning: No config.yaml found in current directory"
	echo "  Create /etc/mango/config.yaml manually before starting the service"
fi

# Set ownership
sudo chown -R mango:mango /etc/mango
sudo chown mango:mango /usr/local/bin/mango

echo ""
echo "Installation complete!"
echo ""
echo "Next steps:"
echo "  1. Review /etc/mango/config.yaml and update as needed"
echo "  2. Enable the service: sudo systemctl enable mango"
echo "  3. Start the service: sudo systemctl start mango"
echo "  4. Check status: sudo systemctl status mango"
echo "  5. View logs: journalctl -u mango -f"
echo ""
echo "Once running, you can use the CLI normally:"
echo "  mango status"
echo "  mango agent list"
echo "  mango task submit 'Say hello' --wait"
