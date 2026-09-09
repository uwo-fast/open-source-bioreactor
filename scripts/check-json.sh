#!/usr/bin/env bash
#
# Fail when the committed parameter JSON has drifted from the registries.
#
: "${OPENSCAD:=openscad}"

set -uo pipefail
before=$(cat scad/assembly.json scad/head.json scad/frame.json 2>/dev/null || true)
just json > /dev/null || { echo "FAIL  the dropdowns have drifted - run just json"; exit 1; }
if [ "$before" != "$(cat scad/assembly.json scad/head.json scad/frame.json)" ]; then
    echo "FAIL  parameter files were stale - run just json and commit the result"; exit 1
fi
echo "ok    parameter files match the registry"
