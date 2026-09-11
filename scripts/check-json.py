#!/usr/bin/env python3
"""Fail when a parameter-set file has drifted from the file it belongs to, or from the registries.

The JSON beside each entry file is AUTHORED, not generated: one set per registered vessel, carrying
only what that vessel's build changes from the file's defaults, and growing as a jar earns tweaks.
OpenSCAD applies a set on top of the file's defaults ("only the parameters defined in the dataset
are modified"), so a set can be as small as the vessel selector. This checks and never writes:

  - every registered vessel has a set in every entry file's JSON
  - every parameter a set names exists in that file's Customizer surface
  - every dropdown annotation that lists registry names still matches its registry

Reads the scad defaults the way check_customizer.py does, and takes the entry files as arguments.
"""

import json
import pathlib
import re
import subprocess
import sys

REPO = pathlib.Path(__file__).resolve().parent.parent
ENTRY = [pathlib.Path(a) for a in sys.argv[1:]]

# Dropdowns that list a registry's names, and whether they also offer "auto".
DESIGNATIONS = {
    "reactor_vessel_name": ("vessels", "vessel_name", False),
    "shaft_name": ("shafts", "shaft_name", True),
    "strip_light_name": ("strip_lights", "strip_light_name", True),
    "plug_oring_name": ("orings", "oring_name", True),
    "do_probe_name": ("atlas_probes", "atlas_probe_name", True),
    "ph_probe_name": ("atlas_probes", "atlas_probe_name", True),
    "gasket_sheet_name": ("gasket_sheets", "gasket_sheet_name", True),
    "motor_name": ("dc_motors", "dc_motor_name", True),
}


def registry_names():
    """Every registry's row names, read from the registries themselves."""
    pairs = sorted({(r, f) for r, f, _ in DESIGNATIONS.values()})
    src = "".join(f"include <{REPO}/scad/purchased/{r}.scad>\n" for r, _ in pairs)
    for reg, fn in pairs:
        src += f'for (x = {reg}) echo(str("N|{reg}|", {fn}(x)));\n'
    out = subprocess.run(
        ["openscad", "-o", "/dev/null", "--export-format", "csg", "/dev/stdin"],
        input=src,
        capture_output=True,
        text=True,
    ).stderr
    names = {}
    for m in re.finditer(r'ECHO: "N\|(\w+)\|(.*?)"', out):
        names.setdefault(m.group(1), []).append(m.group(2))
    return names


def customizer_params(scad):
    """name -> declaration line, for everything the Customizer would offer."""
    params, sec = {}, None
    for line in scad.read_text().split("\n"):
        if re.match(r"^\s*module\s+dummy\s*\(", line):
            break
        ms = re.match(r"^\s*/\*\s*\[(.+?)\]\s*\*/", line)
        if ms:
            sec = ms.group(1)
            continue
        m = re.match(r"^([A-Za-z_][A-Za-z0-9_]*)\s*=", line)
        if m and (sec or "").lower() != "hidden":
            params[m.group(1)] = line
    return params


failed = 0
names = registry_names()
vessels = names.get("vessels", [])
if not vessels:
    print("FAIL  could not read the vessel registry")
    sys.exit(1)

for scad in ENTRY:
    params = customizer_params(scad)

    for param, (reg, _, auto) in DESIGNATIONS.items():
        decl = params.get(param)
        if not decl or "[" not in decl:
            continue
        listed = {s.strip() for s in re.search(r"\[(.*)\]", decl).group(1).split(",")}
        want = set(names.get(reg, [])) | ({"auto"} if auto else set())
        if listed != want:
            print(f"FAIL  {scad}: the {param} dropdown does not match its registry")
            for x in sorted(want - listed):
                print(f"        missing  {x}")
            for x in sorted(listed - want):
                print(f"        extra    {x}")
            failed = 1

    jpath = scad.with_suffix(".json")
    if not jpath.exists():
        print(f"FAIL  {jpath} is missing; every entry file carries one set per vessel")
        failed = 1
        continue
    sets = json.loads(jpath.read_text()).get("parameterSets", {})
    for v in vessels:
        if v not in sets:
            print(f"FAIL  {jpath}: no parameter set for {v}")
            failed = 1
    for name, body in sets.items():
        for p in body:
            if p not in params:
                print(
                    f"FAIL  {jpath}: set {name} names {p}, which {scad.name} does not offer"
                )
                failed = 1
    if not failed:
        print(
            f"ok    {jpath}  {len(sets)} sets, {sum(len(b) for b in sets.values())} overrides"
        )

sys.exit(failed)
