#!/usr/bin/env python3
"""Fail when a just recipe has no description, or shows a sentence fragment as one.

`just` reads ONLY the comment line immediately above a recipe, exactly as the OpenSCAD
Customizer reads the line above a variable. A multi-line comment block therefore shows its
LAST line, which is usually the middle of a sentence: four recipes here once advertised
"clean while the thermocouple row named a part the model had replaced" and "or hiding one
that does".

Detecting a fragment by reading it is guesswork - the same trap check-customizer's TODO
records - so this checks STRUCTURE instead, and the rule is the one the file already follows:
the description must be the first line of its own block. Either the line above the recipe is
the only comment line, or the one above IT is a bare `#` separating the description from the
prose that explains it.

That is mechanical, has no false positives, and is satisfied by writing the description last
with a `#` above it - which is the fix in every case anyway.
"""

import pathlib
import re
import sys

RECIPE = re.compile(r"^([a-zA-Z_][a-zA-Z0-9_-]*)(\s+[^:]*)?:(\s|$)")

lines = pathlib.Path("justfile").read_text().split("\n")
bad = []
for i, line in enumerate(lines):
    m = RECIPE.match(line)
    if not m or line.startswith((" ", "\t")):
        continue
    name = m.group(1)
    if name.startswith(
        "_"
    ):  # private recipes are not listed, so they need no description
        continue
    above = lines[i - 1].strip() if i else ""
    if not above.startswith("#"):
        bad.append((i + 1, name, "no comment line above it"))
        continue
    text = above.lstrip("# ").strip()
    if not text:
        bad.append((i + 1, name, "the line above it is a bare #, so it shows nothing"))
        continue
    over = lines[i - 2].strip() if i > 1 else ""
    if over.startswith("#") and over != "#":
        bad.append((i + 1, name, f'shows a fragment: "{text[:44]}"'))

for ln, name, why in bad:
    print(f"FAIL  justfile:{ln}  {name}  {why}")
if bad:
    print("        put the description last in its block, with a bare # above it")
    sys.exit(1)
print("ok    every listed recipe shows a description, not a fragment")
