#!/bin/bash
set -euo pipefail

app="$1"
if [[ -e "$app/Contents/Library/LaunchDaemons/com.shariq.sapphireHelper.plist" || -e "$app/Contents/MacOS/com.shariq.sapphireHelper" ]]; then
  echo "FAIL: community package still contains the privileged helper" >&2
  exit 1
fi
echo "PASS: community package contains no privileged helper"
