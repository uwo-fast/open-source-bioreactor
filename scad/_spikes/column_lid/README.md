# Column lid (spike)

A printed top lid for the lab's acrylic column reactors, in place of the plain acrylic disc, so the
same bayonet ports and instruments as the jar reactor mount on top. It is kept apart from the
reactor: `column_lid.scad` reads the bayonet port and NPT thread libraries and changes nothing of
theirs, and the repo's checks skip `scad/_spikes/`.

```sh
just column-lid    # every lid to output/column_lid/<name>.stl, as it prints; fails on any that does not build
```

## The column, as measured

|        |                                                       |
| ------ | ----------------------------------------------------- |
| flange | Ø160 mm                                               |
| bolts  | 8 × Ø10 mm holes, evenly spaced on a Ø139.5 mm circle |
| bore   | Ø100 mm                                               |
| seal   | an o-ring in a groove in the column flange's own face |

## The lid

An 8 mm flange the bolts pass, over a plain 10 mm plug, Ø99.6 mm, that drops into the bore and
centres it. The column's o-ring seals on the flange's underside, so the lid needs no groove. The
18 mm plate is the jar lid's, because the bayonet pins are cut for that panel.

| `variant` | carries                                                                     |
| --------- | --------------------------------------------------------------------------- |
| `npt`     | a 1/2 NPT thread through the plate, the thermocouple mount's thread         |
| `centre`  | one std bayonet port in the middle                                          |
| `ring`    | a std port in the middle and as many round it as fit: 6, on a Ø70.8 mm ring |

**A pocket for a deep headspace.** A column is not always full, and what hangs from a flat lid
may not reach the culture. `pocket_depth` sinks the ports' panel that far down the bore, as the
floor of a cup with a `pocket_wall` wall (5 mm, so 89.6 mm inside), open at the top so a hand
reaches in to turn the pin. 0, the default, is the flat lid. It suits the `centre` lid: a ring
cannot clear its middle port inside the cup, and the build says so. `just column-lid` builds
`centre_pocket` at 100 mm, with 30.7 mm round the pin's flange for the fingers.

The ring is derived, not chosen. It sits as far out as the plug leaves 2 mm round each hole, and
takes as many ports as keep 3 mm between flanges. A different bore or interface recomputes it, and
a ring that cannot clear the middle port fails the build.

**Printing:** `just column-lid` writes each lid turned as it prints (`part = "print"`). The flat
lids lie top face on the bed, plug up, with no supports; that is why the NPT is cut through the
plate without a boss. The pocket lid stands on its floor, the cup rising, and only the flange's
ledge needs supports. 18 mm of plate holds a 1/2 NPT
fitting's 8.1 mm hand-tight and 13.6 mm made-up engagement.

**Pins:** the reactor's own std pins and blanks fit these ports unchanged (`just export-parts`).
Its thermocouple port pin is a 1/2 NPT mount on a std bayonet, so the `centre` lid takes a
threaded fitting that way too. `part = "assembly"` draws the lid with a blank in each port.
