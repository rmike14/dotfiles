#!/bin/bash
# =============================================================
#  CachyOS Setup Script
#  Installs: waybar, hyprpaper, blueman, nm-applet,
#            neovim, rofi, hyprlock, hypridle
# =============================================================

set -e # Exit on any error

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

log() { echo -e "${GREEN}[+]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
error() {
  echo -e "${RED}[✗]${NC} $1"
  exit 1
}

# -------------------------------------------------------------
# Check we're on an Arch-based system
# -------------------------------------------------------------
if ! command -v pacman &>/dev/null; then
  error "pacman not found. This script is for Arch-based distros only."
fi

# -------------------------------------------------------------
# Check for AUR helper (yay or paru)
# -------------------------------------------------------------
AUR_HELPER=""
if command -v yay &>/dev/null; then
  AUR_HELPER="yay"
elif command -v paru &>/dev/null; then
  AUR_HELPER="paru"
else
  warn "No AUR helper found. Installing yay..."
  sudo pacman -S --needed --noconfirm git base-devel
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  (cd /tmp/yay && makepkg -si --noconfirm)
  rm -rf /tmp/yay
  AUR_HELPER="yay"
fi
log "Using AUR helper: $AUR_HELPER"

# -------------------------------------------------------------
# Update system first
# -------------------------------------------------------------
log "Updating system..."
sudo pacman -Syu --noconfirm

# -------------------------------------------------------------
# Packages from official repos
# -------------------------------------------------------------
PACMAN_PKGS=(
  waybar                 # Status bar for Hyprland/Wayland
  hyprpaper              # Wallpaper utility for Hyprland
  blueman                # Bluetooth manager GUI
  network-manager-applet # nm-applet (system tray for NetworkManager)
  neovim                 # Vim-based text editor
  rofi                   # Application launcher / window switcher
  hyprlock               # Screen locker for Hyprland
  hypridle               # Idle daemon for Hyprland
  alacritty
  brightnessctl
  fastfetch
  hyprpolkitagent
  pavucontrol
  papirus-icon-theme
  otf-atkinson-hyperlegible
  sddm
  thunar
  ttf-jetbrains-mono
  ttf-jetbrains-mono-nerd
  ufw
  wl-clipboard
  xdg-user-dirs
)

log "Installing packages from official repos..."
sudo pacman -S --needed --noconfirm "${PACMAN_PKGS[@]}"

# -------------------------------------------------------------
# Packages from AUR
# -------------------------------------------------------------
AUR_PKGS=(
  hyprshot
)

if [ ${#AUR_PKGS[@]} -gt 0 ]; then
  log "Installing packages from AUR..."
  $AUR_HELPER -S --needed --noconfirm "${AUR_PKGS[@]}"
else
  warn "No AUR packages specified, skipping."
fi

# -------------------------------------------------------------
# Enable services
# -------------------------------------------------------------
log "Enabling Bluetooth service..."
sudo systemctl enable --now bluetooth.service

log "Ensuring NetworkManager is running..."
sudo systemctl enable --now NetworkManager.service

# -------------------------------------------------------------
# Done
# -------------------------------------------------------------
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Setup complete! Everything installed.  ${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "  Next steps:"
echo "  - Check if the config file is installed correctly "
echo "  - Don't forget to update the sddm theme 'where-is-my-sddm' "
echo ""
