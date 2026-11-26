#!/usr/bin/env bash
#
# Export every printed part as its own STL, with a print list.
#
# Given a build in $1 (a parameter set in scad/bioreactor.json), it writes that build flat to
# $2/<build> (output/ by default). $3 names a single part to write, with no print list.
#
# Without a build, it writes every registered build, grouped by vessel, to $2/<vessel> (build/ by
# default). common/ holds the parts that every build of that vessel prints the same, and one
# folder per build type (stirred, magnetic, airlift) holds only what that type adds. A part is
# common when every build of the vessel has it with the same geometry, compared by its CSG, and
# it does not belong to one drive only. Each distinct part renders once. The folder for a vessel
# is replaced as a whole, so its contents always match what the model prints now.
#
# The renders run JOBS at a time (every core unless set). Each is one OpenSCAD process on one
# core, and the lid alone takes a minute and a half, so the whole run takes about as long as the
# lid.
#
: "${OPENSCAD:=openscad}"
: "${JOBS:=$(nproc)}"

# A failing render still exits 0 and writes a small file, as in check-mesh, so nothing here may
# be gated on $?. stderr is the signal, and the file size is the fallback.
set -uo pipefail
# the printed parts are only as good as the binary that rendered them, so print which binary is
# used and reject an old one
source "$(dirname "$0")/openscad-canary.sh"
openscad_canary
tmp=$(mktemp -d) && trap 'rm -rf "$tmp"' EXIT

build="${1:-}"
only="${3:-}"
# The number of coincident faces a part may have before it counts as a defect rather than a
# tangency.
#
# Two solids that touch on exactly one plane leave the whole shared face, which is tens or
# hundreds of edges: the socket taper on sparge_arm left 202, the impeller collar 124, and the
# probe tilt wedge 43. A curve meeting a surface at a point leaves one or two, and the rounding
# that decides this depends on the machine: the same part measures 0 here and 1 on a different
# CGAL build. Counting those exactly would make the result depend on the host. A ceiling well
# clear of both ranges makes it depend only on the project.
: "${SEAM_CEILING:=10}"
export OPENSCAD JOBS SEAM_CEILING tmp

# shellcheck source=scripts/export-lib.sh
source "$(dirname "$0")/export-lib.sh"
failed=0

# ----- one build, flat -----

if [ -n "$build" ] || [ -n "$only" ]; then
    # A string, not an array, because the render below runs in a child shell and an array cannot
    # be exported. Set names are identifiers, so word splitting is safe.
    sel=""
    if [ -n "$build" ]; then
        # OpenSCAD ignores a -P that names a nonexistent set and silently falls back to the file
        # defaults, which would write a directory named for one build but containing the parts
        # of another. So the set is looked up first.
        if ! /usr/bin/python3 -c 'import json,sys; sys.exit(sys.argv[2] not in json.load(open(sys.argv[1]))["parameterSets"])' scad/bioreactor.json "$build"; then
            echo "FAIL  no parameter set is named $build in scad/bioreactor.json"
            exit 1
        fi
        sel="-p scad/bioreactor.json -P $build"
    fi

    # Get the printed parts from the model, through the assembly, which contains both halves.
    # The stub has render_all off, so it takes about a second. Each row names its half.
    if ! export_manifest "$sel" "$tmp/m"; then
        echo "FAIL  ${build:-the default build} does not resolve, so there is nothing to export"
        grep -m1 '^ERROR' "$tmp/m.err" | sed 's/^/        /'
        exit 1
    fi
    # The build description echoed by the model: the vessel, the drive and every designation set
    # explicitly rather than left at auto. It is printed and written into the list, because an
    # STL of a g1 collet and one of a g2 collet look identical in a directory listing.
    stated=$(cat "$tmp/m.stated")
    echo "note  $stated"
    rows=$(cat "$tmp/m.rows")
    if [ -z "$rows" ]; then echo "FAIL  the model lists no printed parts"; exit 1; fi
    if [ -n "$only" ]; then
        rows=$(grep "|$only|" <<< "$rows" || true)
        if [ -z "$rows" ]; then
            echo "FAIL  no part is named $only in this build; the print list names them"
            exit 1
        fi
    fi

    label="${build:-default}"
    dir="${2:-output}/$label"
    mkdir -p "$dir"
    : > "$tmp/rows.md"; : > "$tmp/sizes"
    pieces=0
    parts=0

    while IFS='|' read -r file name _ flags; do
        [ -n "$name" ] && printf '%s|%s|%s|%s|%s\n' "$sel" "$file" "$flags" "$dir/$name.stl" "$tmp/$name.err"
    done <<< "$rows" > "$tmp/jobs"
    export_render "$tmp/jobs"

    # Then check each part, in manifest order, from the output of its render.
    while IFS='|' read -r file name qty flags; do
        [ -z "$name" ] && continue
        parts=$((parts + 1))
        pieces=$((pieces + qty))
        export_judge "$name" "$qty" "$dir/$name.stl" "$tmp/rows.md" "$tmp/sizes" "$tmp/$name.err"
    done <<< "$rows"

    # A single part is exported for inspection only; the print list covers the whole build.
    if [ -n "$only" ]; then exit $failed; fi

    allfit=$(export_fits "$tmp/sizes" "$sel" "$tmp/nofit")
    while read -r m; do
        [ -n "$m" ] && { echo "FAIL  $m  fits no registered printer at all - see scad/purchased/printers.scad"; failed=1; }
    done < "$tmp/nofit"
    [ -n "$allfit" ] && echo "ok    every exported part fits: $allfit"

    { echo "# Print list — $label"
      echo
      echo "$pieces pieces, $parts distinct parts. Written by \`just export-parts\`; the model is the"
      echo "authority and this is a transcript of it, so regenerate rather than editing."
      echo
      echo "**\`$stated\`** — the model's own statement of what this is. A part whose designation"
      echo "differs from this list's is a different part, whatever its file is called."
      echo
      export_list_body "$allfit" "$tmp/rows.md" "../.."
    } > "$dir/print-list.md"

    echo "ok    $dir/print-list.md  ($pieces pieces, $parts parts)"
    exit $failed
