#!/bin/bash

# Random Wallpaper Script for Hyprland
# Sets a random wallpaper from ~/backgrounds directory using hyprpaper

WALLPAPER_DIR="$HOME/backgrounds"

# Resolve symlink if it is one
if [ -L "$WALLPAPER_DIR" ]; then
    WALLPAPER_DIR=$(readlink -f "$WALLPAPER_DIR")
fi

# Check if wallpaper directory exists
if [ ! -d "$WALLPAPER_DIR" ]; then
    echo "Error: Wallpaper directory $WALLPAPER_DIR does not exist"
    exit 1
fi

# Get all image files from the directory
mapfile -t WALLPAPERS < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \))

# Check if any wallpapers were found
if [ ${#WALLPAPERS[@]} -eq 0 ]; then
    echo "Error: No image files found in $WALLPAPER_DIR"
    exit 1
fi

# Select a random wallpaper
RANDOM_WALLPAPER="${WALLPAPERS[RANDOM % ${#WALLPAPERS[@]}]}"

echo "Setting wallpaper: $RANDOM_WALLPAPER"

# Check if hyprpaper is running
if ! pgrep -x hyprpaper > /dev/null; then
    # Start hyprpaper and use preload + wallpaper
    hyprpaper &
    sleep 0.5
    hyprctl hyprpaper preload "$RANDOM_WALLPAPER"
    hyprctl hyprpaper wallpaper ",$RANDOM_WALLPAPER"
else
    # hyprpaper is already running, use reload for smooth transition
    hyprctl hyprpaper reload ",$RANDOM_WALLPAPER"
fi

echo "Wallpaper set successfully!"