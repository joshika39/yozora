#!/bin/bash

current_spaces=$(yabai -m query --spaces | jq length)
target_spaces=${1:-10}

while [ "$current_spaces" -lt "$target_spaces" ]; do
	yabai -m space --destroy "$(yabai -m query --spaces | jq '.[-1].index')"
	sleep 0.5
	current_spaces=$(yabai -m query --spaces | jq length)
done
