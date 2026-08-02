#!/usr/bin/env python3
"""Rebuild every derived artefact for the 2024-11-19 microalgae run.

Writes to ``derived/`` (git-ignored) and ``figures/`` (committed):

* ``derived/legacy_cleaned{0,1,2}.csv`` — bit-for-bit reconstructions of the
  files that used to be committed here. ``--verify`` checks them against the
  sha256 digests recorded in this run's README.
* ``derived/tidy.csv`` — the corrected frame, aligned on real timestamps.

Run ``python pipeline.py --verify`` to confirm the reconstruction still holds.
"""

from __future__ import annotations

import argparse
import hashlib
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402
import numpy as np  # noqa: E402
import pandas as pd  # noqa: E402

RUN = Path(__file__).resolve().parent
RAW = RUN / "raw" / "microalgae_raw.csv"
DERIVED = RUN / "derived"
FIGURES = RUN / "figures"

# Channel label in the raw file -> column name in the derived frames.
COLUMNS = {
    "Thermo 1": "temperature",
    "Dissolved Oxygen": "dissolved oxygen",
    "pH": "pH",
    "Stirring": "stirring motor",
    "Pump 1": "sample pump",
}
BASE = "Thermo 1"

# sha256 of the derived CSVs as they were committed before the 2026-08
# restructure, so the reconstruction stays provable after their deletion.
#
# cleaned0 is the one exception: the committed file had sha256 e64c807c…, which
# differs from this reconstruction in exactly one cell. The spreadsheet that
# produced it rounded a temperature of 4.37069000783219e-19 to 4.37E-19. The
# digest below is the faithful, unrounded reconstruction; cleaned1 and
# cleaned2, which every published figure was built from, are unaffected
# because that sample fails the 20-45 C filter either way.
LEGACY_DIGESTS = {
    "legacy_cleaned0.csv":
        "b158e35343a163558f3e0513eec296a3b164ae29ec355a3e07fbf4058479a67a",
    "legacy_cleaned1.csv":
        "0d2900e53e2a1265169806164790dc7cd7e2c9dad5ae12f00e21d2a7092524c1",
    "legacy_cleaned2.csv":
        "91ff8a32d55a1cf14d65584de622efc67b88d66b4683351ef50f9c3a477f3745",
}


def read_paired_channels(path):
    """Return ``{label: DataFrame[time, value]}`` from the raw logger CSV.

    The file is not a table. It is fourteen independent channels laid side by
    side, each a ``(time, value)`` column pair carrying its own clock and its
    own length, space-padded to the longest. Frames keep their original row
    positions and full length — padding rows stay in as NaN, which
    :func:`align_by_row_index` depends on.
    """
    raw = pd.read_csv(path, header=0, dtype=str)
    labels = [c for i, c in enumerate(raw.columns) if i % 2 == 1]

    channels = {}
    for i, label in enumerate(labels):
        time = pd.to_numeric(raw.iloc[:, 2 * i].str.strip(), errors="coerce")
        value = raw.iloc[:, 2 * i + 1].str.strip().replace("", np.nan)
        channels[label] = pd.DataFrame({"time": time, "value": value})
    return channels


def align_by_row_index(channels):
    """Stack channels by raw row position, as the 2024 spreadsheet did.

    This is **wrong** — it pairs the i-th row of each channel regardless of
    when each sample was actually recorded. Kept only so the archived derived
    files regenerate bit-for-bit; see README.md for the measured skew.
    """
    out = pd.DataFrame({"time": channels[BASE]["time"].round().astype("Int64")})
    for label, name in COLUMNS.items():
        out[name] = channels[label]["value"]
    return out[out["time"].notna()]


def align_by_timestamp(channels, tolerance_s=30):
    """Align channels onto the base channel's clock with a backward as-of join.

    Each channel contributes its most recent sample at or before every base
    timestamp, and nothing at all when that sample is older than
    ``tolerance_s``, so gaps stay NaN instead of being carried forward.
    """

    def clean(label):
        frame = channels[label].dropna(subset=["time"]).copy()
        frame["time"] = frame["time"].astype(float)
        return frame.sort_values("time")

    out = clean(BASE).rename(columns={"value": COLUMNS[BASE]})[["time", COLUMNS[BASE]]]

    for label, name in COLUMNS.items():
        if label == BASE:
            continue
        other = clean(label).rename(columns={"value": name})[["time", name]]
        out = pd.merge_asof(
            out, other, on="time", direction="backward",
            tolerance=float(tolerance_s),
        )
    return out.reset_index(drop=True)


