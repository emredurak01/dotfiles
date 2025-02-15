#!/bin/bash

set -e  # Exit script on error

# Colors for output
green="\e[32m"
red="\e[31m"
reset="\e[0m"

log() {
    echo -e "${green}[INFO] $1${reset}"
}

error() {
    echo -e "${red}[ERROR] $1${reset}" >&2
    exit 1
}

### UPDATE SYSTEM ###
log "Updating system packages..."
sudo pacman -Syu --noconfirm || error "System update failed"

### INSTALL GIT ###
if ! command -v git &>/dev/null; then
    log "Git not found. Installing..."
    sudo pacman -S --needed --noconfirm git || error "Failed to install Git"
fi

### CLONE CONFIG REPO ###
DOTFILES_REPO="https://github.com/emredurak01/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"

if [ -d "$DOTFILES_DIR" ]; then
    log "Dotfiles already cloned. Pulling latest updates..."
    cd "$DOTFILES_DIR" && git pull && cd -
else
    log "Cloning dotfiles from $DOTFILES_REPO..."
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR" || error "Failed to clone dotfiles"
fi

### INSTALL yay ###
log "Installing yay (AUR helper)..."
if ! command -v yay &>/dev/null; then
    git clone https://aur.archlinux.org/yay.git /tmp/yay && cd /tmp/yay
    makepkg -si --noconfirm || error "Failed to install yay"
    cd - && rm -rf /tmp/yay
fi

### INSTALL OFFICIAL PACKAGES ###
log "Installing packages from official repositories..."
if [ -f "$DOTFILES_DIR/pkglist.txt" ]; then
    xargs -a "$DOTFILES_DIR/pkglist.txt" sudo pacman -S --needed --noconfirm || error "Failed to install official packages"
else
    error "pkglist.txt not found"
fi

### INSTALL AUR PACKAGES ###
log "Installing AUR packages..."
if [ -f "$DOTFILES_DIR/aur-pkglist.txt" ]; then
    xargs -a "$DOTFILES_DIR/aur-pkglist.txt" yay -S --needed --noconfirm || error "Failed to install AUR packages"
else
    error "aur-pkglist.txt not found"
fi

### BACKUP EXISTING CONFIGS ###
log "Backing up existing config files..."
mkdir -p "$HOME/config_backup"
cp -r "$HOME/.config" "$HOME/config_backup/" || log "No existing .config to backup"
cp -r /etc/pacman.conf "$HOME/config_backup/" || log "No existing pacman.conf to backup"
cp -r /etc/ly/config.ini "$HOME/config_backup/" || log "No existing ly config.ini to backup"

### MOVE CONFIG FILES TO HOME ###
log "Applying new configuration files..."
cp -r "$DOTFILES_DIR/.config" "$HOME/"
cp "$DOTFILES_DIR/.zshrc" "$HOME/"
cp "$DOTFILES_DIR/.p10k.zsh" "$HOME/"
cp "$DOTFILES_DIR/.xinitrc" "$HOME/"
cp -r "$DOTFILES_DIR/.oh-my-zsh" "$HOME/"
cp -r "$DOTFILES_DIR/Pictures" "$HOME/"
cp -r "$DOTFILES_DIR/.screenlayout" "$HOME/"

### MOVE SYSTEM CONFIG FILES ###
log "Applying system configuration files..."
sudo cp "$DOTFILES_DIR/etc/pacman.conf" /etc/pacman.conf || error "Failed to copy pacman.conf"
sudo cp "$DOTFILES_DIR/etc/ly/config.ini" /etc/ly/config.ini || error "Failed to copy ly config.ini"

### SET ZSH AS DEFAULT SHELL ###
log "Ensuring /bin/zsh is listed in /etc/shells..."
echo "/bin/zsh" | sudo tee -a /etc/shells >/dev/null

log "Changing default shell to Zsh..."
chsh -s /bin/zsh || error "Failed to set Zsh as default shell"

### ENABLE ESSENTIAL SYSTEM SERVICES ###
log "Enabling system services..."
sudo systemctl enable --now NetworkManager || error "Failed to enable NetworkManager"
sudo systemctl enable --now bluetooth || error "Failed to enable Bluetooth"
sudo systemctl enable --now sshd || error "Failed to enable SSH"

### CLEANUP ###
log "Cleaning up unnecessary dependencies..."
yay -Yc --noconfirm || error "Cleanup failed"

log "Installation complete! Please reboot."
sudo reboot

