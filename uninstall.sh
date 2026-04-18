#!/bin/bash
set -e

echo "Mango Agent Gateway Uninstaller"
echo "================================"
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
echo "  1. Stop and disable the systemd service"
echo "  2. Remove the service file"
echo "  3. Remove the binary from /usr/local/bin/mango"
echo "  4. Remove the system user 'mango'"
echo "  5. Remove configuration from /etc/mango/"
echo ""
echo "Note: User data/logs may remain. Delete /var/lib/mango manually if needed."
echo ""
read -p "Continue with uninstall? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
	echo "Aborted."
	exit 1
fi

read -p "Are you sure? This cannot be undone. (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
	echo "Aborted."
	exit 1
fi

# Stop the service
echo "Stopping mango service..."
if systemctl is-active --quiet mango 2>/dev/null; then
	sudo systemctl stop mango
	echo "  Stopped"
else
	echo "  Service not running"
fi

# Disable the service
echo "Disabling mango service..."
if systemctl is-enabled --quiet mango 2>/dev/null; then
	sudo systemctl disable mango
	echo "  Disabled"
else
	echo "  Service not enabled"
fi

# Remove service file
echo "Removing systemd service file..."
if [ -f /etc/systemd/system/mango.service ]; then
	sudo rm /etc/systemd/system/mango.service
	sudo systemctl daemon-reload
	echo "  Removed"
else
	echo "  Service file not found"
fi

# Remove binary
echo "Removing binary..."
if [ -f /usr/local/bin/mango ]; then
	sudo rm /usr/local/bin/mango
	echo "  Removed /usr/local/bin/mango"
else
	echo "  Binary not found"
fi

# Remove config
echo "Removing configuration..."
if [ -d /etc/mango ]; then
	sudo rm -rf /etc/mango
	echo "  Removed /etc/mango"
else
	echo "  Config directory not found"
fi

# Remove user
echo "Removing system user..."
if id -u mango &> /dev/null; then
	sudo userdel mango
	echo "  Removed user: mango"
else
	echo "  User 'mango' not found"
fi

echo ""
echo "Uninstall complete!"
echo ""
echo "Optional cleanup:"
echo "  rm -rf /var/lib/mango        # user data"
echo "  rm -rf /var/log/mango.log    # logs"
