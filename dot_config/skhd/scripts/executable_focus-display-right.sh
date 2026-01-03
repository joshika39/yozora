#!/usr/bin/env sh
idx="$(yabai -m query --displays | jq -r '
  sort_by(.frame.x) as $d
  | ($d | map(select(."has-focus")) | .[0]) as $cur
  | ($cur.frame.x) as $cx
  | ($d | map(select(.frame.x > $cx))) as $right
  | if ($right|length) > 0 then $right[0].index else $d[0].index end
')"

[ -n "$idx" ] && yabai -m display --focus "$idx"
