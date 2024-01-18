#!/bin/sh

# Setup keyboard
setxkbmap br

# Set compositor
picom -b

# Set wallpaper
nitrogen --restore

# Set notification manager
dunst &

# Finally start WM
exec i3