fi

# ----- every registered build, by vessel -----

out="${2:-build}"
mkdir -p "$out"
# Before anything is removed, the root of the replaced folders must exist, be a real directory
# and be inside the repository, but not be the repository itself.
root=$(realpath -e "$out") || { echo "FAIL  $out is not a directory"; exit 1; }
repo=$(realpath -e .)
if [ -L "$out" ] || [ "$root" = "$repo" ] || [ "${root#"$repo"/}" = "$root" ]; then
    echo "FAIL  $out has to be a real directory inside the repository, not the repository itself"
    exit 1
fi

# Get the print list of each build under its own drive and under the other two. This shows
# whether a part belongs to one drive only, rather than simply being absent from another build of
# the same vessel.
/usr/bin/python3 - "$tmp" <<'PY'
import json, sys
tmp = sys.argv[1]
sets = json.load(open("scad/bioreactor.json"))["parameterSets"]
jobs, variants = [], {}
for name, params in sets.items():
    for drive in ("shaft", "magnetic", "airlift"):
        variants[f"{name}__{drive}"] = dict(params, drive_name=drive)
        jobs.append(f"{name}|{drive}")
json.dump({"fileFormatVersion": "1", "parameterSets": variants}, open(f"{tmp}/variants.json", "w"))
open(f"{tmp}/sets", "w").write("\n".join(sets) + "\n")
open(f"{tmp}/manifest-jobs", "w").write("\n".join(jobs) + "\n")
PY
export_manifest_job() {
    local set drive
    IFS='|' read -r set drive <<< "$1"
    export_manifest "-p $tmp/variants.json -P ${set}__$drive" "$tmp/man.$set.$drive" || true
    # the build as registered, once per set; the shaft job is used for this, though any would do
    if [ "$drive" = shaft ]; then
        export_manifest "-p scad/bioreactor.json -P $set" "$tmp/man.$set" || echo unresolved > "$tmp/man.$set.bad"
    fi
}
export -f export_manifest export_manifest_job export_defines
xargs -d '\n' -P "$JOBS" -I{} bash -c 'export_manifest_job "$1"' _ {} < "$tmp/manifest-jobs"

while read -r set; do
    if [ -f "$tmp/man.$set.bad" ]; then
        echo "FAIL  $set does not resolve, so there is nothing to export"
        grep -m1 '^ERROR' "$tmp/man.$set.err" | sed 's/^/        /'
        failed=1
    fi
done < "$tmp/sets"
[ $failed -eq 0 ] || exit 1

# Render every part of every build as CSG, which is fast and shows whether two builds print the
# same part.
mkdir -p "$tmp/csg"
while read -r set; do
    while IFS='|' read -r file name _ flags; do
        printf '%s|%s|%s|%s|%s\n' "-p scad/bioreactor.json -P $set" "$file" "$flags" "$tmp/csg/$set.$name.csg" "$tmp/csg/$set.$name.err"
    done < "$tmp/man.$set.rows"
