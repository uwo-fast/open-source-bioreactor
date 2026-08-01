"""Readers for the two raw telemetry formats used by this bioreactor.

Two eras of logger produced two very different files:

* The 2024 logger wrote *paired channels* — the CSV is a side-by-side
  concatenation of independent channels, each a ``(time, value)`` column pair
  carrying its own clock and its own length, with shorter channels padded out
  with spaces. Channels are therefore **not** row-aligned.
* The 2026 anolis runtime writes *long/tidy* events, one row per observed
  change, already sharing a single clock column.
"""

from __future__ import annotations

import numpy as np
import pandas as pd


def read_paired_channels(path):
    """Return ``{label: DataFrame[time, value]}`` from a 2024-era logger CSV.

    Frames keep their original row positions and full length — padding rows
    stay in as NaN. :func:`align_by_row_index` depends on that; drop them
    yourself before doing anything time-based.
    """
    raw = pd.read_csv(path, header=0, dtype=str)
    labels = [c for i, c in enumerate(raw.columns) if i % 2 == 1]

    channels = {}
    for i, label in enumerate(labels):
        time = pd.to_numeric(raw.iloc[:, 2 * i].str.strip(), errors="coerce")
        value = raw.iloc[:, 2 * i + 1].str.strip().replace("", np.nan)
        channels[label] = pd.DataFrame({"time": time, "value": value})
    return channels


def align_by_row_index(channels, base, columns):
    """Reproduce the 2024 alignment: stack channels by raw row position.

    This is the historical behaviour and it is **wrong** — it pairs the i-th
    row of each channel regardless of when each sample was actually recorded,
    which on this dataset skews pH by minutes and actuator state by more. Kept
    only so the archived derived files regenerate bit-for-bit. Use
    :func:`align_by_timestamp` for anything new.
    """
    out = pd.DataFrame({"time": channels[base]["time"].round().astype("Int64")})
    for label, name in columns.items():
        out[name] = channels[label]["value"]
    return out[out["time"].notna()]


def align_by_timestamp(channels, base, columns, tolerance_s=30):
    """Align channels onto ``base``'s clock with a backward as-of join.

    Each channel contributes its most recent sample at or before every base
    timestamp, and nothing at all when that sample is older than
    ``tolerance_s``, so gaps stay visible as NaN instead of being silently
    carried forward.
    """

    def clean(label):
        frame = channels[label].dropna(subset=["time"]).copy()
        frame["time"] = frame["time"].astype(float)
        return frame.sort_values("time")

    out = clean(base).rename(columns={"value": columns[base]})
    out = out[["time", columns[base]]]

    for label, name in columns.items():
        if label == base:
            continue
        other = clean(label).rename(columns={"value": name})[["time", name]]
        out = pd.merge_asof(
            out, other, on="time", direction="backward",
            tolerance=float(tolerance_s),
        )
    return out.reset_index(drop=True)


def detect_line_terminator(path):
    r"""Return the line terminator a text file actually uses.

    The exporter emits CRLF, but ``.gitattributes`` normalises ``*.csv`` to LF,
    so a fresh clone sees LF while the original export on disk still has CRLF.
    Anything regenerated from a file should mirror that file rather than assume
    either one.
    """
    with open(path, "rb") as handle:
        line = handle.readline()
    return "\r\n" if line.endswith(b"\r\n") else "\n"


def read_long_telemetry(path):
    """Read a 2026 anolis long-format export into a tidy frame.

    Timestamps are RFC3339 with a Z offset and a varying number of fractional
    digits, so they need an explicit ISO8601 parse to land as datetimes.
    """
    frame = pd.read_csv(path)
    # Keep the exporter's own RFC3339 text so splits can be written back out
    # byte-for-byte instead of in pandas' datetime rendering.
    frame["timestamp_text"] = frame["timestamp"]
    frame["timestamp"] = pd.to_datetime(
        frame["timestamp"], format="ISO8601", utc=True
    )
    frame["key"] = frame["device_id"] + "__" + frame["signal_id"]
    return frame


def pivot_long_telemetry(frame, keys, freq="1min"):
    """Resample selected ``device__signal`` series onto a shared time grid."""
    columns = {}
    for key in keys:
        series = frame.loc[frame["key"] == key, ["timestamp", "value"]]
        series = pd.to_numeric(
            series.set_index("timestamp")["value"], errors="coerce"
        ).dropna()
        columns[key] = series.resample(freq).mean()
    return pd.DataFrame(columns).sort_index()
