#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Create Short URL
# @raycast.mode compact

# Optional parameters:
# @raycast.icon ./images/shlink.png
# @raycast.packageName Shlink
# @raycast.argument1 { "type": "text", "placeholder": "URL", "percentEncoded": false }
# @raycast.argument2 { "type": "text", "placeholder": "Custom Slug (optional)", "optional": true, "percentEncoded": false }
# @raycast.argument3 { "type": "text", "placeholder": "Tag (optional)", "optional": true, "percentEncoded": false }

# Documentation:
# @raycast.author joshika39
# @raycast.description Create a short URL using Shlink with an optional custom slug
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
SH_URL="$PROTOCOL://$BASEURL"

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

SLUG=${2:-""}
TAG=${SHLINK_TAG:-""}
TAG=${3:-$TAG}

if [[ $URL =~ ^https?://[a-zA-Z0-9./?=_-]*$ ]]; then
	JSON_PAYLOAD='{
        "longUrl": "'"$URL"'",
        "validateUrl": false,
        "tags": ["'"$TAG"'"],
        "findIfExists": true,
        "domain": "'"$BASEURL"'"
    }'

	# Add the custom slug to the payload if provided
	if [ -n "$SLUG" ]; then
		JSON_PAYLOAD=$(echo "$JSON_PAYLOAD" | jq --arg slug "$SLUG" '. + { "customSlug": $slug }')
	fi

	SHORT_URL=$(curl --location --silent --request POST "$SH_URL/rest/v1/short-urls" \
		--header 'Content-Type: application/json' \
		--header 'X-Api-Key: '"$APIKEY"'' \
		--data-raw "$JSON_PAYLOAD" | jq -r '.shortUrl')

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
