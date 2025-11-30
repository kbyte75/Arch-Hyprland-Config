# My ARCH-Hyprland Config

1. Download or clone this repository.
2. Copy all files to `~/.config`, except `nanorc`, `sddm-login-theme` & `previews`.
3. Copy `nanorc` in `/etc/`.
4. Copy `sddm-login-theme` in `/usr/share/sddm/themes`.
5. Setup Cursor, Icon Theme, Fonts with nwg-look

## Required Dependencies

```bash
 sudo pacman -S waybar swww rofi hyprlock hypridle hyprshot matugen fish fastfetch sddm kitty make cmake base-devel git nano python-pyquery nwg-look nautilus font-manager blueman nm-connection-editor --needed
```

## Create Folder

```bash
  mkdir -p ~/Pictures
  mkdir -p ~/Pictures/Screenshots
  mkdir -p ~/Pictures/Wallpapers
```

## Install Yay

```bash
 git clone https://aur.archlinux.org/yay. git
 cd yay
 makepkg -si
```

## Install oh-my-posh

```bash
 yay -S oh-my-posh hypremoji --noconfirm
```

## Change Default Shell to Fish

```bash
 chsh -s /usr/local/bin/fish
```

## Download Fonts, Themes, Cursor, Icon

- **Bibata Modern Ice Cursor**: [Click](https://www.gnome-look.org/p/1197198)
- **MacTahoe Icon Theme**: [Click](https://www.gnome-look.org/p/2299216)

- **Rubik**: [Link](https://fonts.google.com/selection?query=rubik)
- **Poppins**: [Link](https://fonts.google.com/selection?query=poppins)
- **A Black Lives**: [Link](https://www.dafont.com/a-black-lives.font)
- **Voice In My Head**: [Link](https://www.dafont.com/voice-in-my-head.font)
- **FiraCode Nerd Font**: [Link](https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/FiraCode.zip)

## Set permissions

```bash
 sudo chmod +x ~/.config/hypr/scripts/*.sh
 sudo chmod +x ~/.config/waybar/scripts/*.sh
 sudo chmod +x ~/.config/rofi/scripts/*.sh
 sudo chmod +x ~/.config/waybar/scripts/weather.py
```

### - WAYBAR

![Alt text](https://github.com/kbyte75/my-arch-config/blob/main/previews/waybar.png?raw=true)

### - FASTFETCH

![Alt text](https://github.com/kbyte75/my-arch-config/blob/main/previews/fish_&_fastfetch.png?raw=true)

### - KEYBINDINGS

<table width="100%">
  <tbody>
    <tr><td>SUPER + RETURN</td><td>OPEN TERMINAL</td></tr>
    <tr><td>SUPER + D</td><td>CLOSE ACTIVE WINDOW</td></tr>
    <tr><td>SUPER + F</td><td>OPEN FILE MANAGER</td></tr>
    <tr><td>SUPER + R</td><td>LAUNCH ROFI</td></tr>
    <tr><td>SUPER + B</td><td>OPEN FIREFOX</td></tr>
    <tr><td>SUPER + C</td><td>OPEN VSCODIUM</td></tr>
    <tr><td>SUPER + M</td><td>OPEN MOTRIX</td></tr>
    <tr><td>SUPER + W</td><td>OPEN WAYDROID</td></tr>
    <tr><td>SUPER + .</td><td>OPEN EMOJI PICKER</td></tr>
    <tr><td>SUPER + SHIFT + F</td><td>TOGGLE FULLSCREEN</td></tr>
    <tr><td>SUPER + SPACE</td><td>TOGGLE FLOATING</td></tr>
    <tr><td>SUPER + P</td><td>SELECT AREA SCREENSHOT</td></tr>
    <tr><td>PRINT</td><td>FULL SCREENSHOT</td></tr>
    <tr><td>SUPER + T</td><td>SWITCH WALLPAPER</td></tr>
    <tr><td>SUPER + J</td><td>TOGGLE WAYBAR</td></tr>
    <tr><td>ALT + SPACE</td><td>RELOAD WAYBAR</td></tr>
    <tr><td>SUPER + MOUSE UP</td><td>PREVIOUS WORKSPACE</td></tr>
    <tr><td>SUPER + MOUSE DOWN</td><td>NEXT WORKSPACE</td></tr>
    <tr><td>ALT + MOUSE UP</td><td>MOVE WINDOW TO PREVIOUS WORKSPACE</td></tr>
    <tr><td>ALT + MOUSE DOWN</td><td>MOVE WINDOW TO NEXT WORKSPACE</td></tr>
    <tr><td>SUPER + 1–9</td><td>SWITCH TO WORKSPACE 1–9</td></tr>
    <tr><td>SUPER + LMB DRAG</td><td>MOVE WINDOW</td></tr>
    <tr><td>SUPER + RMB DRAG</td><td>RESIZE WINDOW</td></tr>
  </tbody>
</table>