done < "$tmp/sets" > "$tmp/csg-jobs"
export_render "$tmp/csg-jobs"
: > "$tmp/keys"
while read -r set; do
    while IFS='|' read -r _ name _ _; do
        # a CSG that failed to render cannot match a part of another build, so it is never common
        if grep -q '^ERROR' "$tmp/csg/$set.$name.err" || [ ! -s "$tmp/csg/$set.$name.csg" ]; then
            echo "$set|$name|unrendered-$set" >> "$tmp/keys"
        else
            echo "$set|$name|$(export_csg_key "$tmp/csg/$set.$name.csg")" >> "$tmp/keys"
        fi
    done < "$tmp/man.$set.rows"
done < "$tmp/sets"

# The plan: where each part goes, and which render is used for it. One line per destination:
# key|set|file|name|qty|flags|vessel/folder. The lists file gives the folders for each vessel and
# the builds each folder serves.
/usr/bin/python3 - "$tmp" <<'PY'
import collections, re, sys
tmp = sys.argv[1]
TYPES = {"shaft": "stirred", "magnetic": "magnetic", "airlift": "airlift"}
sets = open(f"{tmp}/sets").read().split()
keys = {}
for line in open(f"{tmp}/keys"):
    s, n, k = line.rstrip("\n").split("|")
    keys[(s, n)] = k

def rows(path):
    try:
        return [(f, n, int(q), fl) for f, n, q, fl in (l.rstrip("\n").split("|", 3) for l in open(path) if l.strip())]
    except FileNotFoundError:
        return []

builds = {}
for s in sets:
    stated = open(f"{tmp}/man.{s}.stated").read().strip()
    m = re.match(r"build: ([^,]+), (\w+) drive", stated)
    if not m:
        sys.exit(f"cannot read the vessel and drive of {s} from: {stated!r}")
    vessel, drive = m.group(1), m.group(2)
    by_drive = {d: {r[1] for r in rows(f"{tmp}/man.{s}.{d}.rows")} for d in TYPES}
    own = {n for n in by_drive[drive] if all(n not in by_drive[d] for d in TYPES if d != drive)}
    builds[s] = dict(vessel=vessel, drive=drive, stated=stated, rows=rows(f"{tmp}/man.{s}.rows"), own=own)

by_vessel = collections.defaultdict(list)
for s in sets:
    by_vessel[builds[s]["vessel"]].append(s)

plan, lists = [], []
for vessel, members in by_vessel.items():
    # two builds of one vessel on one drive cannot share a type's name, so they take their own
    drives = collections.Counter(builds[s]["drive"] for s in members)
    kind = {s: TYPES[builds[s]["drive"]] if drives[builds[s]["drive"]] == 1 else s for s in members}
    names = []
    for s in members:
        names += [r[1] for r in builds[s]["rows"] if r[1] not in names]
    for n in names:
        having = [s for s in members if any(r[1] == n for r in builds[s]["rows"])]
        row = {s: next(r for r in builds[s]["rows"] if r[1] == n) for s in having}
        common = (
            len(having) == len(members)
            and len({keys[(s, n)] for s in having}) == 1
            and len({row[s][2] for s in having}) == 1
            and not any(n in builds[s]["own"] for s in having)
        )
        for s in (having[:1] if common else having):
            f, _, q, flags = row[s]
            dest = f"{vessel}/common" if common else f"{vessel}/{kind[s]}"
            plan.append("|".join([keys[(s, n)], s, f, n, str(q), flags, dest]))
    lists.append("|".join([vessel, "common", ",".join(f"{kind[s]}={s}" for s in members)]))
    lists += ["|".join([vessel, kind[s], s]) for s in members]
open(f"{tmp}/plan", "w").write("\n".join(plan) + "\n")
open(f"{tmp}/lists", "w").write("\n".join(lists) + "\n")
for s in sets:
    open(f"{tmp}/stated.{s}", "w").write(builds[s]["stated"])
PY
[ -s "$tmp/plan" ] || { echo "FAIL  no export plan came out of the builds' print lists"; exit 1; }

# One render per distinct part, then a copy to each destination.
mkdir -p "$tmp/stl"
awk -F'|' '!seen[$1 FS $4]++' "$tmp/plan" | while IFS='|' read -r key set file name _ flags _; do
    printf '%s|%s|%s|%s|%s\n' "-p scad/bioreactor.json -P $set" "$file" "$flags" "$tmp/stl/${key:0:16}.$name.stl" "$tmp/stl/${key:0:16}.$name.err"
done > "$tmp/stl-jobs"
echo "note  $(wc -l < "$tmp/plan") parts across $(wc -l < "$tmp/sets") builds, $(wc -l < "$tmp/stl-jobs") distinct renders"
export_render "$tmp/stl-jobs"

