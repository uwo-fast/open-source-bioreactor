# Sourced, not run. Stop unless $OPENSCAD is at least OPENSCAD_MIN and can render a cube, and
# print the binary and version that every later result comes from.
#
# A check that treats "no ERROR on stderr" or "no probe lines" as a pass also passes on a binary
# that renders nothing: one that is missing, crashes, or is an AppImage that cannot mount. So a
# script that gates on the absence of output first renders something known. It does not rely on
# $? alone: a failing export still exits 0, so the size of the output file is the signal.

# The oldest OpenSCAD supported here, 2021.01 from apt. Below it, the assumptions the checks make
# (the echo format, -D crossing a use boundary) are untested.
OPENSCAD_MIN=2021.01

openscad_canary() {
    local dir size ver
    ver=$("$OPENSCAD" --version 2>&1 | sed -n 's/^OpenSCAD version //p' | head -1)
    if [ -z "$ver" ]; then
        echo "FAIL  $OPENSCAD did not say its version, so whether it is at least $OPENSCAD_MIN is unknown"
        exit 1
    fi
    if [ "$(printf '%s\n%s\n' "$OPENSCAD_MIN" "$ver" | sort -V | head -1)" != "$OPENSCAD_MIN" ]; then
        echo "FAIL  $OPENSCAD is OpenSCAD $ver, older than $OPENSCAD_MIN, the oldest this repo supports"
        exit 1
    fi
    dir=$(mktemp -d)
    echo 'cube(1);' >"$dir/c.scad"
    "$OPENSCAD" -o "$dir/c.stl" "$dir/c.scad" >/dev/null 2>"$dir/err"
    size=$(stat -c%s "$dir/c.stl" 2>/dev/null || echo 0)
    if [ "$size" -le 84 ]; then # 84 bytes is an empty binary STL
        echo "FAIL  $OPENSCAD cannot render a cube, so nothing here would be tested"
        head -3 "$dir/err" | sed 's/^/        /'
        rm -rf "$dir"
        exit 1
    fi
    rm -rf "$dir"
    echo "note  $OPENSCAD is OpenSCAD $ver"
}
