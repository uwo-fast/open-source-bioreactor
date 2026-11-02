#!/usr/bin/env python3
"""Total what purchased-parts.csv costs to buy, by scope and currency, and fail on a row that cannot be summed.

A row costs qty x price: qty counts what you buy (packs, spools, cords), and price is for one of
those, in the row's currency. `need` is how many the build uses, which is not what you pay for.

Totals stay in their own currency unless a rate is given, because a rate written into the repo is
wrong the day after. Pass one with `--cad-per-usd` to get a single figure; the Bank of Canada
publishes the daily rate.

`--check` validates only, which is what `just check` runs.
"""

import argparse
import csv
import re
import sys
from collections import defaultdict
from decimal import Decimal, InvalidOperation

SCOPES = ("reactor", "sampler", "bench", "tooling")
CURRENCIES = ("USD", "CAD")
# How a price was got. Every one but `none` carries a price; `listed` is the only priced one
# without a date, because it predates recording one.
CONFIDENCE = ("read", "listed", "representative", "cited", "estimate", "none")
DATE = re.compile(r"^\d{4}-\d{2}-\d{2}$")

ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
ap.add_argument("--csv", default="purchased-parts.csv")
ap.add_argument("--check", action="store_true", help="validate only")
ap.add_argument(
    "--cad-per-usd", type=Decimal, help="exchange rate, for a combined total"
)
args = ap.parse_args()

errors = []
totals = defaultdict(lambda: defaultdict(Decimal))
unpriced = defaultdict(list)
by_conf = defaultdict(lambda: defaultdict(Decimal))

with open(args.csv, newline="") as f:
    for line, r in enumerate(csv.DictReader(f), start=2):
        where = f"line {line} ({r['item']})"
        conf, price, cur, date = (
            r["price_confidence"],
            r["price"],
            r["currency"],
            r["price_date"],
        )
        if r["scope"] not in SCOPES:
            errors.append(
                f"{where}: scope {r['scope']!r} is not one of {', '.join(SCOPES)}"
            )
        if not r["qty"].isdigit() or int(r["qty"]) < 1:
            errors.append(
                f"{where}: qty {r['qty']!r} is not a whole number of purchase units"
            )
        if not r["unit"]:
            errors.append(f"{where}: no unit says what one of qty is")
        if conf not in CONFIDENCE:
            errors.append(
                f"{where}: price_confidence {conf!r} is not one of {', '.join(CONFIDENCE)}"
            )
        if date and not DATE.match(date):
            errors.append(f"{where}: price_date {date!r} is not YYYY-MM-DD")
        if conf == "none":
            if price or cur or date:
                errors.append(
                    f"{where}: price_confidence is none but a price, currency or date is set"
                )
            unpriced[r["scope"]].append(r["item"])
            continue
        try:
            p = Decimal(price)
        except InvalidOperation:
            p = None
        if p is None or not p.is_finite() or p < 0:
            errors.append(f"{where}: price {price!r} is not a number")
            continue
        if cur not in CURRENCIES:
            errors.append(
                f"{where}: currency {cur!r} is not one of {', '.join(CURRENCIES)}"
            )
            continue
        if conf != "listed" and not date:
            errors.append(f"{where}: a {conf} price needs the date it was got")
        if r["qty"].isdigit():
            totals[r["scope"]][cur] += int(r["qty"]) * p
            by_conf[conf][cur] += int(r["qty"]) * p

if errors:
    print("\n".join(f"FAIL  {e}" for e in errors))
    sys.exit(1)
if args.check:
    sys.exit(0)


def money(d):
    return "  ".join(f"{d[c]:>9.2f} {c}" for c in CURRENCIES if d[c]) or "        -"


def combined(d):
    if args.cad_per_usd is None:
        return ""
    cad = d["CAD"] + d["USD"] * args.cad_per_usd
    return f"  = {cad:>9.2f} CAD = {cad / args.cad_per_usd:>9.2f} USD"


print("By scope, what buying it costs (qty x price):")
for s in SCOPES:
    print(
        f"  {s:8} {money(totals[s])}{combined(totals[s])}  ({len(unpriced[s])} unpriced)"
    )
print("\nBy how the price was got:")
for c in CONFIDENCE[:-1]:
    if by_conf[c]:
        print(f"  {c:14} {money(by_conf[c])}{combined(by_conf[c])}")
if args.cad_per_usd is not None:
    print(f"\nAt {args.cad_per_usd} CAD per USD.")
for s in SCOPES:
    if unpriced[s]:
        print(f"\nUnpriced in {s}, so missing from its total:")
        print("\n".join(f"  - {i}" for i in unpriced[s]))
