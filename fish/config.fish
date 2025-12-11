fish_add_path ~/.local/bin
set -g fish_greeting ''

oh-my-posh init fish --config ~/.config/fish/atomic.omp.json | source

set -U __done_min_cmd_duration 5000
set -g fish_color_autosuggestion 95969a

# BANGLA TYPING
set -Ux NO_AT_BRIDGE 1
set -Ux IBUS_ENABLE_SYNC_MODE 0
set -Ux GDK_BACKEND wayland

# YAY BUILD
set -Ux MAKEFLAGS "-j4"

#  ALIAS
abbr -a ls eza --icons --group-directories-first
alias motrix="~/Desktop/motrix/motrix"
abbr -a wsstop waydroid session stop
abbr -a ys yay -S --needed --noconfirm