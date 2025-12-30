#!/usr/bin/env bash
# shellcheck disable=SC1091

# ================================================================
#  Hyprland Installer — KBYTE75
# ================================================================

set -Eeuo pipefail
IFS=$'\n\t'

# ==============================================================================
# Global Configuration
# ==============================================================================
readonly REPO_URL="https://github.com/kbyte75/Arch-Hyprland-Config.git"
readonly WALLPAPER_REPO_URL="https://github.com/kbyte75/wallpapers.git"

readonly CONFIG_DIR="$HOME/.config"
readonly WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

readonly STATE_DIR="$HOME/.local/state/hyprland-installer"
readonly LOG_FILE="$STATE_DIR/install.log.json"
readonly STATE_FILE="$STATE_DIR/state.txt"
readonly BACKUP_DIR="$STATE_DIR/backup"
readonly CONFIG_BACKUP="$BACKUP_DIR/config-full"

# ANSI colors
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly NC='\033[0m'

# ==============================================================================
# Runtime Flags
# ==============================================================================
DRY_RUN=false
CI_MODE=false
UNINSTALL=false

# User-selected options (defaults)
update_vscodium_icons=false
INSTALL_WALLPAPERS=false
SET_FISH_SHELL=true
CONFIGURE_BOOTLOADER=true
REBOOT_AFTER=false

STEP=0
TOTAL_STEPS=14

mkdir -p "$STATE_DIR" "$BACKUP_DIR"

# ==============================================================================
# Logging
# ==============================================================================
json_log() {
	local level="$1"
	shift
	printf '{"time":"%s","level":"%s","step":%d,"dry_run":%s,"message":"%s"}\n' \
		"$(date --iso-8601=seconds)" \
		"$level" "$STEP" "$DRY_RUN" \
		"$(printf '%s' "$*" | sed 's/"/\\"/g')" \
		>>"$LOG_FILE"
}

log() {
	echo -e "${GREEN}[INFO]${NC} $*"
	json_log info "$@"
}
warn() {
	echo -e "${YELLOW}[WARN]${NC} $*"
	json_log warn "$@"
}
error() {
	echo -e "${RED}[ERROR]${NC} $*" >&2
	json_log error "$@"
}
die() {
	error "$@"
	exit 1
}

step() {
	STEP=$((STEP + 1))
	log "[$STEP/$TOTAL_STEPS] $*"
}

# ==============================================================================
# Helpers
# ==============================================================================
run() {
	if $DRY_RUN; then echo "[dry-run] $*"; else "$@"; fi
}

state_add() { echo "$1" >>"$STATE_FILE"; }
state_read() { [[ -f "$STATE_FILE" ]] && cat "$STATE_FILE"; }

pacman_install() {
	for p in "$@"; do pacman -Qi "$p" &>/dev/null || state_add "pacman:$p"; done
	run sudo pacman -S --needed --noconfirm "$@"
}

aur_install() {
	for p in "$@"; do pacman -Qi "$p" &>/dev/null || state_add "aur:$p"; done
	run yay -S --needed --noconfirm "$@"
}

check_os() {
	command -v pacman >/dev/null || die "This installer supports Arch Linux only."
}

# ==============================================================================
# Arguments
# ==============================================================================
show_help() {
	cat <<EOF
Hyprland Installer — KBYTE75

Usage:
  install.sh [OPTIONS]

Options:
  --dry-run           Show what would be executed
  --ci                Non-interactive mode
  --uninstall         Remove installed packages and state
  -h, --help          Show this help
EOF
}

parse_args() {
	for arg in "$@"; do
		case "$arg" in
		-h | --help)
			show_help
			exit 0
			;;
		--dry-run) DRY_RUN=true ;;
		--ci) CI_MODE=true ;;
		--uninstall) UNINSTALL=true ;;
		*) die "Unknown argument: $arg" ;;
		esac
	done
}

