#!/bin/bash

WALLPAPER_DIR="$HOME/.config/hypr/wallpapers"

shopt -s nullglob
files=("$WALLPAPER_DIR"/*)

if [ ${#files[@]} -eq 0 ]; then
    echo "Keine Dateien gefunden."
    exit 1
fi

STORE_FILE="$HOME/.lastwp"

if [ -f "$STORE_FILE" ]; then
    VALUE=$(cat "$STORE_FILE")
else
    VALUE=0
fi

echo "Aktueller Wert: $VALUE"

if [ ${#files[@]} -gt 0 ] && [ "$VALUE" -lt "${#files[@]}" ]; then
    image_path="${files[$VALUE]}"
    echo "Gewählte Datei: $image_path"
else
    echo "Fehler: Index ungültig oder Verzeichnis leer."
fi

length=${#files[@]}

VALUE=$(( (VALUE + 1) % length ))

echo "$VALUE" > "$STORE_FILE"

hyprctl hyprpaper wallpaper "desc:Dell Inc. DELL U2518D 3C4YP92CBUDL,$image_path,contain"
hyprctl hyprpaper wallpaper "eDP-1,$image_path,contain"

