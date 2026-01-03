#!/usr/bin/env sh

idx="$(yabai -m query --displays | jq -r '
  sort_by(.frame.y) as $d
  | ($d | map(select(."has-focus")) | .[0]) as $cur
  | ($cur.frame.y) as $cy
  | ($d | map(select(.frame.y < $cy))) as $up
  | if ($up|length) > 0 then $up[-1].index else $d[-1].index end
')"

[ -n "$idx" ] && yabai -m display --focus "$idx"
