#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Checkout or investigate GitLab work item
# @raycast.mode compact
# @raycast.icon 🚚

# Documentation:
# @raycast.author joshika39
# @raycast.authorURL https://raycast.com/joshika39
# @raycast.packageName Safari GitLab actions
# @raycast.argument1 { "type": "dropdown", "placeholder": "Checkout", "data": [{"title": "Checkout", "value": "1"},{"title": "Just task", "value": "2"}] }

url="$(safari-ctl)"

if [[ "$url" != https://gitlab.com/* ]]; then
	echo "Not a valid GitLab tab!"
	exit 1
fi

project_path="$(echo "$url" | sed -E 's#^https://gitlab\.com/([^/]+/[^/]+).*#\1#')"
project_path="$(echo "$url" | sed -E 's#^https://gitlab\.com/(([^/]+/)+[^/]+)/-/(merge_requests|issues)/[0-9]+.*#\1#')"

if [[ -z "$project_path" || "$project_path" == "$url" ]]; then
	echo "Could not determine project from URL!"
	exit 1
fi

project_name="$(echo "$project_path" | awk -F/ '{print $NF}')"

cd "$HOME/Projects/$project_name/" >/dev/null 2>&1 || true

project_path_enc="$(
	P="$project_path" python3 -c 'import os, urllib.parse; print(urllib.parse.quote(os.environ["P"], safe=""))'
)"

get_user_id_by_username() {
	local username="$1"
	glab api "users?username=$username" | jq -r '.[0].id'
}

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
created_at=""
author=""
web_url="$url"

if [[ -n "$mr_iid" ]]; then
	mr_json="$(glab api "projects/$project_path_enc/merge_requests/$mr_iid")"

	eval "$(
		echo "$mr_json" |
			jq '{iid: .iid, title: .title, url: .web_url, author: .author.username, created_at: .created_at}' |
			jq -r '@sh "number=\(.iid)", @sh "title=\(.title)", @sh "web_url=\(.url)", @sh "author=\(.author)", @sh "created_at=\(.created_at)"'
	)"
	if [[ "$author" == *"joshika39"* ]]; then
		pr_time="$(date -j -u -f "%Y-%m-%dT%H:%M:%SZ" "$created_at" +%s)"
		current_time="$(date +%s)"
		time_diff=$((current_time - pr_time))

		if [ "$time_diff" -le 64000 ]; then
			task_title="$title"
		else
			task_title="Fixup: $title"
		fi
	else
		task_title="Review: $title"
	fi

	task_notes="[gitlab $project_path!$number]($web_url)"

elif [[ -n "$issue_iid" ]]; then
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
        set task_id to id of item 1 of task_list
        return task_id
    else
        return "no"
    end if
end tell
EOF
)"

auth_token="$(security find-generic-password -s "things-url-auth-token" -w 2>/dev/null || true)"

focus="$(get-current-focus 2>/dev/null || true)"
obs_running="$(pgrep -x OBS || true)"

if [ -n "${obs_running:-}" ]; then
	tag_param="&tags=Stream,Standup"
else
	tag_param="&tags=Standup"
fi

if [ "$task_id" != "no" ]; then
	open "things:///update?id=$task_id&when=today$tag_param&list-id=CvRfq3p4a5eY3u3Wd8uwQ5&auth-token=$auth_token&completed=false"
else
	open "things:///add?title=$(echo -n "$task_title" | jq -sRr @uri)&notes=$(echo -n "$task_notes" | jq -sRr @uri)&when=today$tag_param&list-id=CvRfq3p4a5eY3u3Wd8uwQ5&auth-token=$auth_token"
fi

echo "Added task"

osascript <<'EOF'
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

if [ "${1:-2}" -eq "1" ]; then
	username="joshika39"
	user_id="$(get_user_id_by_username "$username")"

	if [[ -n "$mr_iid" ]]; then
		echo "$project_path"
		glab mr checkout "$mr_iid" -R "$project_path"
		echo "Checked out !$number ($title)"

		glab api -X PUT "projects/$project_path_enc/merge_requests/$mr_iid" -f "reviewer_ids[]=$user_id"

	else
		glab api -X PUT "projects/$project_path_enc/issues/$issue_iid" -f "reviewer_ids[]=$user_id"
	fi
else
	echo "Just creating a task"
fi
