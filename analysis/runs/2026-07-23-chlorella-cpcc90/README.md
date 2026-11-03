# Chlorella vulgaris (CPCC 90) photobioreactor run — telemetry export (2026-07)

Full telemetry export of the July 2026 bioreactor culture, pulled from the Pi's
InfluxDB just before the culture was evacuated and the bench sterilized.

## Culture

- **Organism:** _Chlorella vulgaris_, strain **CPCC 90**
- **Feed / medium:** 0.2 g/L Miracle-Gro in DI water (unbuffered)
- **Control:** impeller stirring only; **no active pH control** (dose pumps configured but disabled the entire run)
- **Vessel / stack:** bioreactor-v1 machine profile; anolis runtime `bioreactor-automation`, providers `bread0` (CRUMBS/I2C actuators) + `ezo0` (Atlas EZO pH/DO probes)

## Export provenance

- **Source:** Pi `anolis-f95d50b1`, InfluxDB org/bucket `anolis` (native `--with-observability`, 30-day retention)
- **Window:** `2026-07-23T02:10:05Z → 2026-07-31T18:05:05Z` (~8.7 days, full retained history of this culture)
- **Exported:** 2026-07-31 (~14:05 EDT) via **`anolis-telemetry-export` v0.1.1** (`POST /v1/exports/signals:query`, `resolution.mode=raw_event`, `format=csv`), run from source on the Pi.
- All timestamps are **UTC (RFC3339 Z)**. EDT = UTC−4.
- Per-export manifests (query params + sha256 content hash) are in `raw/manifests/`; `raw/export_index.tsv` maps each signal → export-id → manifest-hash → row count.

### Why per-`(device,signal)` queries (tool caveat)

`anolis-telemetry-export` v0.1.1 has two bugs in `raw_event` mode when a query
spans **multiple field types** (`value_double`/`value_int`/`value_bool`/`value_string`/`value_uint`):

1. **Leaked header rows** — a fresh CSV/NDJSON header is re-emitted at every field-type transition (≈17 junk rows per 15 min of mixed data). Present in **both** CSV and NDJSON (upstream of the formatter).
2. **Wrong `value_type`** — every row is labelled `bool` regardless of the real type.

**Workaround used here:** query one `(device_id, signal_id)` pair at a time — each is a single field type → a single Flux table → **0 leaked headers and correct `value_type`**, at full raw fidelity. Verified: 0 leaked header rows across all 29 files; each signal carries exactly one correct type. `downsampled` mode is also clean (single pivoted table) if a smaller file is ever wanted.

## Files

| Path                                             | What                                                                                          |
| ------------------------------------------------ | --------------------------------------------------------------------------------------------- |
| `raw/signals_raw_long.csv`                       | **Master dataset** — all 29 signals, raw events, time-sorted, long/tidy format. 587,061 rows. |
| `raw/manifests/<device>__<signal>.manifest.json` | Export manifest per signal (query window, selector, row count, content hash).                 |
| `raw/export_index.tsv`                           | device · signal · rows · leaked_hdr(=0) · export_id · manifest_hash.                          |
| `pipeline.py`                                    | Rebuilds everything below from the master.                                                    |
| `derived/per_signal/<device>__<signal>.csv`      | The master split one file per signal (handy for loading a single series). Git-ignored.        |
| `derived/pivoted_1min.csv`                       | Sensors resampled onto a shared 1-minute grid. Git-ignored.                                   |
| `figures/`                                       | Committed plots.                                                                              |

`per_signal/` used to be committed next to the master, which stored all
587,061 rows twice. It is now regenerated:

```bash
just analysis-run 2026-07-23-chlorella-cpcc90    # or: python pipeline.py --verify
```

`--verify` cross-checks every regenerated split against the row counts in
`raw/export_index.tsv`; the splits come back byte-identical to the original
export.

### Schema (`raw/signals_raw_long.csv`)

```
timestamp,runtime_name,provider_id,device_id,signal_id,value,value_type,quality
```

Long format: one row per observed change (telemetry is emitted **on change**, not
at a fixed rate), so sampling cadence varies by signal. To analyze, pivot on
`timestamp` × `signal_id` (values don't share exact timestamps across signals —
resample/`merge_asof` in pandas).

### Signal glossary

