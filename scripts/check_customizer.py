#!/usr/bin/env python3
"""Fail when a Customizer parameter has no description the UI can actually show.

OpenSCAD reads ONLY the line immediately above a variable. A multi-line comment block shows
its last line, and a trailing comment shows nothing at all - so 46 parameters across the three
entry files offered the previous LINE OF CODE as their help text, render_base advising the
reader that "render_all = true; // render all components". Prose is not checked by `just json`
the way the dropdowns are, so nothing but this stops the next parameter being as silent.

A parameter under /* [Hidden] */ is exempt: it is not offered, so it needs no description. That
section runs until the NEXT marker, which is the trap this also covers - hiding one internal hid
every render flag below it once, because head.scad had no marker between them.

Takes the entry files to check as arguments; the justfile holds the list.
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
