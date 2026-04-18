#!/usr/bin/env bash

[ $# -lt 1 ] && {
	echo "Usage: $0 /Volumes/SDCARD_NAME [--folder NAME]"
	exit 1
}

FOLDER_NAME=""
SRC=""

while [[ $# -gt 0 ]]; do
	case "$1" in
	--folder)
		FOLDER_NAME="/$2"
		shift 2
		;;
	*)
		SRC="$1"
		shift
		;;
	esac
done

DEST="$HOME/Pictures/Bestof$FOLDER_NAME"
mkdir -p "$DEST"
[ -d "$SRC" ] || {
	echo "DCIM not found: $SRC"
	exit 1
}

find "$SRC" -type f \( -iname "*.jpg" -o -iname "*.jpeg" \) -print0 |
	while IFS= read -r -d '' f; do
		stat -f "%Sf" "$f" | grep -Eq 'uchg|schg' || continue

		ts="$(exiftool -s3 -d "%Y-%m-%d_%H-%M-%S" -DateTimeOriginal -CreateDate "$f" | head -n 1)"
		[ -n "$ts" ] || ts="$(stat -f "%Sm" -t "%Y-%m-%d_%H-%M-%S" "$f")"

		orig="$(basename "$f")"
		orig="${orig%.*}"
		ext="${f##*.}"

		base="${ts}_${orig}"
		out="$DEST/$base.$ext"

		if [ -e "$out" ]; then
			echo "$out already copied."
		else
			echo "Copying: $f -> $(basename "$out")"
			cp -f "$f" "$out"
		fi
	done

echo "Done."
