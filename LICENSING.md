# Licensing

This document states which licence covers which parts of this repository, and
explains what that means. [What applies where](#what-applies-where) is the operative
section — it is how these files are made available. The commentary around it is for
convenience; the binding terms are the full texts in [`LICENSES/`](LICENSES/).

- **The design and its software** — GNU General Public License v3.0 or later
  (`GPL-3.0-or-later`) — [`LICENSES/GPL-3.0-or-later.txt`](LICENSES/GPL-3.0-or-later.txt)
- **Research data** — Creative Commons Attribution 4.0 International (`CC-BY-4.0`) —
  [`LICENSES/CC-BY-4.0.txt`](LICENSES/CC-BY-4.0.txt)

The root [`LICENSE`](LICENSE) is a copy of the GPL text. GitHub reports only one
licence per repository and reads that file, so this document is where the full
picture lives.

## What applies where

| Path                                                                                            | Licence            |
| ----------------------------------------------------------------------------------------------- | ------------------ |
| `scad/` — parametric CAD source                                                                 | `GPL-3.0-or-later` |
| `printing/` — print-ready geometry (3MF)                                                        | `GPL-3.0-or-later` |
| `purchased-parts.csv`, `purchased-parts_1p5L_legacy.csv` — bills of materials                   | `GPL-3.0-or-later` |
| `analysis/` — the pipelines, `pyproject.toml` and the READMEs                                   | `GPL-3.0-or-later` |
| `analysis/runs/*/raw/`, `analysis/methods/*/raw/` — measurement data                            | `CC-BY-4.0`        |
| `analysis/runs/*/figures/`, `analysis/methods/*/figures/` — plots of that data                  | `CC-BY-4.0`        |
| `scripts/`, `tests/`, `justfile`, `openscad-libraries.txt`, `.github/`, and other build tooling | `GPL-3.0-or-later` |
| `docs/`, including the drawing `docs/ports_layout.drawio`                                       | `GPL-3.0-or-later` |
| `README.md`, `TODO.md`                                                                          | `GPL-3.0-or-later` |

Add a row to the table above for each new top-level directory.

**Why the hardware is GPL, not CERN-OHL-S.** The
[organization policy](https://github.com/uwo-fast/.github/blob/main/LICENSING.md)
licenses hardware design files `CERN-OHL-S-2.0` where it can. It cannot here: the
parametric source includes GPL-licensed libraries — NopSCADlib, and through the
sampler, turbidity-sensor's probe library — and GPL-3.0 is not a Compatible Licence
under CERN-OHL-S-2.0 §1.2, so the whole-work licensing its §3.3(d) requires cannot be
granted over source entangled with them. The whole design chain is therefore
`GPL-3.0-or-later`: source, geometry, drawings and bills of materials alike. That
gives up CERN-OHL-S's hardware-specific reciprocity, not openness. If that
reciprocity is ever wanted, the route is removing the GPL libraries from the export
path, not relabelling the licence.

**Documentation** is `GPL-3.0-or-later` throughout: every document here documents
the design or the tooling that builds it.

## Third-party components

Anything included keeps its own licence, unaffected by this document. None of these
is vendored: `just setup` fetches each at the revision `openscad-libraries.txt` pins.

| Component                                                                                      | Licence                                                                     |
| ---------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------- |
| [NopSCADlib](https://github.com/nophead/NopSCADlib)                                            | `GPL-3.0-or-later`                                                          |
| [bayonet-lock-scad](https://github.com/CameronBrooks11/bayonet-lock-scad)                      | `MIT`                                                                       |
| [FunctionalOpenSCAD](https://github.com/thehans/FunctionalOpenSCAD)                            | `MIT`                                                                       |
| [threads-scad](https://github.com/rcolyer/threads-scad)                                        | `CC0-1.0`                                                                   |
| [din168-thread-scad](https://github.com/CameronBrooks11/din168-thread-scad)                    | `MIT`                                                                       |
| [turbidity-sensor](https://github.com/uwo-fast/turbidity-sensor) — `hardware/probe/probe.scad` | `GPL-3.0-or-later` and `CERN-OHL-S-2.0`, used here under `GPL-3.0-or-later` |
| [syringe-actuator](https://github.com/uwo-fast/syringe-actuator) — `cad/main.scad`             | `GPL-3.0-or-later` and `CERN-OHL-S-2.0`, used here under `GPL-3.0-or-later` |

## Contributions

"Contribution" means any work of authorship intentionally submitted for inclusion
in this project — a pull request, patch, commit, issue, or other communication —
excluding anything conspicuously marked "Not a Contribution".

Unless you state otherwise, contributions you submit are licensed under whichever
of the licences above covers the files they touch, with no additional terms. By
submitting a contribution you represent that you have the right to license it on
those terms.

## Patents

GPL-3.0 (section 11) contains express patent provisions. Review them before using,
modifying, or distributing this project.

## Disclaimer of warranty and liability

A summary of terms in the licences themselves — GPL-3.0 sections 15–17 and
CC-BY-4.0 section 5.

THIS PROJECT, INCLUDING ALL SOFTWARE, HARDWARE DESIGNS AND DATA, IS PROVIDED "AS IS"
WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND
NON-INFRINGEMENT.

TO THE EXTENT PERMITTED BY APPLICABLE LAW, IN NO EVENT SHALL THE AUTHORS,
CONTRIBUTORS, OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER
LIABILITY ARISING FROM, OUT OF, OR IN CONNECTION WITH THIS PROJECT.

### Additional disclaimer

The following is not a summary of either licence. It is an additional disclaimer of
the kind GPL-3.0 section 7(a) permits, offered alongside them:

HARDWARE DESIGNS HERE HAVE NOT BEEN INDEPENDENTLY VERIFIED OR CERTIFIED FOR SAFETY
OR REGULATORY COMPLIANCE. ANY PHYSICAL PRODUCT MANUFACTURED FROM THEM IS PRODUCED
ENTIRELY AT YOUR OWN RISK. TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE AUTHORS
AND CONTRIBUTORS ARE NOT RESPONSIBLE FOR ANY PERSONAL INJURY, PROPERTY DAMAGE, OR
OTHER HARM RESULTING FROM THE USE OR MANUFACTURE OF PRODUCTS BASED ON THEM.

## Trademarks

Neither licence grants trademark rights. This project does not grant permission to
use the names, trademarks, or logos of the FAST research group or of the project's
contributors, except as needed to describe the project's origin.

## Precedence

Where the commentary in this document and the full licence texts conflict, the full
texts prevail. The scope table above is not commentary — it is the statement of
which files are made available under which terms.
