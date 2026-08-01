# Microalgae run — 2024-11-19

The first instrumented culture run on the v1 bioreactor. Temperature,
dissolved oxygen and pH were logged alongside the stirring motor and sample
pump for 8.9 days (2024-11-19 19:06 UTC → 2024-11-28 16:23 UTC).

This run predates the anolis telemetry stack; see
[`../2026-07-23-chlorella-ccpc90/`](../2026-07-23-chlorella-ccpc90/) for the
current export format.

> **Provenance warning.** Organism, strain, medium and vessel were never
> recorded for this run, and cannot now be recovered. Treat it as a
> commissioning shakedown of the logging chain rather than a characterised
> culture experiment.

## Files

| Path | What |
|---|---|
| `raw/microalgae_raw.csv` | The logger export, untouched. 28 MB, 152,712 rows. |
| `pipeline.py` | Rebuilds everything below from the raw file. |
| `derived/` | Regenerated, git-ignored. |
| `figures/` | Committed plots. |

Rebuild with:

```bash
just analysis-run 2024-11-19-microalgae     # or: python pipeline.py --verify
```

## Raw format: paired channels, independent clocks

The raw CSV is **not** a table. It is fourteen independent channels laid
side by side, each a `(time, value)` column pair with its **own clock and its
own length**, space-padded to the longest:

```
time,Air Cal,time,DO Cal,…,time,Thermo 1,time,Dissolved Oxygen,time,pH,time,Stirring,time,Pump 1,…
```

Row *i* of `Thermo 1` and row *i* of `pH` are **unrelated samples**. Channel
lengths differ accordingly:

| Channel | Samples | Kept as |
|---|---|---|
| `Thermo 1` | 152,615 | `temperature` |
| `Dissolved Oxygen` | 152,624 | `dissolved oxygen` |
| `pH` | 152,661 | `pH` |
| `Stirring` | 152,688 | `stirring motor` |
| `Pump 1` | 152,712 | `sample pump` |

The other nine channels are one-shot calibration events (2 samples each) plus
the unused heating element and pH-control outputs, and are dropped.

## ⚠ The historical pipeline misaligned the channels

The originally committed `cleaned0/1/2` files were built by stacking the
channels **by row position**, which silently pairs samples taken minutes
apart. Measured skew relative to the `Thermo 1` clock:

| Channel | Median | 95th pct | Worst |
|---|---|---|---|
| Dissolved Oxygen | −39 s | +0.6 s | −475 s |
| pH | −154 s | −3.5 s | −513 s |
| Stirring | −258 s | −43 s | +948 s |
| Pump 1 | −338 s | −28 s | +948 s |

So in every previously published figure from this run, **pH lags its stated
timestamp by ~2.5 minutes on average and actuator state by ~5 minutes**, with
excursions to ±16 minutes. Slow trends are unaffected; anything that reads
short-term cause and effect between an actuator and a sensor is not.

`pipeline.py` therefore emits two frames:

- **`derived/tidy.csv`** — correct. Channels aligned onto the `Thermo 1` clock
  with a backward as-of join and a 30 s tolerance, so gaps stay NaN rather
  than being carried forward. **Use this.**
- **`derived/legacy_cleaned{0,1,2}.csv`** — bit-for-bit reconstructions of the
  files that used to be committed here, kept only so past figures remain
  auditable. Do not build new analysis on them.

Both apply the same two physical filters the original scripts did: temperature
outside 20–45 °C is sensor noise (there was no active heating or cooling), and
pH below 7 is the probe still settling at the start of the run.

## Reconstruction provenance

The step from `raw` to `cleaned0` was originally done by hand in a spreadsheet
and **no script for it was ever committed**. It has since been reverse-
engineered and is now `align_by_row_index()` in [`../../lib/rawio.py`](../../lib/rawio.py):
take channels by raw row position, set `time = round(Thermo 1 time)`, drop the
duplicated first scan, drop the final row, and uppercase the booleans.

`python pipeline.py --verify` checks the reconstruction against the sha256 of
each file as it was committed before the 2026-08 restructure:

| File | sha256 | Status |
|---|---|---|
| `legacy_cleaned1.csv` | `0d2900e5…` | byte-identical |
| `legacy_cleaned2.csv` | `91ff8a32…` | byte-identical |
| `legacy_cleaned0.csv` | `b158e353…` | see below |

`cleaned0` as committed had sha256 `e64c807c…` and differs from the
reconstruction in **exactly one cell of 915,678**: the spreadsheet rounded a
temperature reading of `4.37069000783219e-19` to `4.37E-19`. The digest
recorded in `pipeline.py` is the faithful unrounded value. Nothing downstream
is affected — that sample fails the 20–45 °C filter either way, which is why
`cleaned1` and `cleaned2`, the files every published figure was actually built
from, still reproduce exactly.

## Reload

```python
import pandas as pd
tidy = pd.read_csv("derived/tidy.csv", parse_dates=["datetime"])
```
