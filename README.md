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
- [`docs/design-conventions.md`](docs/design-conventions.md) - the rules the model is built to
- [`docs/baseline.md`](docs/baseline.md) - what the reference build holds at a standard, and the knobs later work turns
- [`docs/agitation.md`](docs/agitation.md) - why the impeller is the size it is
- [`docs/ports-layout.md`](docs/ports-layout.md) - what sits at each port on the lid, and why
- [`docs/procurement.md`](docs/procurement.md) - how the bought parts were chosen
- [`docs/references.md`](docs/references.md) - the sources, and how far each one was actually read
- For contributors:
  - [`dev/architecture.md`](dev/architecture.md) - who may hand a number to whom
  - [`dev/decisions.md`](dev/decisions.md) - what was settled and why, and the figures that were corrected
  - [`dev/future-work.md`](dev/future-work.md) - ideas with their reasoning, not planned or tracked

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

Run `just setup` first, after cloning and whenever `scadman.lock` changes. It installs the
libraries below into `.scadman/env/` with [scadman](https://github.com/CameronBrooks11/scadman),
each at the revision [`scadman.lock`](scadman.lock) pins and checked against its content hash,
and every recipe puts that directory first on `OPENSCADPATH`. Without it most of `scad/` does
not build, and `just check` and `just test` fail. Run it even with these libraries installed
globally: a global copy at another revision is what the pins exist to rule out.

`just setup` fetches the scadman release it needs into `.cache/` on Linux x86_64 and macOS.
Elsewhere it uses a `scadman` on `PATH`. Without scadman, install each library below into a
folder with the name shown, at the pin shown, and put that folder on `OPENSCADPATH`.
[`scadman.toml`](scadman.toml) says why each one is at its pin.

| Name                 | Repository                                                                                  | Pin        |
| -------------------- | ------------------------------------------------------------------------------------------- | ---------- |
| `NopSCADlib`         | [nophead/NopSCADlib](https://github.com/nophead/NopSCADlib)                                 | `v21.41.1` |
| `bayonet-lock-scad`  | [CameronBrooks11/bayonet-lock-scad](https://github.com/CameronBrooks11/bayonet-lock-scad)   | `v0.12.0`  |
| `FunctionalOpenSCAD` | [thehans/FunctionalOpenSCAD](https://github.com/thehans/FunctionalOpenSCAD)                 | `51588ff`  |
| `threads-scad`       | [rcolyer/threads-scad](https://github.com/rcolyer/threads-scad)                             | `4ae9aeb`  |
| `din168-thread-scad` | [CameronBrooks11/din168-thread-scad](https://github.com/CameronBrooks11/din168-thread-scad) | `7ea65c3`  |
| `turbidity-sensor`   | [uwo-fast/turbidity-sensor](https://github.com/uwo-fast/turbidity-sensor)                   | `4be431f`  |
| `syringe-actuator`   | [uwo-fast/syringe-actuator](https://github.com/uwo-fast/syringe-actuator)                   | `ea8b221`  |
