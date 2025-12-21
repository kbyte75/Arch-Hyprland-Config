#!/usr/bin/env bash
# shellcheck disable=SC1091

# ================================================================
#
#    ██╗  ██╗██████╗ ██╗   ██╗████████╗███████╗███████╗███████╗
#    ██║ ██╔╝██╔══██╗╚██╗ ██╔╝╚══██╔══╝██╔════╝╚════██║██╔════╝
#    █████╔╝ ██████╔╝ ╚████╔╝    ██║   █████╗      ██╔╝███████╗
#    ██╔═██╗ ██╔══██╗  ╚██╔╝     ██║   ██╔══╝     ██╔╝ ╚════██║
#    ██║  ██╗██████╔╝   ██║      ██║   ███████╗   ██║  ███████║
#
# ================================================================

set -Eeuo pipefail
IFS=$'\n\t'

# ==============================================================================
# Global Configuration
# ==============================================================================
readonly REPO_URL="https://github.com/kbyte75/Arch-Hyprland-Config.git"
readonly CONFIG_DIR="$HOME/.config"

readonly STATE_DIR="$HOME/.local/state/hyprland-installer"
readonly LOG_FILE="$STATE_DIR/install.log.json"
readonly STATE_FILE="$STATE_DIR/state.txt"
readonly BACKUP_DIR="$STATE_DIR/backup"
readonly CONFIG_BACKUP="$BACKUP_DIR/config-full"

readonly WALLPAPER_REPO_URL="https://github.com/kbyte75/wallpapers.git"
readonly WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

# ANSI colors
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly NC='\033[0m'

# Runtime flags
DRY_RUN=false
CI_MODE=false
ROLLBACK=false
UNINSTALL=false

STEP=0
TOTAL_STEPS=13

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

check_os() { command -v pacman >/dev/null || die "Arch Linux only."; }

# ==============================================================================
# Args & Checks
# ==============================================================================

show_help() {
	cat <<'EOF'
Hyprland Installer

Usage:
  install.sh [OPTIONS]

Options:
  -h, --help            Show this help message and exit
      --dry-run         Show what would be executed without making changes
      --ci              Run in CI / non-interactive mode (no prompts)
      --rollback        Restore ~/.config from the last backup
      --uninstall       Remove installed packages and installer state

Examples:
  ./install.sh
  ./install.sh --dry-run
  ./install.sh --ci
  ./install.sh --rollback
  ./install.sh --uninstall
EOF
}

parse_args() {
	for arg in "$@"; do
		case "$arg" in
		-h | --help)
			show_help
			exit 0
			;;
		--dry-run)
			DRY_RUN=true
			;;
		--ci | --non-interactive)
			CI_MODE=true
			;;
		--rollback)
			ROLLBACK=true
			;;
		--uninstall)
			UNINSTALL=true
			;;
		*)
			die "Unknown argument: $arg (use --help)"
			;;
		esac
	done
}
# ==============================================================================
# Rollback / Uninstall
# ==============================================================================
rollback() {
	step "Rollback"
	[[ -d "$CONFIG_BACKUP" ]] || die "No backup found"
	run rm -rf "$CONFIG_DIR"
	run cp -a "$CONFIG_BACKUP" "$CONFIG_DIR"
	log "Rollback completed"
}

