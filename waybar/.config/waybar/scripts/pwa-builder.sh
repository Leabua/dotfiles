#!/bin/bash

clear
echo "========================================"
echo "         Helium PWA Generator           "
echo "========================================"
echo ""

# Ensure the local icon directory exists
icon_dir="$HOME/.local/share/icons/pwa-icons"
mkdir -p "$icon_dir"
read -r -p "1. Enter App Name (e.g., WhatsApp): " app_name
read -r -p "2. Enter Web URL (e.g., https://web.whatsapp.com): " app_url
read -r -p "3. Enter Image URL for Icon: " icon_url

# Create a safe filename (lowercase, no spaces)
safe_name=$(echo "$app_name" | tr '[:upper:]' '[:lower:]' | tr -d ' ')
icon_path="$icon_dir/${safe_name}.png"
file_path="$HOME/.local/share/applications/pwa-${safe_name}.desktop"

# Download the icon
echo "Downloading icon..."
curl -L -s -o "$icon_path" "$icon_url"

# Generate the .desktop file
cat <<EOF >"$file_path"
[Desktop Entry]
Name=$app_name
Exec=chromium --app="$app_url"
Icon=$icon_path
Type=Application
Terminal=false
Categories=Network;WebBrowser;
StartupWMClass=chromium

EOF
echo ""
echo "========================================"
echo "Success! $app_name has been created."
echo "Icon saved to: $icon_path"
echo "It is now available in your Rofi launcher."
echo "Press ANY KEY to exit."
read -r -n 1 -s
