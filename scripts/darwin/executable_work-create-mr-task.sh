#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Checkout or investigate GitLab work item
# @raycast.mode fullOutput
# @raycast.icon 🚚

# Documentation:
# @raycast.author joshika39
# @raycast.authorURL https://raycast.com/joshika39
# @raycast.packageName Safari GitLab actions
# @raycast.argument1 { "type": "dropdown", "placeholder": "Checkout", "data": [{"title": "Checkout", "value": "1"},{"title": "Just task", "value": "2"}] }

set -euo pipefail

MY_USERNAME="joshika39"
THINGS_LIST_ID="HLcSHt2UdiVVN1MhntVbp3"
THINGS_TOKEN_SERVICE="things-url-auth-token"

url="$(safari-ctl)"

if [[ -z "$url" ]]; then
	echo "Could not read Safari URL."
	exit 1
fi

if [[ "$url" != https://gitlab.com/* ]]; then
	echo "Not a valid GitLab tab!"
	exit 1
fi

project_path="$(echo "$url" | sed -E 's#^https://gitlab\.com/##; s#(/-/(merge_requests|issues)/[0-9]+.*)$##')"

if [[ -z "$project_path" || "$project_path" == "$url" ]]; then
	echo "Could not determine project from URL!"
	exit 1
fi

repo="$(echo "$project_path" | awk -F/ '{print $NF}')"

cd "$HOME/Projects/$repo" >/dev/null 2>&1 || true

project_path_enc="$(
	P="$project_path" python3 -c 'import os, urllib.parse; print(urllib.parse.quote(os.environ["P"], safe=""))'
)"

get_user_id_by_username() {
	local username="$1"
	glab api "users?username=$username" | jq -r '.[0].id'
}

MY_USER_ID="$(get_user_id_by_username "$MY_USERNAME")"

mr_iid=""
issue_iid=""

if [[ "$url" == *"/-/merge_requests/"* ]]; then
	mr_iid="$(echo "$url" | sed -E 's#^.*/-/merge_requests/([0-9]+).*#\1#')"
elif [[ "$url" == *"/-/issues/"* ]]; then
	issue_iid="$(echo "$url" | sed -E 's#^.*/-/issues/([0-9]+).*#\1#')"
else
	echo "Not a merge request or issue URL!"
	exit 1
fi

number=""
title=""
author=""
created_at=""
web_url="$url"

if [[ -n "$mr_iid" ]]; then
	mr_json="$(glab api "projects/$project_path_enc/merge_requests/$mr_iid")"

	eval "$(
		echo "$mr_json" |
			jq '{iid: .iid, title: .title, url: .web_url, author: .author.username, created_at: .created_at}' |
			jq -r '@sh "number=\(.iid)", @sh "title=\(.title)", @sh "web_url=\(.url)", @sh "author=\(.author)", @sh "created_at=\(.created_at)"'
	)"

	if [[ "$author" == *"joshika39"* ]]; then
		created_at_sanitized="$(echo "$created_at" | sed -E 's/\.[0-9]+Z$/Z/')"
		pr_time="$(date -j -u -f "%Y-%m-%dT%H:%M:%SZ" "$created_at_sanitized" +%s 2>/dev/null || echo 0)"
		current_time="$(date +%s)"
		time_diff=$((current_time - pr_time))

		if [[ "$pr_time" -ne 0 && "$time_diff" -le 64000 ]]; then
			task_title="$title"
		else
			task_title="Fixup: $title"
		fi
	else
		task_title="Review: $title"
	fi

	task_notes="[gitlab $project_path!$number]($web_url)"

else
	issue_json="$(glab api "projects/$project_path_enc/issues/$issue_iid")"

	eval "$(
		echo "$issue_json" |
			jq '{iid: .iid, title: .title, url: .web_url}' |
			jq -r '@sh "number=\(.iid)", @sh "title=\(.title)", @sh "web_url=\(.url)"'
	)"

	task_title="Investigate: $title"
	task_notes="[gitlab $project_path#$number]($web_url)"
