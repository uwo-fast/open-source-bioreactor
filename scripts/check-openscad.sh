#!/usr/bin/env bash
#
# Fail unless $OPENSCAD is at least the oldest version this repo supports and can render a cube,
# and print the binary and version the following recipes use. It runs first in `check` and
# `test`, because just runs the first openscad on PATH unless OPENSCAD names one.
set -uo pipefail
: "${OPENSCAD:=openscad}"
source "$(dirname "$0")/openscad-canary.sh"
openscad_canary
