#!/bin/bash

battery() {
	BAT=`ls /sys/class/power_supply | grep BAT | head -n 1`

  if [[ -f /sys/class/power_supply/${BAT}/capacity ]]; then
    cat /sys/class/power_supply/${BAT}/capacity
  else
    echo ""
  fi
}
battery_stat() {
	BAT=`ls /sys/class/power_supply | grep BAT | head -n 1`

  if [[ -f /sys/class/power_supply/${BAT}/capacity ]]; then
    cat /sys/class/power_supply/${BAT}/status
  else
    echo ""
  fi
}

if [[ "$1" == "--bat" ]]; then
	battery
elif [[ "$1" == "--bat-st" ]]; then
	battery_stat
fi