# Stage the folder for each vessel next to the one it replaces, and copy each part into place.
declare -A stage
for vessel in $(cut -d'|' -f1 "$tmp/lists" | sort -u); do
    stage[$vessel]=$(mktemp -d "$root/.staging-$vessel.XXXX")
done
while IFS='|' read -r key _ _ name _ _ dest; do
    vessel="${dest%%/*}"; kind="${dest#*/}"
    mkdir -p "${stage[$vessel]}/$kind"
    cp "$tmp/stl/${key:0:16}.$name.stl" "${stage[$vessel]}/$kind/$name.stl" 2>/dev/null
    cp "$tmp/stl/${key:0:16}.$name.err" "$tmp/err.$vessel.$kind.$name" 2>/dev/null \
        || echo "no render flags known" > "$tmp/err.$vessel.$kind.$name"
done < "$tmp/plan"

# Check each part in its destination and write the print list for each folder. common comes first
# in the lists file, so its sizes are available when the printers for a build type are computed.
while IFS='|' read -r vessel kind who; do
    d="${stage[$vessel]}/$kind"
    mkdir -p "$d"
    echo "== $vessel/$kind"
    : > "$tmp/rows.md"; : > "$tmp/sizes.$vessel.$kind"
    pieces=0; parts=0
    while IFS='|' read -r _ _ _ name qty _ dest; do
        [ "$dest" = "$vessel/$kind" ] || continue
        parts=$((parts + 1)); pieces=$((pieces + qty))
        export_judge "$name" "$qty" "$d/$name.stl" "$tmp/rows.md" "$tmp/sizes.$vessel.$kind" "$tmp/err.$vessel.$kind.$name"
    done < "$tmp/plan"
    if [ "$kind" = common ]; then
        first="${who%%,*}"
        sel="-p scad/bioreactor.json -P ${first#*=}"
        sizes="$tmp/sizes.$vessel.common"
    else
        # the printers for a type must also fit common/, since both are printed for that build
        cat "$tmp/sizes.$vessel.common" "$tmp/sizes.$vessel.$kind" > "$tmp/sizes.$vessel.$kind.all"
        sel="-p scad/bioreactor.json -P $who"
        sizes="$tmp/sizes.$vessel.$kind.all"
    fi
    allfit=$(export_fits "$sizes" "$sel" "$tmp/nofit")
    while read -r m; do
        [ -n "$m" ] && { echo "FAIL  $m  fits no registered printer at all - see scad/purchased/printers.scad"; failed=1; }
    done < "$tmp/nofit"
    {
        if [ "$kind" = common ]; then
            echo "# Print list — $vessel, common to every build"
            echo
            echo "$pieces pieces, $parts distinct parts. Written by \`just export-parts\`; the model is the"
            echo "authority and this is a transcript of it, so regenerate rather than editing."
            echo
            echo "Every registered build of this vessel prints these the same. Print them once, then add"
            echo "the folder for the build you are making:"
            echo
            for pair in ${who//,/ }; do
                echo "- [\`${pair%%=*}/\`](../${pair%%=*}/print-list.md) - **\`$(cat "$tmp/stated.${pair#*=}")\`** (\`${pair#*=}\`)"
            done
        else
            echo "# Print list — $vessel, $kind"
            echo
            echo "$pieces pieces, $parts distinct parts, printed with everything in [\`common/\`](../common/print-list.md)."
            echo "Written by \`just export-parts\`; the model is the authority and this is a transcript of it,"
            echo "so regenerate rather than editing."
            echo
            echo "**\`$(cat "$tmp/stated.$who")\`** (\`$who\`) — the model's own statement of this build."
            echo "What this folder adds to \`common/\` is what makes it this build rather than another."
        fi
        echo
        export_list_body "$allfit" "$tmp/rows.md" "../../.."
    } > "$d/print-list.md"
    echo "ok    $vessel/$kind  ($pieces pieces, $parts parts)"
done < "$tmp/lists"

# Replace each old folder with the staged one. The target is the checked root plus a vessel name,
# which must be an identifier. A symlink at the target is refused rather than followed.
for vessel in "${!stage[@]}"; do
    target="$root/$vessel"
    if ! [[ "$vessel" =~ ^[A-Za-z0-9_]+$ ]] || [ -L "$target" ]; then
        echo "FAIL  refusing to replace $target"; failed=1; continue
    fi
    [ -d "$target" ] && rm -rf -- "$target"
    mv -- "${stage[$vessel]}" "$target"
done
echo "ok    $out/  ($(wc -l < "$tmp/sets") builds, ${#stage[@]} vessels)"
exit $failed
