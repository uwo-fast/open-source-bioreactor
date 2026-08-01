#!/usr/bin/env python3
"""Rebuild every derived artefact for the 2026-07-23 Chlorella CCPC 90 run.

The export ships one master file, ``raw/signals_raw_long.csv``. Everything
else is regenerated here:

* ``derived/per_signal/<device>__<signal>.csv`` — the master split one file per
  series. These used to be committed alongside the master, which stored the
  same 587,061 rows twice.
* ``derived/pivoted_1min.csv`` — the analysis frame, resampled onto a shared
  1-minute grid, since telemetry is emitted on change rather than on a clock.

``--verify`` cross-checks every regenerated split against the row counts in
``raw/export_index.tsv``.
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402
import pandas as pd  # noqa: E402

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))
from lib import rawio  # noqa: E402

RUN = Path(__file__).resolve().parent
MASTER = RUN / "raw" / "signals_raw_long.csv"
INDEX = RUN / "raw" / "export_index.tsv"
DERIVED = RUN / "derived"
FIGURES = RUN / "figures"

SENSORS = ["ph0__ph_value", "do0__do_saturation_pct", "rlht0__t1_c"]
IMPELLER = "dcmt0__motor2_value"

# The run did not proceed cleanly; see README.md for the full account.
EVENTS = [
    ("2026-07-23 23:46Z", "impeller failed"),
    ("2026-07-25 00:19Z", "impeller recovered"),
    ("2026-07-30 22:00Z", "power cut"),
    ("2026-07-31 10:15Z", "power restored"),
]


def split_per_signal(frame):
    """Write the master back out as one file per (device, signal).

    Writes the exporter's original timestamp text, so each split is
    byte-identical to the corresponding file from the original export.
    """
    out = DERIVED / "per_signal"
    out.mkdir(parents=True, exist_ok=True)
    columns = [c for c in frame.columns if c not in ("key", "timestamp_text")]
    terminator = rawio.detect_line_terminator(MASTER)

    counts = {}
    for key, group in frame.groupby("key", sort=True):
        group = group[columns].assign(timestamp=group["timestamp_text"])
        group.to_csv(out / f"{key}.csv", index=False, lineterminator=terminator)
        counts[key] = len(group)
    return counts


def verify(counts):
    """Cross-check regenerated splits against the exporter's own row counts."""
    index = pd.read_csv(INDEX, sep="\t")
    index["key"] = index["device"] + "__" + index["signal"]
    expected = dict(zip(index["key"], index["rows"]))

    failures = 0
    for key in sorted(expected):
        got, want = counts.get(key, 0), expected[key]
        ok = got == want
        failures += not ok
        if not ok:
            print(f"  FAIL {key}: regenerated {got:,}, export_index says {want:,}")
    extra = set(counts) - set(expected)
    for key in sorted(extra):
        failures += 1
        print(f"  FAIL {key}: regenerated but absent from export_index")

    if failures:
        raise SystemExit(f"{failures} signal(s) failed verification")
    print(f"  OK   all {len(expected)} signals match export_index row counts "
          f"({sum(expected.values()):,} rows total)")


def plot(pivoted):
    fig, axes = plt.subplots(3, 1, figsize=(15, 12), sharex=True)
    for axis, key, label, colour in (
        (axes[0], "rlht0__t1_c", "Reactor temperature (°C)", "tab:red"),
        (axes[1], "do0__do_saturation_pct", "Dissolved O₂ (% sat)", "tab:blue"),
        (axes[2], "ph0__ph_value", "pH", "tab:green"),
    ):
        axis.plot(pivoted.index, pivoted[key], color=colour, linewidth=0.9, label=label)
        axis.set_ylabel(label)
        axis.grid(True, alpha=0.3)
        axis.legend(loc="upper left")
        for when, name in EVENTS:
            axis.axvline(pd.Timestamp(when), color="0.4", linestyle="--", linewidth=0.8)
    blended = axes[0].get_xaxis_transform()
    for when, name in EVENTS:
        axes[0].annotate(
            name, xy=(pd.Timestamp(when), 0.97), xycoords=blended,
            rotation=90, va="top", ha="right", fontsize=8, color="0.3",
        )
    axes[0].set_title("Chlorella vulgaris CCPC 90 — 2026-07-23 to 07-31")
    axes[2].set_xlabel("Time (UTC)")
    fig.tight_layout()
    fig.savefig(FIGURES / "sensors.png", dpi=110)
    plt.close(fig)

    fig, axis = plt.subplots(figsize=(15, 5))
    axis.step(
        pivoted.index, pivoted[IMPELLER], where="post",
        color="tab:orange", label="Impeller PWM (0-255)",
    )
    axis.set_title("Impeller commanded PWM")
    axis.set_xlabel("Time (UTC)")
    axis.set_ylabel("PWM")
    axis.grid(True, alpha=0.3)
    axis.legend()
    for when, _ in EVENTS:
        axis.axvline(pd.Timestamp(when), color="0.4", linestyle="--", linewidth=0.8)
    fig.tight_layout()
    fig.savefig(FIGURES / "actuators.png", dpi=110)
    plt.close(fig)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--verify", action="store_true",
        help="cross-check regenerated splits against raw/export_index.tsv",
    )
    args = parser.parse_args()

    DERIVED.mkdir(exist_ok=True)
    FIGURES.mkdir(exist_ok=True)

    print(f"reading {MASTER.name} …")
    frame = rawio.read_long_telemetry(MASTER)
    print(f"  {len(frame):,} rows, {frame['key'].nunique()} signals")

    counts = split_per_signal(frame)
    print(f"wrote derived/per_signal/ ({len(counts)} files)")

    pivoted = rawio.pivot_long_telemetry(frame, SENSORS + [IMPELLER], freq="1min")
    pivoted.to_csv(DERIVED / "pivoted_1min.csv")
    print(f"wrote derived/pivoted_1min.csv ({len(pivoted):,} rows)")

    plot(pivoted)
    print("wrote figures/sensors.png, figures/actuators.png")

    if args.verify:
        print("\nverifying regenerated splits against export_index.tsv:")
        verify(counts)


if __name__ == "__main__":
    main()
