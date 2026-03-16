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
STOW_PACKAGES=(hypr waybar nvim kanshi electron yazi)
DOTFILES_DIR="$HOME/dotfiles"
if [ ! -d "$DOTFILES_DIR" ]; then
  echo "FEHLER: $DOTFILES_DIR nicht gefunden. Repo muss nach ~/dotfiles geklont sein."
  exit 1
fi

cd "$DOTFILES_DIR"
stow -v "${STOW_PACKAGES[@]}"

sudo pacman -Rs dolphin
rm -rf ~/.local/share/dolphin
rm -rf ~/.config/dolphinrc

# packages
PACKAGES=(
  "zathura"
  "zathura-pdf-poppler"
  "yazi"
  "libva-utils"
  "swaync"
  "fuzzel"
  "hyprpaper"
  "hyprshot"
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
paru -S ripdrag --noconfirm --needed

# node/npm
curl -fsSL https://fnm.vercel.app/install | bash

# docker settings
sudo usermod -aG docker "$USER"
sudo systemctl enable --now docker.service

xdg-settings set default-web-browser firefox.desktop

xdg-mime default org.pwmt.zathura.desktop application/pdf

systemctl --user enable --now ssh-agent.service 2>/dev/null || true
systemctl --user enable --now ssh-agent.socket 2>/dev/null || true

echo "Du solltest vlt. deine Github creds setzen"
echo "git config --global user.email \"hanjo@prieur.de\""
echo "git config --global user.name \"Hanjo Prieur\""
echo "_________"
echo "außerdem noch 'fnm install --lts' runnen, um node/npm zu installieren, vielleicht dazu shell neustarten"
echo "_________"
echo "einmal rebooten"
