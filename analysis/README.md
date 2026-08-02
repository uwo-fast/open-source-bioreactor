# analysis

Culture runs and hardware characterisation for the bioreactor.

## Layout

```
analysis/
  runs/<date>-<subject>/    one culture run
  methods/<name>/           hardware characterisation, re-runnable anytime
```

Each `pipeline.py` is self-contained: it reads its own raw format, writes its
own outputs, and shares no code with the others. The raw formats have nothing
in common — a 2024 paired-channel dump and a 2026 long-event export — so
there is nothing worth factoring out, and each pipeline stays readable on its
own.

Every run and method directory has the same shape:

| Path | Committed? | What |
|---|---|---|
| `README.md` | yes | Provenance, caveats, how to reload. |
| `raw/` | yes | The original export. **Never edited.** |
| `pipeline.py` | yes | Rebuilds everything else from `raw/`. |
| `derived/` | **no** | Intermediates and analysis frames. |
| `figures/` | yes | Plots. |

### Runs

| Run | Subject | Span |
|---|---|---|
| [`runs/2024-11-19-microalgae`](runs/2024-11-19-microalgae/) | unrecorded microalgae, v1 reactor | 8.9 d |
| [`runs/2026-07-23-chlorella-ccpc90`](runs/2026-07-23-chlorella-ccpc90/) | *Chlorella vulgaris* CCPC 90 | 8.7 d |

### Methods

| Method | What |
|---|---|
| [`methods/light-irradiance`](methods/light-irradiance/) | LED vs fluorescent spectra, 300–800 nm |

## The one rule

**Raw is immutable and committed. Everything derived is git-ignored and has a
script that regenerates it.**

Before this directory was restructured in 2026-08 it worked the other way
round: derived CSVs were committed while the code that produced them was
never written down at all. The `raw → cleaned0` step for the 2024 run had to
be reverse-engineered from the data itself, and the 2026 run shipped 587,061
rows twice — once as the master, once as per-signal splits.

Concretely, when adding a run:

- Put the export in `raw/` and do not touch it again. If it needs fixing, fix
  it in `pipeline.py`.
- Anything you can regenerate goes in `derived/`, which is git-ignored.
- Write the README **when you do the run**, not later. Organism, medium,
  control mode, and anything that went wrong are unrecoverable a year on —
  the 2024 run has no record of what was even growing in it.
- Figures are committed despite being derived. They are small, they are the
  thing people actually look at, and they should survive the raw data moving
  out of git.

## Running things

```bash
just analysis-setup                              # create the venv
just analysis                                    # rebuild everything, with verification
just analysis-run 2026-07-23-chlorella-ccpc90    # one run
just analysis-method light-irradiance            # one method
```

Or directly, once `analysis-setup` has been run:

```bash
.venv/bin/python runs/2026-07-23-chlorella-ccpc90/pipeline.py --verify
```

Every `pipeline.py` takes `--verify`, which checks its output against
independent evidence — recorded sha256 digests for the 2024 run, the
exporter's own row counts for the 2026 run.

## Data size

`raw/` is 74 MB across both runs and compresses to roughly 14 MB in git. That
is affordable now but scales linearly with every run: one 8.7-day culture is
~14 MB packed, permanently.

Before committing the next export, decide where it goes. Once raw telemetry
approaches a few hundred MB, move `raw/` to Git LFS or to external storage
and keep only the manifests and their sha256 digests in git — the 2026 run's
`raw/manifests/` already has exactly what that needs.
