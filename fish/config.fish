fish_add_path ~/.local/bin

# Disable default greeting
set -g fish_greeting ''

# Oh My Posh prompt
oh-my-posh init fish --config ~/.config/fish/atomic.omp.json | source

# Done plugin: minimum command duration (ms) for notification
set -U __done_min_cmd_duration 5000

# Subtle autosuggestion color
set -g fish_color_autosuggestion 95969a

# Input method (Bangla typing)
set -Ux NO_AT_BRIDGE 1
set -Ux IBUS_ENABLE_SYNC_MODE 0
set -Ux GDK_BACKEND wayland

# Optimize makepkg for 4 CPU cores
set -Ux MAKEFLAGS "-j4"

# Aliases & abbreviations
abbr -a ls   eza --icons --group-directories-first
abbr -a motrix ~/Desktop/motrix/motrix
abbr -a wsstop waydroid session stop

# Package management
abbr -a update sudo pacman -Syyu
abbr -a clean  'sudo pacman -Sc;sudo pacman -Rns $(pacman -Qtdq) --noconfirm;yay -Rns $(yay -Qdtq 2>/dev/null); yay -Scc'
abbr -a ys     'yay -S --needed --noconfirm'

# Optional: unlock pacman database (use only when needed)
# abbr -a unlock 'sudo rm /var/lib/pacman/db.lck'