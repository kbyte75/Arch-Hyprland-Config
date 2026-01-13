fish_add_path ~/.local/bin

# Disable default greeting
set -g fish_greeting ''

set -g fish_complete_case_insensitive 1
set -g fish_fuzzy_complete 1

starship init fish | source

# Oh My Posh prompt
# oh-my-posh init fish --config ~/.config/fish/atomic.omp.json | source

# Done plugin: minimum command duration (ms) for notification
set -U __done_min_cmd_duration 5000

# Subtle autosuggestion color
set -g fish_color_autosuggestion 95969a

# Input method (Bangla typing)
set -Ux NO_AT_BRIDGE 1

# Optimize makepkg for 4 CPU cores
set -Ux MAKEFLAGS "-j4"

#--- Aliases & abbreviations---
abbr -a ls 'eza --icons --group-directories-first'
abbr -a motrix '~/Desktop/motrix/motrix'
abbr -a wsstop 'waydroid session stop'

# Package management
abbr -a update 'sudo pacman -Syyu'
abbr -a clean 'sudo pacman -Sc --noconfirm;
pacman -Qtdq >/dev/null 2>&1 && sudo pacman -Rns (pacman -Qtdq) --noconfirm;
yay -Qdtq >/dev/null 2>&1 && yay -Rns (yay -Qdtq) --noconfirm'

#  install / uninstall using yay & pacman
abbr -a ys 'yay -S --needed --noconfirm'
abbr -a yr 'yay -Rs --noconfirm'
abbr -a pi 'sudo pacman -S --needed --noconfirm'
abbr -a pr 'sudo pacman -Rns --noconfirm'

# Replace cp with rsync (safe & fast)
abbr -a cp 'rsync -a --info=progress2 --ignore-existing'
abbr -a scp 'sudo rsync -a --info=progress2 --ignore-existing'

# Git
abbr -a gs 'git status'
abbr -a ga 'git add .'
abbr -a gc 'git commit -m'
abbr -a gp 'git push'
abbr -a gl 'git log --oneline --graph --decorate'
abbr -a close '$HOME/.config/hypr/scripts/close_ws.sh'

# Optional: unlock pacman database (use only when needed)
abbr -a unlockdb 'sudo rm /var/lib/pacman/db.lck'
