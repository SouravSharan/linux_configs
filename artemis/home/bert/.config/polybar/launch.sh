#!/bin/bash

# Wait for X server and monitors to settle
sleep 3

# Kill existing Polybar instances
killall -q polybar

# Wait for processes to close
while pgrep -x polybar >/dev/null; do sleep 1; done

# Get connected monitors dynamically
monitors=$(xrandr --query | grep " connected" | cut -d" " -f1)

# Launch Polybar on each monitor
for monitor in $monitors; do
    MONITOR=$monitor polybar alpha --reload &
done

echo "Polybar launched on all monitors!"