| signal_id                            | device            | meaning                                             | type   |
| ------------------------------------ | ----------------- | --------------------------------------------------- | ------ |
| `ph_value`                           | ph0               | pH                                                  | double |
| `do_mg_l`                            | do0               | dissolved O₂ (mg/L)                                 | double |
| `do_saturation_pct`                  | do0               | dissolved O₂ (% sat)                                | double |
| `t1_c`                               | rlht0             | reactor temperature (°C)                            | double |
| `t2_c`, `setpoint1_c`, `setpoint2_c` | rlht0             | secondary temp / heater setpoints (unused this run) | double |
| `relay1_on`, `relay2_on`             | rlht0             | heater relays (unused)                              | bool   |
| `period1_ms`, `period2_ms`           | rlht0             | relay PWM periods                                   | uint64 |
| `motor2_target` / `motor2_value`     | **dcmt0**         | **impeller** commanded / echoed PWM (0–255)         | int64  |
| `motor1_*`                           | dcmt0             | dcmt0 channel-1 (sampling; unused)                  | —      |
| `motor*_*`                           | **dcmt1**         | **dose pumps** (disabled entire run → flat)         | —      |
| `motor*_brake`, `estop`              | dcmt0/dcmt1       | brake / e-stop state                                | bool   |
| `mode`                               | dcmt0/dcmt1/rlht0 | device control mode (`open_loop` etc.)              | string |

Row counts (raw events over the window): `ph_value` 204,189 · `t1_c` 181,988 ·
`do_saturation_pct` 97,898 · `do_mg_l` 91,316 · impeller `motor2_*` (dcmt0) ~764 ·
dose/other actuator + rlht static signals 204–755 each.

## Run timeline & caveats (read before analysis)

The values, gaps and impeller commands below are read from `raw/signals_raw_long.csv`, where
the impeller is `dcmt0`'s `motor2_target`. What was done - the failure, the restart, the doses,
the outage and the clock - is from the run's incident notes, which are not published. Times are
UTC, with EDT (UTC−4) beside them.

- **The impeller was commanded off for the first 12.8 h.** The record starts 07-23 02:10Z with
  `motor2_target` at 0; it went to 60, 85 and then 100 at 14:59–15:00Z (10:59 EDT). A 36 min
  telemetry gap, 13:58–14:34Z, comes just before.
- **Impeller failed 2026-07-23 23:46Z (19:46 EDT)**, undetected ~22 h; recovered 07-25 ~00:19Z
  (07-24 ~20:19 EDT) by a board power-cycle and a staged restart, `motor2_target` 60 at 00:22Z and
  100 at 00:28Z.
- **pH was falling before the failure, and kept falling after the recovery.** It was 6.785 at the
  start and 4.544 at the failure, reached 3.9 at the recovery (07-24 23:53Z), and bottomed at
  **3.649 at 07-27 16:49Z**, nearly three days into the restored stirring.
- **Base dose(s)** added manually on 07-27 (unbuffered medium, no pH-stat): pH was back above 6 by
  17:15Z and peaked at 9.54 that day. From 19:00Z it held at 8.0–8.4 (hourly means) until the
  outage, except 7.74 in the hour after the second reboot.
- Two **unexplained reboots**, each a telemetry gap: **1.93 h**, 07-24 13:49–15:45Z (09:49–11:45
  EDT), and **6.23 h**, 07-28 21:01Z–07-29 03:15Z (17:01–23:15 EDT).
- **The impeller stayed off for 13.65 h after the second reboot:** `motor2_target` went to 0 at
  07-29 04:07Z (00:07 EDT) and back to 100 at 17:46Z (13:46 EDT). The data does not say why.
- **Planned power outage 2026-07-30 22:00Z → 07-31 10:15Z (18:00 → 06:15 EDT), 12.24 h:** hard
  power-off and no data. Unlit and unstirred, the culture **respired**: the record ends at DO
  135 % sat and pH 8.0, and resumes at DO 43 % and pH 7.0, back to 127 % and 7.6 by 11:00Z.
  **⚠ Clock artifact:** the Pi has no RTC battery, so fake-hwclock restored the poweroff time at
  boot. 17 s of post-boot data, DO 39.9–42.1 % and pH 7.00–7.02, are stamped **07-30
  22:00:23–22:00:40Z**, interleaved with the last real readings (pH ~7.99), so they cannot be cut
  by time alone. The record resumes correctly stamped at 07-31 10:14:54Z. Treat the power cut,
  ~22:00Z 07-30, as the true run boundary.
- Final **short stirred run** from **07-31 17:22:30Z (13:22 EDT)**, after 5.9 h with the impeller
  off from 11:26Z, to capture recovery; the record ends at 18:05Z (14:05 EDT), and the culture was
  then evacuated.
- **DO probe** reads supersaturated (>100 % sat) for most of the run — active photosynthesis, but calibration date unknown; treat absolute DO with caution, trends are reliable.

## Reload

```python
import pandas as pd
df = pd.read_csv("raw/signals_raw_long.csv", parse_dates=["timestamp"])
ph  = df[df.signal_id=="ph_value"][["timestamp","value"]]
do  = df[df.signal_id=="do_saturation_pct"][["timestamp","value"]]
tmp = df[df.signal_id=="t1_c"][["timestamp","value"]]
```
