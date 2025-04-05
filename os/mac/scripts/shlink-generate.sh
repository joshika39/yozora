#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Create Short URL
# @raycast.mode compact

# Optional parameters:
# @raycast.icon ./images/shlink.png
# @raycast.packageName Shlink
# @raycast.argument2 { "type": "text", "placeholder": "URL", "optional": true, "percentEncoded": false }

# Documentation:
# @raycast.author joshika39
# @raycast.description Create a short URL using Shlink
# @raycast.authorURL https://github.com/joshika39

# Set the following environment variables in your .env file
# SHLINK_APIKEY: Shlink server API key (https://shlink.io/documentation/command-line-interface/entry-point/)
# SHLINK_URL: Shlink server URL
# SHLINK_PROTOCOL: http or https
# SHLINK_TAG: If you want to add a tag to the short URL, set it here

set -a
source .env
set +a

APIKEY=$SHLINK_APIKEY
BASEURL=$SHLINK_URL
PROTOCOL=$SHLINK_PROTOCOL
TAG=${SHLINK_TAG:-""}

if [ -z "$APIKEY" ]; then
	echo "Please set the SHLINK_APIKEY environment variable in your .env file."
	exit 1
fi

if ! command -v jq &>/dev/null; then
	echo "jq is required (https://stedolan.github.io/jq/)."
	exit 1
fi

if [ -z "$1" ]; then
	URL=$(pbpaste)
else
	URL=$1
fi

if [[ $URL =~ ^https?://[a-zA-Z0-9./?=_-]*$ ]]; then
	SHORT_URL=$(curl --location --silent --request POST ''"$PROTOCOL"'/rest/v1/short-urls' \
		--header 'Content-Type: application/json' \
		--header 'X-Api-Key: '"$APIKEY"'' \
		--data-raw '{
        "longUrl": "'"$URL"'",
        "validateUrl": false,
        "tags": [
            "'$TAG'"
        ],
        "findIfExists": true,
        "domain": "'"$BASEURL"'"
    }' | jq -r '.shortUrl')

	if [ -n "$SHORT_URL" ]; then
		echo "$SHORT_URL" | pbcopy
		echo "Copied $SHORT_URL to your clipboard"
	else
		echo "Error: Could not create short URL"
		exit 1
	fi

else
	echo "Invalid URL \"$URL\""
	exit 1
fi