fi

task_title_escaped="$(echo "$task_title" | sed 's/"/\\"/g')"
task_notes_escaped="$(echo "$task_notes" | sed 's/"/\\"/g')"

task_id="$(
	osascript <<EOF
tell application "Things3"
    set task_list to to dos whose name is "$task_title_escaped"
    if (count of task_list) > 0 then
        return id of item 1 of task_list
    else
        return "no"
    end if
end tell
EOF
)"

auth_token="$(security find-generic-password -s "$THINGS_TOKEN_SERVICE" -w 2>/dev/null || true)"
if [[ -z "$auth_token" ]]; then
	echo "Could not read Things auth token from Keychain (service: $THINGS_TOKEN_SERVICE)."
	exit 1
fi

obs_running="$(pgrep -x OBS || true)"
if [[ -n "${obs_running:-}" ]]; then
	tag_param="&tags=%F0%9F%92%BC%20Work%2C%F0%9F%93%B7%20Sportograf%2C%F0%9F%93%B9%20Stream"
else
	tag_param="&tags=%F0%9F%92%BC%20Work%2C%F0%9F%93%B7%20Sportograf"
fi

if [[ "$task_id" != "no" ]]; then
	open "things:///update?id=$task_id&when=today$tag_param&list-id=$THINGS_LIST_ID&auth-token=$auth_token&completed=false"
else
	open "things:///add?title=$(echo -n "$task_title" | jq -sRr @uri)&notes=$(echo -n "$task_notes" | jq -sRr @uri)&when=today$tag_param&list-id=$THINGS_LIST_ID&auth-token=$auth_token"
fi

echo "Added task"

osascript <<'EOF' >/dev/null 2>&1 || true
tell application "System Events"
    tell application "Things3" to activate
    repeat until application "Things3" is frontmost
        delay 0.01
    end repeat

    delay 0.05
    key code 53
    delay 0.02
    key code 53
    delay 0.02
    key code 125
    delay 0.02
    key code 125
end tell
EOF

assign_mr_to_me() {
	local endpoint="projects/$project_path_enc/merge_requests/$mr_iid"
	glab api -X PUT "$endpoint" -f "assignee_id=$MY_USER_ID" >/dev/null
}

assign_issue_to_me() {
	local endpoint="projects/$project_path_enc/issues/$issue_iid"
	glab api -X PUT "$endpoint" -f "assignee_id=$MY_USER_ID" >/dev/null
}

add_me_as_reviewer() {
	local endpoint="projects/$project_path_enc/merge_requests/$mr_iid"

	if glab api -X PUT "$endpoint" -f "reviewer_ids=$MY_USER_ID" >/dev/null 2>&1; then
		return 0
	fi

	glab api -X PUT "$endpoint" \
		-H "Content-Type: application/json" \
		--raw-field "$(jq -c --argjson id "$MY_USER_ID" '{reviewer_ids: [$id] }')" \
		>/dev/null
}

ensure_git_repo() {
	local p1="$HOME/Projects/$repo"
	local p2="$HOME/Projects/$project_path"
	local p3="$HOME/Projects/gitlab.com/$project_path"

	for p in "$p1" "$p2" "$p3"; do
		if [[ -d "$p/.git" ]]; then
			cd "$p"
			return 0
		fi
	done

	local target="$HOME/Projects/$project_path"
	mkdir -p "$(dirname "$target")"
	glab repo clone "$project_path" "$target"
	cd "$target"
}

if [[ "${1:-2}" -eq 1 ]]; then
	if [[ -n "$mr_iid" ]]; then
		ensure_git_repo
		glab mr checkout "$mr_iid" -R "$project_path"

		echo "Checked out !$number ($title)"

		if [[ "$author" == "$MY_USERNAME" ]]; then
			assign_mr_to_me
		else
			add_me_as_reviewer
		fi
	else
		assign_issue_to_me
	fi
fi