uninstall() {
	step "Uninstall"
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
# Phases
# ==============================================================================
phase_update_system() {
	step "Prepareing System update"
	run sudo pacman -Syu --noconfirm
}

phase_dependencies() {
	step "Installing Base dependencies"
	pacman_install base-devel git rsync jq nano grim slurp shfmt \
		nwg-look font-manager imagemagick blueman nm-connection-editor python-pyquery \
		adw-gtk-theme qt6-base xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
}

phase_main_packages() {
	step "Installing Required Packages"
	pacman_install waybar swww rofi hyprlock hypridle matugen fish \
		fastfetch kitty nautilus cliphist wl-clipboard
}

phase_shell() {
	step "Change Default shell to fish"
	command -v fish &>/dev/null && run chsh -s /usr/bin/fish "$USER" || true
}

phase_yay() {
	step "Setting up Yay Package Manager"
	command -v yay &>/dev/null && return
	run git clone https://aur.archlinux.org/yay.git /tmp/yay
	run bash -c 'cd /tmp/yay && makepkg -si --noconfirm'
}

phase_rust_conflict() {
	step "Rust conflict resolution"
	if pacman -Qi rust &>/dev/null && ! pacman -Qi rustup &>/dev/null; then
		warn "Replacing rust with rustup"
		run sudo pacman -Rns --noconfirm rust
	fi
}

phase_prepare_vscodium() {
	#  if vscodium is running then terminate
	pgrep -f codium &>/dev/null && run pkill -f codium || true
}

phase_aur_packages() {
	step "Installing AUR packages"
	aur_install hypremoji vscodium-bin ibus-m17n m17n-db
}

phase_vscodium_icons() {
	step "Changing icon  VSCodium  to VSCode "
	command -v codium &>/dev/null || return
	for f in /usr/share/applications/codium*.desktop; do
		[[ -f "$f" ]] && run sudo sed -i 's/^Icon=.*/Icon=vscode/' "$f"
	done
}

phase_clone_repo() {
	step "Cloning Config in ~/.config"

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

phase_permissions() {
	step "Setting up Permissions."
	run chmod +x "$CONFIG_DIR"/hypr/scripts/*.sh 2>/dev/null || true
	run chmod +x "$CONFIG_DIR"/waybar/scripts/*.sh 2>/dev/null || true
	run chmod +x "$CONFIG_DIR"/waybar/scripts/*.py 2>/dev/null || true
}

phase_wallpapers() {
	step "Download Wallpapers"

	# Never prompt in CI
	if $CI_MODE; then
		warn "CI mode detected; skipping wallpaper download"
		return 0
	fi

	echo
	read -r -p "(Optional) Do you want to download wallpapers? (~$(du -sh "$WALLPAPER_DIR" 2>/dev/null | awk '{print $1}' || echo 'unknown size'))? [y/N]: " reply || true

	if [[ ! "$reply" =~ ^[Yy]$ ]]; then
		log "Skipped wallpaper download."
		return 0
	fi

	mkdir -p "$HOME/Pictures"

	local tmp
	tmp="$(mktemp -d)"

	log "Cloning wallpaper repository"
	run git clone "$WALLPAPER_REPO_URL" "$tmp"

	log "Syncing wallpapers to $WALLPAPER_DIR"
	run mkdir -p "$WALLPAPER_DIR"
	run rsync -a --delete \
		--exclude='.git' \
		"$tmp"/ "$WALLPAPER_DIR"/

	run rm -rf "$tmp"

	log "Wallpapers downloaded successfully"
}

phase_optional() {
	sudo rsync -a --info=progress2 nanorc /etc/

	sudo sed -i 's/^timeout .*/timeout 0/' /boot/loader/loader.conf # No Waiting in Systemd boot menu

	sudo sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/' /etc/default/grub # No Waiting in Grub boot menu
	sudo grub-mkconfig -o /boot/grub/grub.cfg
}

phase_reboot_prompt() {
	$CI_MODE && {
		warn "CI mode: skipping reboot"
		return
	}
	read -r -p "Reboot now? (Recommended) [y/N]: " r || true
	[[ "$r" =~ ^[Yy]$ ]] && run sudo reboot
}
# ==============================================================================
# Main
# ==============================================================================
main() {
	parse_args "$@"
	check_os

	$ROLLBACK && {
		rollback
		exit 0
	}
	$UNINSTALL && {
		uninstall
		exit 0
	}

	log "Installer started"
	$DRY_RUN && warn "DRY-RUN mode"
	$CI_MODE && warn "CI mode"

	phase_update_system
	phase_dependencies
	phase_main_packages
	phase_shell
	phase_yay
	phase_rust_conflict
	phase_prepare_vscodium
	phase_aur_packages
	phase_vscodium_icons
	phase_clone_repo
	phase_wallpapers
	phase_permissions
	phase_optional
	phase_reboot_prompt

	log "Installation completed"
}

main "$@"
