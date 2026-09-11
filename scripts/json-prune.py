#!/usr/bin/env python3
"""Strip every parameter a set carries at the file's own default, so a set holds only what it changes.

The Customizer writes EVERY parameter when it saves a set, so one save turns a two-line vessel
profile into a hundred lines of restated defaults. Run this after saving: a set comes back holding
only its deviations, which is the whole content of a profile. Writes in the Customizer's own layout
so a later save does not churn the file.

Takes the entry files as arguments and prunes the .json beside each.
"""

import json
import pathlib
import re
import sys


def scad_defaults(scad):
    """name -> default, parsed from `name = value;` above module dummy(), as Python values."""
    out, sec = {}, None
    for line in scad.read_text().split("\n"):
        if re.match(r"^\s*module\s+dummy\s*\(", line):
            break
        ms = re.match(r"^\s*/\*\s*\[(.+?)\]\s*\*/", line)
        if ms:
            sec = ms.group(1)
            continue
        m = re.match(r"^([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.+?)\s*;", line)
        if m and (sec or "").lower() != "hidden":
            out[m.group(1)] = m.group(2)
    return out


def same(json_value, scad_literal):
    """Whether a JSON string value restates a scad default. Numbers compare by value."""
    j = json_value.strip()
    s = scad_literal.strip()
    try:
        return abs(float(j) - float(s)) <= 1e-9 * max(1.0, abs(float(s)))
    except ValueError:
        pass
    return j.strip('"') == s.strip('"')


changed = 0
for scad in (pathlib.Path(a) for a in sys.argv[1:]):
    jpath = scad.with_suffix(".json")
    if not jpath.exists():
        continue
    defaults = scad_defaults(scad)
    data = json.loads(jpath.read_text())
    before = sum(len(b) for b in data["parameterSets"].values())
    for name, body in data["parameterSets"].items():
        for p in [p for p in body if p in defaults and same(body[p], defaults[p])]:
            del body[p]
    after = sum(len(b) for b in data["parameterSets"].values())
    out = {
        "fileFormatVersion": "1",
        "parameterSets": {
            k: dict(sorted(v.items())) for k, v in sorted(data["parameterSets"].items())
        },
    }
    jpath.write_text(json.dumps(out, indent=4) + "\n")
    print(
        f"{'pruned' if after < before else 'ok    '} {jpath}  {before} -> {after} overrides"
    )
    changed += before - after
