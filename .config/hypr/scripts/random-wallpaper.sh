#!/bin/bash

# Random Wallpaper Script for Hyprland
# Sets a random wallpaper from ~/backgrounds directory using hyprpaper

WALLPAPER_DIR="$HOME/arch-hyprland/backgrounds"

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

# Kill existing hyprpaper instance if running
pkill hyprpaper

# Start hyprpaper with the selected wallpaper
hyprpaper &

# Wait a moment for hyprpaper to start
sleep 0.5

# Configure hyprpaper via hyprctl
hyprctl hyprpaper preload "$RANDOM_WALLPAPER"
hyprctl hyprpaper wallpaper ",$RANDOM_WALLPAPER"

echo "Wallpaper set successfully!"
