# open-source-bioreactor

Composable, modular, and extensible bioreactor design.

## status

> Under development, not yet ready for use.

- `scad/` - the OpenSCAD source, built around registered parameter sets for purchased parts and composable modules for printed ones. This replaced an earlier iteration that became unwieldy as the assembly grew; that tree was removed in `376c21f` and remains in the history.

## Documentation

- [`docs/build.md`](docs/build.md) — what to cut, print and tighten, and in what order
- [`docs/architecture.md`](docs/architecture.md) — who may hand a number to whom
- [`docs/design-conventions.md`](docs/design-conventions.md) — the rules the model is built to
- [`docs/baseline.md`](docs/baseline.md) — what the reference build holds at a standard, and the knobs later work turns
- [`docs/agitation.md`](docs/agitation.md) — why the impeller is the size it is
- [`docs/ports-layout.md`](docs/ports-layout.md) — what sits at each port on the lid, and why
- [`docs/procurement.md`](docs/procurement.md) — how the bought parts were chosen
- [`docs/references.md`](docs/references.md) — the sources, and how far each one was actually read

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

---

<div align="center">
  <p>
    <img src="https://img.shields.io/badge/Developed_by-uwo--fast-purple" alt="Developed by uwo-FAST">
    <img src="https://img.shields.io/badge/Powered_by-Open_Source-blue" alt="Powered by Open Source">
  </p>
</div>