# ==============================================================================
# Uninstall
# ==============================================================================
uninstall() {
	step "Uninstalling"
	local p=() a=()
	while read -r e; do
		case "$e" in
		pacman:*) p+=("${e#pacman:}") ;;
		aur:*) a+=("${e#aur:}") ;;
		esac
	done < <(state_read)

	((${#a[@]})) && run yay -Rns --noconfirm "${a[@]}"
	((${#p[@]})) && run sudo pacman -Rns --noconfirm "${p[@]}"
	run rm -rf "$STATE_DIR"
	log "Uninstall completed"
}

# ==============================================================================
# User Configuration Phase
# ==============================================================================
get_user_choice() {
	step "Collecting user preferences"

	if $CI_MODE; then
		warn "CI mode: using defaults"
		update_vscodium_icons=true
		INSTALL_WALLPAPERS=false
		REBOOT_AFTER=false
		return
	fi

	read -r -p "Install VSCodium (VSCode alternative)? [y/N]: " r || true
	[[ "$r" =~ ^[Yy]$ ]] && update_vscodium_icons=true

	read -r -p "Download wallpapers? [y/N]: " r || true
	[[ "$r" =~ ^[Yy]$ ]] && INSTALL_WALLPAPERS=true

	read -r -p "Set fish as default shell? [Y/n]: " r || true
	[[ "$r" =~ ^[Nn]$ ]] && SET_FISH_SHELL=false

	read -r -p "Configure bootloader timeout? [Y/n]: " r || true
	[[ "$r" =~ ^[Nn]$ ]] && CONFIGURE_BOOTLOADER=false

	read -r -p "Reboot automatically after install? [y/N]: " r || true
	[[ "$r" =~ ^[Yy]$ ]] && REBOOT_AFTER=true

	echo
	log "Configuration summary:"
	echo "  VSCodium:        $update_vscodium_icons"
	echo "  Wallpapers:      $INSTALL_WALLPAPERS"
	echo "  Fish shell:      $SET_FISH_SHELL"
	echo "  Bootloader tweak:$CONFIGURE_BOOTLOADER"
	echo "  Reboot:    $REBOOT_AFTER"

	echo
	read -r -p "Proceed with installation? [Y/n]: " r || true
	[[ "$r" =~ ^[Nn]$ ]] && die "Installation aborted"
}

# ==============================================================================
# Phases
# ==============================================================================
updating_system() {
	step "Preparing system update"
	run sudo pacman -Syu --noconfirm
}

install_dependencies() {
	step "Installing base dependencies"
	pacman_install base-devel git rsync jq eog eza nano grim slurp shfmt \
		nwg-look font-manager imagemagick blueman nm-connection-editor \
		python-pyquery adw-gtk-theme qt6-base starship \
		xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
}

install_main_packages() {
	step "Installing main packages"
	pacman_install waybar swww rofi hyprlock hypridle matugen fish \
		fastfetch kitty nautilus cliphist wl-clipboard
}

change_shell() {
	$SET_FISH_SHELL || return 0
	step "Setting fish as default shell"
	command -v fish &>/dev/null && run sudo chsh -s /usr/bin/fish "$USER"
}

install_yay() {
	step "Installing yay"
	command -v yay &>/dev/null && return
	run git clone https://aur.archlinux.org/yay.git /tmp/yay
	run bash -c 'cd /tmp/yay && makepkg -si --noconfirm'
}

# phase_prepare_vscodium() {
# 	$update_vscodium_icons || return 0
# 	pgrep -f codium &>/dev/null && run pkill -f codium || true
# }

install_yay_packages() {
	step "Installing AUR packages"
	local aur_pkgs=(hypremoji ibus-m17n m17n-db)
	$update_vscodium_icons && pgrep -f codium &>/dev/null && run pkill -f codium || true #check is vscodium running
	$update_vscodium_icons && aur_pkgs+=(vscodium-bin)
	aur_install "${aur_pkgs[@]}"
}

update_vscodium_icons() {
	$update_vscodium_icons || return 0
	command -v codium &>/dev/null || return 0
	step "Adjusting VSCodium icons"
	for f in /usr/share/applications/codium*.desktop; do
		[[ -f "$f" ]] && run sudo sed -i 's/^Icon=.*/Icon=vscode/' "$f"
	done
}

clone_config_repo() {
	step "Installing configuration files"

	if [[ -d "$CONFIG_DIR" && ! -d "$CONFIG_BACKUP" ]]; then
		log "Backing up ~/.config"
		run cp -a "$CONFIG_DIR" "$CONFIG_BACKUP"
	fi

	local tmp
	tmp="$(mktemp -d)"
	run git clone "$REPO_URL" "$tmp"
	run rsync -a --delete --exclude='.git' "$tmp"/ "$CONFIG_DIR"/
	run rm -rf "$tmp"
}

setup_permissions() {
	step "Fixing script permissions"
	run chmod +x "$CONFIG_DIR"/hypr/scripts/*.sh 2>/dev/null || true
	run chmod +x "$CONFIG_DIR"/waybar/scripts/*.{sh,py} 2>/dev/null || true
}

clone_wallpaper_repo() {
	$INSTALL_WALLPAPERS || return 0
	step "Installing wallpapers"

	mkdir -p "$HOME/Pictures"
	local tmp
	tmp="$(mktemp -d)"

	run git clone "$WALLPAPER_REPO_URL" "$tmp"
	run mkdir -p "$WALLPAPER_DIR"
	run rsync -a --delete --exclude='.git' "$tmp"/ "$WALLPAPER_DIR"/
	run rm -rf "$tmp"
}
setup_gtk_theme() {
	# Apply via gsettings (best-effort, non-fatal)
	if command -v gsettings >/dev/null; then
		run gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk-theme' || true
		# run gsettings set org.gnome.desktop.interface icon-theme 'Adwaita' || true
		# run gsettings set org.gnome.desktop.interface cursor-theme 'Adwaita' || true
	fi
}

other_tweaks() {
	$CONFIGURE_BOOTLOADER || return 0
	step "Applying optional system tweaks"

	run sudo rsync -a "$CONFIG_DIR/nanorc" /etc/ # Copy nanorc file to /etc

	if bootctl is-installed >/dev/null 2>&1; then
		run sudo sed -i.bak 's/^timeout .*/timeout 1/' /boot/loader/loader.conf
	elif command -v grub-mkconfig >/dev/null 2>&1; then
		run sudo sed -i.bak 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=1/' /etc/default/grub
		run sudo grub-mkconfig -o /boot/grub/grub.cfg
	fi
}

reboot_system() {
	$REBOOT_AFTER || return 0
	run sudo reboot
}

# ==============================================================================
# Main
# ==============================================================================
main() {
	parse_args "$@"
	check_os

	$UNINSTALL && {
		uninstall
		exit 0
	}

	log "Installer started"
	$DRY_RUN && warn "DRY-RUN mode"
	$CI_MODE && warn "CI mode"

	get_user_choice
	updating_system
	install_dependencies
	install_main_packages
	change_shell
	install_yay
	# phase_prepare_vscodium
	install_yay_packages
	update_vscodium_icons
	clone_config_repo
	clone_wallpaper_repo
	setup_permissions
	other_tweaks
	reboot_system

	log "Installation completed successfully"
}

main "$@"
