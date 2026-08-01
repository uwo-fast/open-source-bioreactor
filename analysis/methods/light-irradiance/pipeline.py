#!/usr/bin/env python3
"""Rebuild the light-irradiance comparison from the spectrometer export.

``raw/spectroscopy_data.csv`` holds seven spectrometer trials as
``(wavelength, irradiance)`` column pairs under a merged header row naming the
three lighting conditions. This regenerates the per-condition splits, which
used to be committed as hand-made files, and the plots built from them.

Negative irradiance is instrument noise below the detection floor and is
dropped to NaN, matching the original cleaning step.
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402
import numpy as np  # noqa: E402
import pandas as pd  # noqa: E402

METHOD = Path(__file__).resolve().parent
RAW = METHOD / "raw" / "spectroscopy_data.csv"
DERIVED = METHOD / "derived"
FIGURES = METHOD / "figures"

# Output name -> the trial columns (0-indexed pairs) it draws from, plus the
# label used on the combined plot.
CONDITIONS = {
    "led1cm": ([0], "LED — 1 cm"),
    "flor90uWpeak": ([1, 2, 3], "Fluorescent — peak matched to LED 90 µW/cm²/nm"),
    "flor1cm": ([4, 5, 6], "Fluorescent — 1 cm"),
}
WAVELENGTH_RANGE = (300, 800)


def split_conditions():
    """Return ``{name: DataFrame}``, one frame per lighting condition."""
    raw = pd.read_csv(RAW, header=1, dtype=str)
    DERIVED.mkdir(exist_ok=True)

    frames = {}
    for name, (trials, _) in CONDITIONS.items():
        columns = [i for trial in trials for i in (2 * trial, 2 * trial + 1)]
        frame = raw.iloc[:, columns].apply(pd.to_numeric, errors="coerce")
        frame.columns = [
            f"{kind} {n}"
            for n in range(1, len(trials) + 1)
            for kind in ("Wavelength", "Absolute Irradiance")
        ]
        for column in frame.columns:
            if column.startswith("Absolute Irradiance"):
                frame[column] = frame[column].where(frame[column] >= 0, np.nan)
        frame.to_csv(DERIVED / f"spectroscopy_{name}.csv", index=False)
        frames[name] = frame
    return frames


def plot(frames):
    FIGURES.mkdir(exist_ok=True)
    for name, frame in frames.items():
        trials = len(frame.columns) // 2
        fig, axis = plt.subplots(figsize=(10, 6))
        for trial in range(1, trials + 1):
            wavelength = frame[f"Wavelength {trial}"]
            irradiance = frame[f"Absolute Irradiance {trial}"].interpolate()
            mask = wavelength.between(*WAVELENGTH_RANGE)
            axis.plot(wavelength[mask], irradiance[mask], label=f"Trial {trial}")
        axis.set_title(f"Absolute irradiance vs wavelength — {CONDITIONS[name][1]}")
        axis.set_xlabel("Wavelength (nm)")
        axis.set_ylabel("Absolute irradiance (µW/cm²/nm)")
        axis.set_ylim(0, 140)
        axis.grid(True, alpha=0.3)
        axis.legend()
        fig.tight_layout()
        fig.savefig(FIGURES / f"{name}.png", dpi=110)
        plt.close(fig)

    fig, axis = plt.subplots(figsize=(10, 6))
    for (name, frame), colour in zip(frames.items(), ("tab:blue", "tab:red", "tab:green")):
        wavelength = frame["Wavelength 1"]
        irradiance = frame["Absolute Irradiance 1"].interpolate()
        mask = wavelength.between(*WAVELENGTH_RANGE)
        axis.plot(
            wavelength[mask], irradiance[mask],
            color=colour, label=CONDITIONS[name][1],
        )
    axis.set_title("Absolute irradiance vs wavelength — lighting conditions compared")
    axis.set_xlabel("Wavelength (nm)")
    axis.set_ylabel("Absolute irradiance (µW/cm²/nm)")
    axis.set_ylim(0, 140)
    axis.grid(True, alpha=0.3)
    axis.legend()
    fig.tight_layout()
    fig.savefig(FIGURES / "combined.png", dpi=110)
    plt.close(fig)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--verify", action="store_true",
        help="report how many noise samples were dropped per condition",
    )
    args = parser.parse_args()

    frames = split_conditions()
    for name, frame in frames.items():
        print(f"wrote derived/spectroscopy_{name}.csv ({frame.shape[0]:,} rows, "
              f"{frame.shape[1] // 2} trial(s))")

    plot(frames)
    print("wrote figures/" + ", figures/".join(
        [f"{n}.png" for n in CONDITIONS] + ["combined.png"]
    ))

    if args.verify:
        print("\nnegative (below-detection-floor) samples dropped:")
        for name, frame in frames.items():
            irradiance = frame.filter(like="Absolute Irradiance")
            print(f"  {name:14s} {int(irradiance.isna().sum().sum()):,} of "
                  f"{irradiance.size:,}")


if __name__ == "__main__":
    main()
