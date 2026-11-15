#!/usr/bin/env bash
#
# Install the OpenSCAD libraries scadman.lock pins into .scadman/env, which every recipe
# puts on OPENSCADPATH, so "it renders" is a property of the project. scadman checks each
# library against the content hash in the lock and refuses a lock that has fallen behind
# scadman.toml.
#
# scadman itself is pinned here, like the formatters in the justfile: on Linux x86_64 and
# macOS the release archive is fetched into .cache/ and checked against its published
# sha256. Elsewhere (Windows, other architectures) a scadman on PATH is used. Its store
# lives in .cache/ too, so setup runs the same on a bench, in CI and in a sandbox that
# cannot write the home directory. Idempotent.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCADMAN_VERSION=v0.1.0-alpha.6

# The sha256 of each release archive, from that release's checksums.txt.
case "$(uname -s)-$(uname -m)" in
Linux-x86_64)
    target=x86_64-unknown-linux-gnu
    sha256=17c65a0a7ab7d50eab510aec4f133c11c677f8e58e7f26ba6b462ffa49b18fb0
    ;;
Darwin-arm64)
    target=aarch64-apple-darwin
    sha256=34803c8d7d2c2875a5fdfd4021a35d21b05db4bb77a9f9663f6c15155bdc3af0
    ;;
Darwin-x86_64)
    target=x86_64-apple-darwin
    sha256=dedef33415fe1cbc7505c048c45132a89f8465688ab217e0249c2919a8b7a294
    ;;
*) target="" ;;
esac

if [ -n "$target" ]; then
    dir="$ROOT/.cache/scadman/$SCADMAN_VERSION"
    scadman="$dir/scadman"
    if [ ! -x "$scadman" ]; then
        archive="scadman-$SCADMAN_VERSION-$target.tar.gz"
        mkdir -p "$dir"
        curl -fsSL -o "$dir/$archive" \
            "https://github.com/CameronBrooks11/scadman/releases/download/$SCADMAN_VERSION/$archive"
        if ! echo "$sha256  $dir/$archive" | sha256sum -c --quiet - 2>/dev/null &&
            ! echo "$sha256  $dir/$archive" | shasum -a 256 -c --quiet - 2>/dev/null; then
            rm -f "$dir/$archive"
            echo "scadman $SCADMAN_VERSION: $archive does not match its published sha256" >&2
            exit 1
        fi
        tar -xzf "$dir/$archive" -C "$dir" scadman
        rm -f "$dir/$archive"
    fi
elif command -v scadman >/dev/null 2>&1; then
    scadman=scadman
    echo "using the scadman on PATH ($(scadman --version)); this repo pins $SCADMAN_VERSION" >&2
else
    echo "no scadman release for $(uname -s) $(uname -m) is pinned here, and none is on PATH." >&2
    echo "Install scadman $SCADMAN_VERSION (https://github.com/CameronBrooks11/scadman/releases)," >&2
    echo "or install the libraries in scadman.toml by hand (see the README)." >&2
    exit 1
fi

cd "$ROOT"
XDG_DATA_HOME="$ROOT/.cache/scadman-data" "$scadman" sync
echo "OPENSCADPATH=$ROOT/.scadman/env"
