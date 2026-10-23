#!/usr/bin/env bash
set -euo pipefail
[[ $GITHUB_SHA =~ ^[0-9a-f]{40}$ ]] || exit 2
[[ -s dist/index.html ]] || { echo 'Built landing page is missing'; exit 1; }
if find dist -type l -print -quit | grep -q .; then
  echo 'Symlinks are not allowed in the static build'; exit 1
fi
umask 077
key_dir=$(mktemp -d)
trap 'rm -rf "$key_dir"' EXIT
printf '%s\n' "$DEPLOY_SSH_KEY" > "$key_dir/key"
printf '%s\n' "$DEPLOY_KNOWN_HOSTS" > "$key_dir/known_hosts"
export RSYNC_RSH="ssh -i $key_dir/key -o IdentitiesOnly=yes -o BatchMode=yes -o StrictHostKeyChecking=yes -o UserKnownHostsFile=$key_dir/known_hosts -o ConnectTimeout=15"
# The forced command confines the remote receiver to the landing directory.
rsync -rtzp --delete-delay --delay-updates --chmod=D755,F644 dist/ crmapp@82.146.57.196:./
python3 deploy/smoke.py "$GITHUB_SHA"
