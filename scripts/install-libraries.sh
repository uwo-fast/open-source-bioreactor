#!/usr/bin/env bash
#
# Install the OpenSCAD libraries openscad-libraries.txt pins, into a directory inside the
# repository, so "it renders" is a property of the project. SSH first (BatchMode, short
# timeout), HTTPS second, from one line in the list. Idempotent.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LIST="$ROOT/openscad-libraries.txt"
DEST="$ROOT/.openscad-libraries"

[ -f "$LIST" ] || { echo "no $LIST" >&2; exit 1; }
mkdir -p "$DEST"

# BatchMode so a missing key fails instead of prompting; accept-new so a first
# contact with github.com does not need an interactive yes.
export GIT_SSH_COMMAND="${GIT_SSH_COMMAND:-ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=5}"
export GIT_TERMINAL_PROMPT=0

# https://host/owner/repo.git -> git@host:owner/repo.git
ssh_url_for() { printf '%s' "$1" | sed -E 's#^https://([^/]+)/#git@\1:#'; }

failed=0
while read -r name url ref; do
    case "$name" in ''|\#*) continue ;; esac
    dir="$DEST/$name"

    if [ -d "$dir/.git" ]; then
        # Already the pinned revision? Then there is nothing to do. Compare
        # resolved SHAs so a tag and its commit are recognised as the same thing.
        have=$(git -C "$dir" rev-parse HEAD 2>/dev/null || echo none)
        want=$(git -C "$dir" rev-parse "$ref^{commit}" 2>/dev/null || echo unknown)
        if [ "$have" = "$want" ]; then
            printf 'ok    %-20s %s\n' "$name" "$ref"
            continue
        fi
        git -C "$dir" fetch --quiet --tags origin || true
    else
        rm -rf "$dir"
        # blob:none keeps the clone small while leaving every ref reachable, so
        # a pinned SHA can be checked out without a full history download.
        if ! git clone --quiet --filter=blob:none "$(ssh_url_for "$url")" "$dir" 2>/dev/null; then
            if ! git clone --quiet --filter=blob:none "$url" "$dir"; then
                printf 'FAIL  %-20s could not clone over SSH or HTTPS\n' "$name"
                failed=1
                continue
            fi
            via=https
        fi
    fi

    if ! git -C "$dir" checkout --quiet --detach "$ref" 2>/dev/null; then
        printf 'FAIL  %-20s no such ref: %s\n' "$name" "$ref"
        failed=1
        continue
    fi
    printf 'ok    %-20s %s (%s)\n' "$name" "$ref" "${via:-ssh}"
    unset via
done < "$LIST"

[ $failed -eq 0 ] || { echo "some libraries did not install" >&2; exit 1; }
echo "OPENSCADPATH=$DEST"
