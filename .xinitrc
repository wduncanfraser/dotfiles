# Load x resources
if [ -f ~/.Xresources ]; then 
  xrdb -merge ~/.Xresources 
fi

# Start audio
start-pulseaudio-x11

# Setup Monitors
xrandr --output DVI-D-0 --auto --pos 0x180 \
  --output DP-2 --auto --primary --pos 1920x0 \
  --output DP-0 --auto --pos 4480x180

# Nvidia
nvidia-settings --load-config-only

# Start WM
exec i3
