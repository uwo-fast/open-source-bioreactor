# open-source-bioreactor

[![License: GPL-3.0-or-later](https://img.shields.io/badge/License-GPL--3.0--or--later-blue.svg)](LICENSE)

A parametric OpenSCAD bioreactor built on glass jars from 1.5 L to 6.5 gal. It is agitated by a
shaft drive or a magnetic drive, or runs as an airlift. A 3D-printed lid holds the drive, sparger,
probes and ports.

This repository contains the reference jar reactor described in the accompanying paper. Parts that
other reactors also use are kept in separate, tagged libraries that this repository pins. A part
moves to a library once a second design uses it:

- the bayonet ports, in [bayonet-port-scad](https://github.com/CameronBrooks11/bayonet-port-scad)
- the turbidity sampler case, in [turbidity-sensor](https://github.com/uwo-fast/turbidity-sensor)
- the sampler's syringe actuator, in [syringe-actuator](https://github.com/uwo-fast/syringe-actuator)

The acrylic column reactor, [column-bioreactor](https://github.com/uwo-fast/column-bioreactor), uses
the same port library.

## Status

> Under development, not yet ready for use.

- `scad/` - the OpenSCAD source. Purchased parts are defined by registered parameter sets, and printed parts by composable modules.

## What you need

- A 3D printer whose bed fits a 257.6 mm disc in both X and Y. The lid and the two frame bases are
  this size (see [Building it](docs/build.md#what-you-print)).
- The purchased parts in [`purchased-parts.csv`](purchased-parts.csv). `just cost` totals their
  price.
- The OpenSCAD libraries that `just setup` installs.

## Build it

Run `just setup`, then `just export-parts` to export every printed part as an STL with a print
list. Then follow [`docs/build.md`](docs/build.md).

## Documentation

- [`docs/build.md`](docs/build.md) - what to cut, print and tighten, and in what order
- [`docs/commissioning.md`](docs/commissioning.md) - the first run and what to record from it
- [`docs/design-conventions.md`](docs/design-conventions.md) - the design conventions the model follows
- [`docs/baseline.md`](docs/baseline.md) - the standard settings the reference build uses, and the parameters later work will vary
- [`docs/agitation.md`](docs/agitation.md) - agitation, and how the impeller was sized
- [`docs/ports-layout.md`](docs/ports-layout.md) - what goes in each lid port, and why
- [`docs/procurement.md`](docs/procurement.md) - how the purchased parts were selected
- [`docs/references.md`](docs/references.md) - the sources, and how thoroughly each one was read
- [`CHANGELOG.md`](CHANGELOG.md) - what each release added, changed and fixed
- For contributors:
  - [`dev/architecture.md`](dev/architecture.md) - which layer may pass a number to which
  - [`dev/decisions.md`](dev/decisions.md) - settled decisions with their reasons, and corrected figures
  - [`dev/future-work.md`](dev/future-work.md) - ideas and their reasoning; not planned or tracked
  - [`CHANGELOG.md`](CHANGELOG.md) - add a line under `## [Unreleased]` in the same pull request for any change a builder would notice (to the CAD, a build, the purchase list, the docs or the checks). A release moves those lines under its version

## Citation

To cite this project, use the metadata in [`CITATION.cff`](CITATION.cff). GitHub's "Cite this
repository" button reads the same file.

## License

Copyright (c) 2024-2026 Cameron Brooks.

This project is free software: you may redistribute it and/or modify it under the
terms of the GNU General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later version.
This includes the hardware design. Its source includes GPL-licensed libraries, so it cannot also be
licensed under CERN-OHL-S. The measurement data under `analysis/` and its plots are licensed under
[CC-BY-4.0](LICENSES/CC-BY-4.0.txt) instead. See [`LICENSING.md`](LICENSING.md) for which licence
applies where, and the organization
[licensing policy](https://github.com/uwo-fast/.github/blob/main/LICENSING.md) for the reasons.

## OpenSCAD Libraries

Run `just setup` after cloning and whenever `scadman.lock` changes. It uses
[scadman](https://github.com/CameronBrooks11/scadman) to install the libraries below into
`.scadman/env/`, each at the revision pinned in [`scadman.lock`](scadman.lock) and verified against
its content hash. Every recipe puts that directory first on `OPENSCADPATH`. Without it, most of
`scad/` does not build, and `just check` and `just test` fail. Run it even if these libraries are
installed globally, because the pins exist to rule out a global copy at a different revision.

On Linux x86_64 and macOS, `just setup` downloads the scadman release it needs into `.cache/`. On
other platforms it uses the `scadman` on `PATH`. Without scadman, install each library below into a
folder with the name shown, at the pinned revision, and add that folder to `OPENSCADPATH`.
[`scadman.toml`](scadman.toml) gives the reason for each pin.

| Name                 | Repository                                                                                  | Pin        | Pinned by                                                 |
| -------------------- | ------------------------------------------------------------------------------------------- | ---------- | --------------------------------------------------------- |
| `NopSCADlib`         | [nophead/NopSCADlib](https://github.com/nophead/NopSCADlib)                                 | `v21.41.1` | this repository, and turbidity-sensor at the same tag     |
| `bayonet-port-scad`  | [CameronBrooks11/bayonet-port-scad](https://github.com/CameronBrooks11/bayonet-port-scad)   | `v0.1.0`   | this repository                                           |
| `bayonet-lock-scad`  | [CameronBrooks11/bayonet-lock-scad](https://github.com/CameronBrooks11/bayonet-lock-scad)   | `v0.12.0`  | bayonet-port-scad                                         |
| `FunctionalOpenSCAD` | [thehans/FunctionalOpenSCAD](https://github.com/thehans/FunctionalOpenSCAD)                 | `51588ff`  | this repository                                           |
| `threads-scad`       | [rcolyer/threads-scad](https://github.com/rcolyer/threads-scad)                             | `4ae9aeb`  | this repository, and bayonet-port-scad at the same commit |
| `din168-thread-scad` | [CameronBrooks11/din168-thread-scad](https://github.com/CameronBrooks11/din168-thread-scad) | `v0.1.0`   | this repository                                           |
| `turbidity-sensor`   | [uwo-fast/turbidity-sensor](https://github.com/uwo-fast/turbidity-sensor)                   | `v0.1.0`   | this repository                                           |
| `syringe-actuator`   | [uwo-fast/syringe-actuator](https://github.com/uwo-fast/syringe-actuator)                   | `v0.1.0`   | turbidity-sensor                                          |
