#!/usr/bin/env bash
# =============================================================================
# Script: install.sh
# Description: Full automated installer for kbyte75's ARCH-Hyprland Config
# Repo: https://github.com/kbyte75/my-arch-config
# Author: KBYTE75
# Version: 1.0.0
# Date: 2025-11-27
# =============================================================================

set -euo pipefail
IFS=$'\n\t'

readonly REPO="https://github.com/kbyte75/my-arch-config.git"
readonly REPO_DIR="$HOME/arch-config"
readonly CONFIG_HOME="${HOME}/.config"
readonly GREEN='\033[0;32m' YELLOW='\033[1;33m' RED='\033[0;31m' NC='\033[0m'

log()   { echo -e "${GREEN}[INFO]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; } >&2

# die() { error "$*"; exit 1; }

check_os() {
  if !command -v pacman >/dev/null 2>&1; then
    error "This script only works on Arch-Linux" 
    exit 1
  fi
}

main() {
  check_os
  log "Hyprland Config Installer.."

  # 1. Clone repo
  log "Cloning repository..."
  rm -rf "$REPO_DIR"
  git clone "$REPO" "$REPO_DIR" || error "Failed to clone repo"

  # 2. Install dependencies
  log "Installing required dependecies..."
  sudo pacman -Syu --noconfirm --needed make cmake rsync base-devel git nano python-pyquery nwg-look font-manager blueman nm-connection-editor
 
  # 2. Install Packages
  log "Installing main packages..."
  sudo pacman -Syu --noconfirm --needed waybar swww rofi hyprlock hypridle hyprshot matugen fish fastfetch sddm kitty nautilus

  # 3. Install yay (if not exist)
  if ! command -v yay >/dev/null; then
    log "Installing yay..."
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    (cd /tmp/yay && makepkg -si --noconfirm)
  fi

  # 4. Install AUR packages
  log "Installing oh-my-posh & hypremoji..."
  yay -S --noconfirm oh-my-posh hypremoji

  # 5. Create folders
  log "Creating required folders..."
  mkdir -p ~/Pictures/{Screenshots,Wallpapers}

  # 6. Copy config files
  log "Copying configs to ~/.config..."
  rsync -a "$REPO_DIR"/config/* "$CONFIG_HOME"/

  # 7. Copy nanorc & SDDM theme
  log "Installing nanorc & SDDM theme..."
  sudo cp "$REPO_DIR/nanorc" /etc/nanorc
  sudo mkdir -p /usr/share/sddm/themes
  sudo cp -r "$REPO_DIR/sddm-theme" /usr/share/sddm/themes/

  # 8. Make scripts executable
  log "Setting executable permissions..."
  sudo chmod +x ~/.config/hypr/scripts/*.sh 2>/dev/null || true
  sudo chmod +x ~/.config/waybar/scripts/*.sh 2>/dev/null || true
  sudo chmod +x ~/.config/rofi/scripts/*.sh 2>/dev/null || true
  sudo chmod +x ~/.config/waybar/scripts/weather.py 2>/dev/null || true

  # 9. Change shell to fish
  log "Changing default shell to fish..."
  sudo chsh -s /usr/bin/fish "$USER"

  # 10. Final instructions
  log "Installation complete!"
  echo
  echo "Next steps:"
  echo "1. Reboot"
  echo "2. Log in with SDDM"
  echo "3. Run 'nwg-look' to set cursor (Bibata Modern Ice), icons (MacTahoe), and fonts"
  echo "4. Download and install these manually:"
  echo "   • Bibata Modern Ice: https://www.gnome-look.org/p/1197198"
  echo "   • MacTahoe Icons: https://www.gnome-look.org/p/2299216"
  echo "   • Rubik, Poppins, A Black Lives, Voice In My Head, FiraCode Nerd Font"
  echo
  echo "Enjoy your new Hyprland rice!"
}

main