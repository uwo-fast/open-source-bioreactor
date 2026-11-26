#!/usr/bin/env bash
#
# Install the OpenSCAD libraries pinned in scadman.lock into .scadman/env, which every recipe
# puts on OPENSCADPATH, so whether a file renders depends only on the project. scadman checks
# each library against the content hash in the lock, and rejects a lock that is out of date
# with scadman.toml.
#
# scadman itself is pinned here, like the formatters in the justfile. On Linux x86_64 and
# macOS the release archive is downloaded into .cache/ and checked against its published
# sha256. Elsewhere (Windows, other architectures) a scadman on PATH is used. Its store is
# also in .cache/, so setup behaves the same on a bench machine, in CI and in a sandbox that
# cannot write to the home directory. Idempotent.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCADMAN_VERSION=v0.1.0-alpha.9

# The sha256 of each release archive, from that release's checksums.txt.
case "$(uname -s)-$(uname -m)" in
Linux-x86_64)
    target=x86_64-unknown-linux-gnu
    sha256=130704c73406ac9193cbfdc4c99a3a68b82426a7399d0d86df094c48bcfaf03f
    ;;
Darwin-arm64)
    target=aarch64-apple-darwin
    sha256=9443597d905cfcc4043ad94e213b6bf85fa1ff7f7343e26dbe23eb5f01be47cf
    ;;
Darwin-x86_64)
    target=x86_64-apple-darwin
    sha256=faba979905330e66ecfb74beba0eb9de1b0ace91d45c5f4c1987facddd8554f1
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
