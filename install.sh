#!/bin/bash
set -euo pipefail

echo "Hier keyboard auf de stellen: sudo nano /etc/default/keyboard"
echo "Wenn schon getan, 5sek warten, wenn nicht CTRL+C..."
sleep 5

if [ "$EUID" -eq 0 ]; then
  echo "FEHLER: Bitte starte dieses Skript NICHT mit sudo oder als root."
  exit 1
fi

if ! command -v paru >/dev/null; then
  echo "FEHLER: paru fehlt. Bitte paru installieren und Script erneut starten."
  echo "Hinweis: https://github.com/Morganamilo/paru"
  exit 1
fi

sudo -v

# sudo refresh
while true; do
  sudo -n true || exit
  sleep 60
  kill -0 "$$" || exit
done 2>/dev/null &

sudo pacman -Syu --noconfirm
sudo pacman -S --needed --noconfirm stow

# dotfiles
STOW_PACKAGES=(hypr waybar nvim kanshi)
DOTFILES_DIR="$HOME/dotfiles"
if [ ! -d "$DOTFILES_DIR" ]; then
  echo "FEHLER: $DOTFILES_DIR nicht gefunden. Repo muss nach ~/dotfiles geklont sein."
  exit 1
fi

BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

for d in .config/hypr .config/waybar .config/nvim .config/kanshi; do
  if [ -e "$HOME/$d" ] && [ ! -L "$HOME/$d" ]; then
    mkdir -p "$BACKUP_DIR/$(dirname "$d")"
    mv "$HOME/$d" "$BACKUP_DIR/$d"
  fi
done

cd "$DOTFILES_DIR"
stow -v "${STOW_PACKAGES[@]}"


# packages
PACKAGES=(
  "swaync"
  "fuzzel"
  "hyprpaper"
  "chromium"
  "neovim"
  "kanshi"
  "opencode"
  "go"
  "docker"
  "docker-compose"
  "thunderbird"
  "vesktop"
  "onlyoffice-bin"
  "gnome-keyring"
  "libsecret"
  "uv"
  "hyprlock"
  "p7zip"
  "waybar"
)

sudo pacman -S --needed --noconfirm "${PACKAGES[@]}"

# aur packages
paru -S bzmenu --noconfirm --needed
paru -S visual-studio-code-bin --noconfirm --needed

# node/npm
curl -fsSL https://fnm.vercel.app/install | bash

# docker settings
sudo usermod -aG docker "$USER"
sudo systemctl enable --now docker.service

xdg-settings set default-web-browser firefox.desktop

systemctl --user enable --now ssh-agent.service 2>/dev/null || true
systemctl --user enable --now ssh-agent.socket 2>/dev/null || true

echo "Du solltest vlt. deine Github creds setzen"
echo "git config --global user.email \"hanjo@prieur.de\""
echo "git config --global user.name \"Hanjo Prieur\""
echo "_________"
echo "außerdem noch 'fnm install --lts' runnen, um node/npm zu installieren, vielleicht dazu shell neustarten"
echo "_________"
echo "einmal rebooten"
