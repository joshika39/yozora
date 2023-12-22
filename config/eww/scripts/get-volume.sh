#!/bin/sh

getVolume() {
  volume=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -Po '\d+(?=%)' | head -n 1)
  
  # Check if volume is empty
  if [ -z "$volume" ]; then
    echo 0
  else
    echo "$volume"
  fi
}

echo `getVolume`

pactl subscribe | grep --line-buffered "sink" | while read -r UNUSED_LINE; do getVolume; done

