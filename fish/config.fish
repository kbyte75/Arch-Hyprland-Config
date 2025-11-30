fish_add_path ~/.local/bin
set -g fish_greeting ''
set -U __done_min_cmd_duration 5000
abbr -a ls eza --icons --group-directories-first
set -g fish_color_autosuggestion 95969a
oh-my-posh init fish --config ~/.config/fish/atomic.omp.json | source



