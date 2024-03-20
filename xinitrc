#!/bin/sh

# Setup keyboard
setxkbmap br

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
