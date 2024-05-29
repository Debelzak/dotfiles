#!/bin/sh
xrdb ~/.Xresources

# Setup keyboard
setxkbmap br

# Load polkit
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &

# Load wallpaper
nitrogen --restore

# Deploy compositor
picom -b

# Deploy notification daemon
dunst &

# Deploy topbar
eww open bar

# Finally start WM
exec i3
