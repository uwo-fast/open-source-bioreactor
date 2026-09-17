#!/usr/bin/env python3
"""Fail when a Customizer parameter has no description the UI can actually show.

OpenSCAD reads only the line immediately above a variable, so a multi-line block shows its last
line and a trailing comment shows nothing. A parameter under /* [Hidden] */ is exempt; that
section runs until the next marker, so a bare marker is checked too.

Takes the entry files to check as arguments.
"""

import pathlib
import re
import sys

failed = 0
for path in sys.argv[1:]:
    lines = pathlib.Path(path).read_text().split("\n")
    sec, bad, bare, offered, hidden = None, [], [], 0, 0
    for i, line in enumerate(lines):
        if re.match(r"^\s*module\s+dummy\s*\(", line):
            break
        ms = re.match(r"^\s*/\*\s*\[(.+?)\]\s*\*/", line)
        if ms:
            sec = ms.group(1)
            # A [Hidden] marker must say WHY. It runs to the next marker, so a bare one can
            # swallow a whole section - one here hid 17 sparger parameters unremarked, and a
            # reader with no reason in front of them deletes it and offers all seventeen.
            prev_is_comment = lines[i - 1].strip().startswith("//") if i else False
            if sec.lower() == "hidden" and not prev_is_comment:
                bare.append(i + 1)
            continue
        # $-prefixed names are OpenSCAD SPECIAL variables. The customizer does not offer them,
        # so they are not parameters and want no description - $fn and $bayonet_shell_only alike.
        m = re.match(r"^([A-Za-z_][A-Za-z0-9_]*)\s*=", line)
        if not m:
            continue
        if (sec or "").lower() == "hidden":
            hidden += 1
            continue
        offered += 1
        prev = lines[i - 1].strip() if i else ""
        if not prev.startswith("//"):
            bad.append((i + 1, m.group(1), prev[:46] or "(blank)"))
    if bare:
        print(
            f"FAIL  {path}  {len(bare)} [Hidden] marker(s) with no comment saying why"
        )
        for ln in bare:
            print(
                f"        :{ln} a bare [Hidden] runs to the next marker - say what it hides"
            )
        failed = 1
    if bad:
        print(
            f"FAIL  {path}  {len(bad)} of {offered} offered parameters have no description"
        )
        for ln, name, shows in bad[:6]:
            print(f"        :{ln} {name} would show: {shows}")
        failed = 1
    else:
        print("ok    %-46s %d offered, %d hidden" % (path, offered, hidden))
sys.exit(failed)
