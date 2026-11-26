# Architecture

This document defines where a number may come from. [Design conventions](../docs/design-conventions.md)
says how a number is justified; this document says which file may pass it to which. It is
normative: a file that breaks a rule here is a defect.

## The layers

```
bioreactor.scad        the build: designations resolved, coupling derived once, head + frame composed
  |-- head.scad        subassembly: takes its coupling as arguments, standalone defaults
  |-- frame.scad       subassembly, same contract
  |     |-- custom/    printed parts: arguments in, geometry out
  |     |-- purchased/ bought parts: registry rows, accessors, a drawing of the vitamin
  |     `-- utils/     standards and laws: thread tables, gland ratios, physics, geometry helpers
support/               furniture around the reactor; may compose bioreactor.scad, nothing composes it
_shelf/  _archive/      off the tree; nothing on it imports them
```

| Layer           | Holds                                                                 | May import                                                   | May not                                        |
| --------------- | --------------------------------------------------------------------- | ------------------------------------------------------------ | ---------------------------------------------- |
| `bioreactor`    | designations by name, the coupling, the composition                   | `use` head, frame; the registries it resolves from           | derive a number a subassembly also derives     |
| `head`, `frame` | own preferences as live defaults; parts composed                      | `use` custom, utils; registries, to resolve names            | read the other's state; read `bioreactor.scad` |
| `custom`        | one general-case part per file; optionally its own interface registry | `use` utils, another custom part; `include` its own registry | read a `purchased/` registry; know a reactor   |
| `purchased`     | a swept row list, a by-name lookup, accessors, a drawing              | `use` its own drawing, utils                                 | know what it is bought for                     |
| `utils`         | a standard, a law, a geometry helper                                  | `use` other utils                                            | know a part                                    |

Imports use `use` unless the table says `include`. `include` passes on every global of the
included file, which is the coupling this document exists to prevent. It is therefore reserved for a
file that takes in its own data: a subassembly including the registries it resolves designations
from, or `bayonet_port.scad` including `bayonet_interfaces.scad`.

## The rules

1. **Decisions flow down; interfaces are read back.** A module takes what it consumes as an
   argument. A composer may read a subassembly accessor (`frame_outer_diameter()`,
   `head_gasket_factor()`) rather than rebuild the value. No file reads a global set by another
   file, or reaches into the state of a sibling. The one exception is the standalone preview in
   `head.scad`, which uses `frame.scad` to derive the joint. It is preview-only and stays.

2. **A designation is resolved where the choice is owned.** `bioreactor.scad` resolves the
   designations a build states, by name, through the `*_by_name()` function of the registry. A
   subassembly resolves its own `"auto"`. Geometry never searches a registry to decide what it
   needs. This is why a subassembly may include a registry and a part may not: the subassembly is
   sometimes the file being rendered. A standalone preview of a part may `use` a registry to select
   its example row by name.

3. **Narrowest coherent interface.** Pass a scalar when the consumer reads one physical fact, and
   the row when it depends on the identity of the part or on several of its fields. For example, a
   port takes the probe row, and a gasket takes a thickness. Pass an interface record when two
   halves must agree (`bayonet_interfaces`, the head-frame joint). Fields are read through
   accessors, never by index.

4. **Derive once.** The bolt circle, the joint diameter and the working volume are each one
   expression, in one file, passed on from there. A standalone preview calls the same function and
   never copies the result.

5. **A subassembly's parameters are live standalone defaults.** The build passes only the
   departures it states, as `[key, value]` pairs, so that "derive it" stays distinguishable from
   "not stated". `"auto"` is never packed.

6. **A registry row may name a row in another registry, inside the registry.** For example, a
   motor names its gearbox, and an interface names its o-ring. This is data describing data,
   resolved once. It is the only legitimate cross-registry `include`, and it does not permit
   geometry to do the same.

7. **Analysis and geometry are separate.** Functions derive values, report modules echo and assert,
   and geometry modules draw. A module that draws does not also carry the fit checks of everything it
   draws. Reports are read by people, so a report line is one line: the quantity, the value, the
   band and the source.

8. **Minimal.** Every argument is consumed. Every exported function has a caller. A wrapper that
   forwards its arguments unchanged is deleted. A comment says what a number is and why. Earlier
   values are in git and in [Decisions](decisions.md).

## Not yet settled

- Whether letting a subassembly resolve names itself (rule 2) is the right price for standalone
  rendering, or whether every name should resolve in the entry file, with `head.scad` carrying a
  small profile of its own. The second option removes eighteen includes from `head.scad`.
- How to split a subassembly into files without the pieces reading each other. `head()` is one
  module in three sections (derived values, checks and geometry). A module returns nothing, so the
  checks cannot move out without restating what they check. The next split will be by subsystem,
  where a real boundary appears.
