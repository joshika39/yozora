#!/bin/bash

current_spaces=$(yabai -m query --spaces | jq length)
target_spaces=12

while [ "$current_spaces" -lt "$target_spaces" ]; do
	yabai -m space --create
	sleep 0.5
	current_spaces=$(yabai -m query --spaces | jq length)
done
