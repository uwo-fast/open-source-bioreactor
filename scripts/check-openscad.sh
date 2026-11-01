#!/usr/bin/env bash
#
# Fail unless $OPENSCAD is at least the version this repo is checked on and renders a cube, and
# say which binary and version the recipes after it ran on. First in `check` and `test`, since
# just runs whichever openscad is first on PATH unless OPENSCAD names one.
set -uo pipefail
: "${OPENSCAD:=openscad}"
source "$(dirname "$0")/openscad-canary.sh"
openscad_canary
