# Light irradiance — LED vs fluorescent

Spectrometer characterisation of the two lighting options considered for the
reactor, measured 2025-01. This is a **method**, not a culture run: it
characterises hardware and can be re-run against any future light source.

## Files

| Path | What |
|---|---|
| `raw/spectroscopy_data.csv` | Spectrometer export, untouched. Seven trials, 3,648 samples each. |
| `pipeline.py` | Rebuilds the per-condition splits and all four plots. |
| `derived/` | Regenerated, git-ignored. |
| `figures/` | Committed plots. |

Rebuild with:

```bash
just analysis-method light-irradiance    # or: python pipeline.py --verify
```

## Conditions

The raw export carries seven `(wavelength, irradiance)` column pairs under a
merged header row that names three conditions:

| Condition | Trials | Split file |
|---|---|---|
| LED at 1 cm | 1 | `derived/spectroscopy_led1cm.csv` |
| Fluorescent, peak matched to the LED at 90 µW/cm²/nm | 3 | `derived/spectroscopy_flor90uWpeak.csv` |
| Fluorescent at 1 cm | 3 | `derived/spectroscopy_flor1cm.csv` |

Those three split files used to be committed as hand-made copies with no
script behind them. They are now regenerated: select the condition's columns,
then drop negative irradiance to NaN. Negative readings are instrument noise
below the detection floor — 363, 2,398 and 2,188 samples respectively, which
`--verify` reports.

Plots cover 300–800 nm, the range that matters for photosynthetically active
radiation.

## Reload

```python
import pandas as pd
led = pd.read_csv("derived/spectroscopy_led1cm.csv")
```
