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
}

### UPDATE SYSTEM ###
log "Updating system packages..."
sudo pacman -Syu --noconfirm || error "System update failed"

### REMOVE CONFLICTING PACKAGES ###
log "Checking for conflicting packages..."
if pacman -Qi i3lock &>/dev/null; then
    log "Removing conflicting package: i3lock"
    sudo pacman -Rns --noconfirm i3lock || error "Failed to remove i3lock"
fi

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
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    sudo -u "$USER" makepkg -si --noconfirm || error "Failed to install yay"
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
cp -r /etc/X11/xorg.conf.d/30-touchpad.conf "$HOME/config_backup/" || log "No existing 30-touchpad.conf to backup"

### MOVE CONFIG FILES TO HOME ###
log "Applying new configuration files..."
cp -r "$DOTFILES_DIR/.config" "$HOME/"
cp -r "$DOTFILES_DIR/Pictures" "$HOME/"
cp -r "$DOTFILES_DIR/.screenlayout" "$HOME/"

### INSTALL NVIM ###
log "Installing Nvim..."
if [ ! -d "$HOME/.config/nvim" ]; then
    git clone https://github.com/NvChad/NvChad "$HOME/.config/nvim" --depth 1
else
    log "NVChad already installed, skipping..."
fi

log "Waiting for NVChad to initialize..."
sleep 5

log "Installing Mason LSPs..."
nvim --headless "+Lazy sync" "+MasonInstall bash-language-server clangd css-lsp html-lsp jdtls lua-language-server pyright typescript-language-server" +qall

### CHECK & LOAD BLUETOOTH MODULE ###
log "Checking Bluetooth module..."
if ! lsmod | grep -q "btusb"; then
    log "btusb module not loaded. Loading it now..."
    sudo modprobe btusb || error "Failed to load btusb module"
else
    log "btusb module already loaded."
fi

### ENABLE BLUETOOTH SERVICE ###
log "Enabling Bluetooth service..."
sudo systemctl enable --now bluetooth || log "Failed to enable Bluetooth, moving on..."

### INSTALL OH MY ZSH ###
log "Installing Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    rm -rf "$HOME/.oh-my-zsh"
    curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh || error "Failed to install Oh My Zsh"
else
    log "Oh My Zsh already installed, skipping..."
fi

### INSTALL OH MY ZSH PLUGINS ###
log "Installing Zsh plugins..."
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom/plugins"

declare -A plugins=(
    ["zsh-syntax-highlighting"]="https://github.com/zsh-users/zsh-syntax-highlighting.git"
    ["zsh-autosuggestions"]="https://github.com/zsh-users/zsh-autosuggestions.git"
    ["fzf-tab"]="https://github.com/Aloxaf/fzf-tab.git"
    ["zsh-autopair"]="https://github.com/hlissner/zsh-autopair.git"
)

for plugin in "${!plugins[@]}"; do
    if [ ! -d "$ZSH_CUSTOM/$plugin" ]; then
        git clone "${plugins[$plugin]}" "$ZSH_CUSTOM/$plugin"
    else
        log "$plugin already installed, skipping..."
    fi
done

### INSTALL POWERLEVEL10K ###
log "Installing Powerlevel10k..."
P10K_THEME="$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
if [ ! -d "$P10K_THEME" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_THEME"
else
    log "Powerlevel10k already installed, skipping..."
fi

### APPLY ZSH CONFIGURATION ###
log "Applying Zsh configuration..."
cp "$DOTFILES_DIR/.zshrc" "$HOME/"
cp "$DOTFILES_DIR/.p10k.zsh" "$HOME/"

### MOVE SYSTEM CONFIG FILES ###
log "Applying system configuration files..."
sudo cp "$DOTFILES_DIR/etc/pacman.conf" /etc/pacman.conf || error "Failed to copy pacman.conf"
sudo cp "$DOTFILES_DIR/etc/ly/config.ini" /etc/ly/config.ini || error "Failed to copy ly config.ini"
sudo cp "$DOTFILES_DIR/etc/X11/xorg.conf.d/30-touchpad.conf" /etc/X11/xorg.conf.d/ || error "Failed to copy 30-touchpad.conf"
sudo cp "$DOTFILES_DIR/etc/modprobe.d/nobeep.conf" /etc/modprobe.d/nobeep.conf || error "Failed to copy nobeep.conf"

### REPLACE LY SERVICE ###
log "Replacing ly.service with the one from dotfiles..."
sudo cp "$DOTFILES_DIR/etc/ly/ly.service" "/etc/systemd/system/ly.service"

log "Reloading systemd daemon..."
sudo systemctl daemon-reexec || log "Warning: daemon-reexec failed, continuing..."

### SET ZSH AS DEFAULT SHELL ###
log "Ensuring /bin/zsh is listed in /etc/shells..."
echo "/bin/zsh" | sudo tee -a /etc/shells >/dev/null

log "Changing default shell to Zsh..."
if [ "$SHELL" != "/bin/zsh" ]; then
    chsh -s /bin/zsh || error "Failed to set Zsh as default shell"
    log "Shell changed to Zsh. You need to log out and log back in for changes to take effect."
fi

### ENABLE ESSENTIAL SYSTEM SERVICES ###
log "Enabling system services..."
sudo systemctl enable --now NetworkManager || error "Failed to enable NetworkManager"
sudo systemctl enable sshd || error "Failed to enable SSH"
sudo systemctl enable ly || log "ly enabled"

log "System services setup complete."

### SET WALLPAPER ###
log "Setting wallpaper..."

if [ -f "$HOME/.config/nitrogen/nitrogen.cfg" ]; then
    sed -i "/^dirs=/c\\dirs=$HOME/Pictures/Wallpapers;" "$HOME/.config/nitrogen/nitrogen.cfg"
else
    error "nitrogen.cfg not found"
fi

if [ -f "$HOME/.config/nitrogen/bg-saved.cfg" ]; then
    sed -i "/^file=/c\\file=$HOME/Pictures/Wallpapers/wallpaper.png" "$HOME/.config/nitrogen/bg-saved.cfg"
else
    error "bg-saved.cfg not found"
fi

### CLEANUP ###
log "Removing xterm..."
yay -Rns --noconfirm xterm || log "xterm not installed, skipping..."

log "Cleaning up unnecessary dependencies..."
yay -Yc --noconfirm || error "Cleanup failed"

log "Cleaning up temporary and unwanted files..."
rm -f "$HOME/.bash_history" "$HOME/.bash_logout" "$HOME/.bash_profile" "$HOME/.bashrc"
rm "$HOME/Pictures/Screenshots/.gitkeep"

### REBOOT ###
read -p "Installation complete! Reboot now? (y/N): " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
    sudo reboot
else
    log "Reboot later to apply all changes."
fi
