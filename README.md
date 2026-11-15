# open-source-bioreactor

[![License: GPL-3.0-or-later](https://img.shields.io/badge/License-GPL--3.0--or--later-blue.svg)](LICENSE)

Composable, modular, and extensible bioreactor design.

## status

> Under development, not yet ready for use.

- `scad/` - the OpenSCAD source, built around registered parameter sets for purchased parts and composable modules for printed ones.

## What you need

A printer whose bed takes a 257.6 mm disc in both X and Y (the lid and the frame's two bases, see
[Building it](docs/build.md#what-you-print)); the bought parts in
[`purchased-parts.csv`](purchased-parts.csv), which `just cost` totals; and the OpenSCAD libraries
`just setup` installs.

## Build it

Run `just setup`, then `just export-parts` to write every printed part as an STL with a print list,
then follow [`docs/build.md`](docs/build.md).

## Documentation

- [`docs/build.md`](docs/build.md) - what to cut, print and tighten, and in what order
- [`docs/commissioning.md`](docs/commissioning.md) - the first run, and what to record from it
- [`docs/architecture.md`](docs/architecture.md) - who may hand a number to whom
- [`docs/design-conventions.md`](docs/design-conventions.md) - the rules the model is built to
- [`docs/baseline.md`](docs/baseline.md) - what the reference build holds at a standard, and the knobs later work turns
- [`docs/agitation.md`](docs/agitation.md) - why the impeller is the size it is
- [`docs/ports-layout.md`](docs/ports-layout.md) - what sits at each port on the lid, and why
- [`docs/procurement.md`](docs/procurement.md) - how the bought parts were chosen
- [`docs/decisions.md`](docs/decisions.md) - what was settled and why, and the figures that were corrected
- [`docs/future-work.md`](docs/future-work.md) - ideas with their reasoning, not planned or tracked
- [`docs/references.md`](docs/references.md) - the sources, and how far each one was actually read

## Citation

To cite this project, use the metadata in [`CITATION.cff`](CITATION.cff). GitHub's "Cite this
repository" button reads the same file.

## License

Copyright (c) 2024-2026 Cameron Brooks.

This project is free software: you may redistribute it and/or modify it under the
terms of the GNU General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later version.
That covers the hardware design too: its source includes GPL-licensed libraries, so
it cannot also carry CERN-OHL-S. The measurement data under `analysis/`, and its plots, are licensed
instead under [CC-BY-4.0](LICENSES/CC-BY-4.0.txt). See
[`LICENSING.md`](LICENSING.md) for what applies where, and the organization
[licensing policy](https://github.com/uwo-fast/.github/blob/main/LICENSING.md) for
why.

## OpenSCAD Libraries

Run `just setup` first, after cloning and whenever `openscad-libraries.txt` changes. It
installs the libraries below into `.openscad-libraries/`, each at the revision
[`openscad-libraries.txt`](openscad-libraries.txt) pins, and every recipe puts that
directory first on `OPENSCADPATH`. Without it most of `scad/` does not build, and
`just check` and `just test` fail. Run it even with these libraries installed
globally: a global copy at another revision is what the pins exist to rule out.

- [github.com/nophead/NopSCADlib](https://github.com/nophead/NopSCADlib)
- [github.com/CameronBrooks11/bayonet-lock-scad](https://github.com/CameronBrooks11/bayonet-lock-scad)
- [github.com/thehans/FunctionalOpenSCAD](https://github.com/thehans/FunctionalOpenSCAD)
- [github.com/rcolyer/threads-scad](https://github.com/rcolyer/threads-scad)
- [github.com/CameronBrooks11/din168-thread-scad](https://github.com/CameronBrooks11/din168-thread-scad)
- [github.com/uwo-fast/turbidity-sensor](https://github.com/uwo-fast/turbidity-sensor)
- [github.com/uwo-fast/syringe-actuator](https://github.com/uwo-fast/syringe-actuator)
