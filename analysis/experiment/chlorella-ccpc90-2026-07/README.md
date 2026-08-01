# Chlorella vulgaris (CCPC 90) photobioreactor run — telemetry export (2026-07)

Full telemetry export of the July 2026 bioreactor culture, pulled from the Pi's
InfluxDB just before the culture was evacuated and the bench sterilized.

## Culture

- **Organism:** *Chlorella vulgaris*, strain **CCPC 90**
- **Feed / medium:** 0.2 g/L Miracle-Gro in DI water (unbuffered)
- **Control:** impeller stirring only; **no active pH control** (dose pumps configured but disabled the entire run)
- **Vessel / stack:** bioreactor-v1 machine profile; anolis runtime `bioreactor-automation`, providers `bread0` (CRUMBS/I2C actuators) + `ezo0` (Atlas EZO pH/DO probes)

## Export provenance

- **Source:** Pi `anolis-f95d50b1` (129.100.228.70), InfluxDB org/bucket `anolis` (native `--with-observability`, 30-day retention)
- **Window:** `2026-07-23T02:10:05Z → 2026-07-31T18:05:05Z` (~8.7 days, full retained history of this culture)
- **Exported:** 2026-07-31 (~14:05 EDT) via **`anolis-telemetry-export` v0.1.1** (`POST /v1/exports/signals:query`, `resolution.mode=raw_event`, `format=csv`), run from source on the Pi.
- All timestamps are **UTC (RFC3339 Z)**. EDT = UTC−4.
- Per-export manifests (query params + sha256 content hash) are in `manifests/`; `export_index.tsv` maps each signal → export-id → manifest-hash → row count.

### Why per-`(device,signal)` queries (tool caveat)

`anolis-telemetry-export` v0.1.1 has two bugs in `raw_event` mode when a query
spans **multiple field types** (`value_double`/`value_int`/`value_bool`/`value_string`/`value_uint`):

1. **Leaked header rows** — a fresh CSV/NDJSON header is re-emitted at every field-type transition (≈17 junk rows per 15 min of mixed data). Present in **both** CSV and NDJSON (upstream of the formatter).
2. **Wrong `value_type`** — every row is labelled `bool` regardless of the real type.

**Workaround used here:** query one `(device_id, signal_id)` pair at a time — each is a single field type → a single Flux table → **0 leaked headers and correct `value_type`**, at full raw fidelity. Verified: 0 leaked header rows across all 29 files; each signal carries exactly one correct type. `downsampled` mode is also clean (single pivoted table) if a smaller file is ever wanted.

## Files

| Path | What |
|---|---|
| `signals_raw_long.csv` | **Master dataset** — all 29 signals, raw events, time-sorted, long/tidy format. 587,061 rows. |
| `per_signal/<device>__<signal>.csv` | Same data split one file per signal (handy for loading a single series). |
| `manifests/<device>__<signal>.manifest.json` | Export manifest per signal (query window, selector, row count, content hash). |
| `export_index.tsv` | device · signal · rows · leaked_hdr(=0) · export_id · manifest_hash. |

### Schema (`signals_raw_long.csv`)

```
timestamp,runtime_name,provider_id,device_id,signal_id,value,value_type,quality
```

Long format: one row per observed change (telemetry is emitted **on change**, not
at a fixed rate), so sampling cadence varies by signal. To analyze, pivot on
`timestamp` × `signal_id` (values don't share exact timestamps across signals —
resample/`merge_asof` in pandas).

### Signal glossary

| signal_id | device | meaning | type |
|---|---|---|---|
| `ph_value` | ph0 | pH | double |
| `do_mg_l` | do0 | dissolved O₂ (mg/L) | double |
| `do_saturation_pct` | do0 | dissolved O₂ (% sat) | double |
| `t1_c` | rlht0 | reactor temperature (°C) | double |
| `t2_c`, `setpoint1_c`, `setpoint2_c` | rlht0 | secondary temp / heater setpoints (unused this run) | double |
| `relay1_on`, `relay2_on` | rlht0 | heater relays (unused) | bool |
| `period1_ms`, `period2_ms` | rlht0 | relay PWM periods | uint64 |
| `motor2_target` / `motor2_value` | **dcmt0** | **impeller** commanded / echoed PWM (0–255) | int64 |
| `motor1_*` | dcmt0 | dcmt0 channel-1 (sampling; unused) | — |
| `motor*_*` | **dcmt1** | **dose pumps** (disabled entire run → flat) | — |
| `motor*_brake`, `estop` | dcmt0/dcmt1 | brake / e-stop state | bool |
| `mode` | dcmt0/dcmt1/rlht0 | device control mode (`open_loop` etc.) | string |

Row counts (raw events over the window): `ph_value` 204,189 · `t1_c` 181,988 ·
`do_saturation_pct` 97,898 · `do_mg_l` 91,316 · impeller `motor2_*` (dcmt0) ~764 ·
dose/other actuator + rlht static signals 204–755 each.

## Run timeline & caveats (read before analysis)

Full ops/dev detail: `anolis/working/incident-2026-07-24-impeller-failure.md`.

- **Impeller (dcmt0) failed 2026-07-23 19:46 EDT**, undetected ~22 h; recovered 07-24 ~20:19 EDT (board power-cycle + staged restart). No stirring/dosing in that gap → pH fell to ~3.9.
- **Base dose(s)** added manually (unbuffered medium, no pH-stat) → pH stepped back up; culture ran at pH ~8.3 thereafter.
- Two **unexplained reboots** (07-24 11:45, 07-28 23:14 EDT) — brief telemetry gaps.
- **Planned power outage 2026-07-30 18:00 → 07-31 ~06:15 EDT (~12 h):** hard power-off, ~12 h gap in the data. Over the dark/unstirred window the culture **respired** (DO 140 %→86 % sat, pH 8.12→~7.5). **⚠ Clock artifact:** the Pi has no RTC battery, so a short burst of post-boot IDLE data around 07-31 morning is mis-stamped **~22:00–23:00 UTC 2026-07-30** (fake-hwclock restored the poweroff time until NTP synced ~11:00 UTC). Treat the true run boundary as the power cut ~22:00 UTC 07-30 (18:00 EDT).
- Final **short stirred run** 07-31 ~17:22 EDT to capture recovery, then culture evacuated.
- **DO probe** reads supersaturated (>100 % sat) for most of the run — active photosynthesis, but calibration date unknown; treat absolute DO with caution, trends are reliable.

## Reload

```python
import pandas as pd
df = pd.read_csv("signals_raw_long.csv", parse_dates=["timestamp"])
ph  = df[df.signal_id=="ph_value"][["timestamp","value"]]
do  = df[df.signal_id=="do_saturation_pct"][["timestamp","value"]]
tmp = df[df.signal_id=="t1_c"][["timestamp","value"]]
```