def build_legacy(channels):
    """Replay the historical cleaned0 -> cleaned1 -> cleaned2 chain.

    cleaned0 was produced in a spreadsheet, so it carries uppercase booleans
    and no trailing newline; cleaned1 and cleaned2 came from pandas scripts
    that re-read it, which is what turned those booleans into True/False. The
    chain is replayed through disk here for exactly that reason.
    """
    cleaned0 = align_by_row_index(channels)
    # The logger emitted its first scan twice, and the export was cut one row
    # short of the last temperature sample.
    cleaned0 = cleaned0.drop_duplicates(subset=["time"], keep="first").iloc[:-1]
    for column in ("stirring motor", "sample pump"):
        cleaned0[column] = cleaned0[column].str.upper()

    path0 = DERIVED / "legacy_cleaned0.csv"
    # Dropped temperature samples were spelled "null" by the original tool.
    path0.write_text(cleaned0.to_csv(index=False, na_rep="null").rstrip("\n"))

    reread = pd.read_csv(path0)
    # No active heating or cooling, so anything outside 20-45 C is sensor noise.
    cleaned1 = reread[reread["temperature"].between(20, 45)]
    (DERIVED / "legacy_cleaned1.csv").write_text(cleaned1.to_csv(index=False))

    # pH below 7 is the probe still settling at the start of the run.
    cleaned2 = cleaned1[cleaned1["pH"] >= 7]
    (DERIVED / "legacy_cleaned2.csv").write_text(cleaned2.to_csv(index=False))

    return {
        "legacy_cleaned0.csv": cleaned0,
        "legacy_cleaned1.csv": cleaned1,
        "legacy_cleaned2.csv": cleaned2,
    }


def build_tidy(channels):
    """The corrected frame: real timestamps, same physical filters."""
    tidy = align_by_timestamp(channels, tolerance_s=30)
    for column in ("temperature", "dissolved oxygen", "pH"):
        tidy[column] = pd.to_numeric(tidy[column], errors="coerce")
    for column in ("stirring motor", "sample pump"):
        tidy[column] = tidy[column].str.lower().map({"true": True, "false": False})

    tidy = tidy[tidy["temperature"].between(20, 45)]
    tidy = tidy[tidy["pH"] >= 7]
    tidy.insert(1, "datetime", pd.to_datetime(tidy["time"], unit="s", utc=True))
    return tidy.reset_index(drop=True)


def plot(tidy):
    smoothed = tidy.assign(
        temperature=tidy["temperature"].rolling(30, min_periods=1).mean(),
        **{"dissolved oxygen": tidy["dissolved oxygen"].rolling(5, min_periods=1).mean()},
        pH=tidy["pH"].rolling(5, min_periods=1).mean(),
    )

    fig, axes = plt.subplots(3, 1, figsize=(15, 12), sharex=True)
    for axis, column, label, colour in (
        (axes[0], "temperature", "Temperature (°C)", "tab:red"),
        (axes[1], "dissolved oxygen", "Dissolved oxygen (%)", "tab:blue"),
        (axes[2], "pH", "pH", "tab:green"),
    ):
        axis.plot(smoothed["datetime"], smoothed[column], color=colour, label=label)
        axis.set_ylabel(label)
        axis.legend()
        axis.grid(True)
    axes[0].set_title("2024-11-19 microalgae run — sensors")
    axes[2].set_xlabel("Time (UTC)")
    fig.tight_layout()
    fig.savefig(FIGURES / "sensors.png", dpi=110)
    plt.close(fig)

    fig, axis = plt.subplots(figsize=(15, 8))
    for column, colour in (("stirring motor", "tab:orange"), ("sample pump", "tab:purple")):
        axis.step(
            tidy["datetime"], tidy[column].astype(int),
            where="post", label=column.title(), color=colour,
        )
    axis.set_title("2024-11-19 microalgae run — actuators")
    axis.set_xlabel("Time (UTC)")
    axis.set_ylabel("On (1) / Off (0)")
    axis.legend()
    axis.grid(True)
    fig.tight_layout()
    fig.savefig(FIGURES / "actuators.png", dpi=110)
    plt.close(fig)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--verify", action="store_true",
        help="check the rebuilt legacy CSVs against their recorded sha256",
    )
    args = parser.parse_args()

    DERIVED.mkdir(exist_ok=True)
    FIGURES.mkdir(exist_ok=True)

    channels = read_paired_channels(RAW)
    for name, frame in build_legacy(channels).items():
        print(f"wrote derived/{name} ({len(frame):,} rows)")

    tidy = build_tidy(channels)
    tidy.to_csv(DERIVED / "tidy.csv", index=False)
    print(f"wrote derived/tidy.csv ({len(tidy):,} rows)")

    plot(tidy)
    print("wrote figures/sensors.png, figures/actuators.png")

    if args.verify:
        print("\nverifying legacy reconstruction against recorded sha256:")
        failures = 0
        for name, expected in LEGACY_DIGESTS.items():
            digest = hashlib.sha256((DERIVED / name).read_bytes()).hexdigest()
            ok = digest == expected
            failures += not ok
            print(f"  {'OK  ' if ok else 'FAIL'} {name}  {digest}")
        if failures:
            raise SystemExit(f"{failures} legacy file(s) did not reproduce")
        print("all legacy files reproduce exactly")


if __name__ == "__main__":
    main()
