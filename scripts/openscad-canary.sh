# Sourced, not run: refuse to go on unless $OPENSCAD can render a cube.
#
# A check that reads "no ERROR on stderr" or "no probe lines" as a pass passes on a binary that
# renders nothing at all: missing, crashing, or an AppImage that cannot mount. So a script that
# gates on the absence of output renders something known first. Not on $? alone: a failing export
# still exits 0, so the file's size is the signal.
openscad_canary() {
    local dir size
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
}
