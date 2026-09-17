# Architecture

Where a number is allowed to come from. `design-conventions.md` says how a number is justified;
this says who may hand it to whom. It is normative: a file that breaks a rule here is a defect, and
the audit of which files do is in `TODO.md`, not here.

## The layers

```
bioreactor.scad        the build: designations resolved, coupling derived once, head + frame composed
  ├── head.scad        subassembly: takes its coupling as arguments, standalone defaults
  ├── frame.scad       subassembly, same contract
  │     ├── custom/    printed parts: arguments in, geometry out
  │     ├── purchased/ bought parts: registry rows, accessors, a drawing of the vitamin
  │     └── utils/     standards and laws: thread tables, gland ratios, physics, geometry helpers
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

`use` unless it says `include`. `include` hands over every global of the included file, which is
the coupling this document exists to stop, so it is reserved for a file taking its own data: a
subassembly including the registries it resolves designations from, `bayonet_port.scad` including
`bayonet_interfaces.scad`.

## The rules

1. **Decisions flow down; interfaces are read back.** A module takes what it consumes as an
   argument. A composer may read a subassembly's accessor (`frame_outer_diameter()`,
   `head_gasket_factor()`) rather than rebuild the value. Nobody reads a global another file set,
   and no file reaches into a sibling's state. The one sideways read is `head.scad`'s standalone
   preview using `frame.scad` to derive the joint; it is preview-only and stays.

2. **A designation is resolved where the choice is owned.** `bioreactor.scad` resolves what a build
   states, by name through the registry's `*_by_name()`; a subassembly resolves its own `"auto"`.
   Geometry never browses a registry to decide what it wants. This is why a subassembly may include
   a registry and a part may not: the subassembly is sometimes the file being rendered. A part's
   standalone preview may `use` a registry to pick its example row by name.

3. **Narrowest coherent interface.** A scalar when the consumer reads one physical fact; the row
   when it depends on the part's identity or several of its fields (a port takes the probe row, a
   gasket takes a thickness); an interface record when two halves must agree (`bayonet_interfaces`,
   the head-frame joint). Fields are read through accessors, never by index.

4. **Derive once.** The bolt circle, the joint diameter, the working volume: one expression, in one
   file, handed on. A standalone preview calls the same function; it never quotes the result.

5. **A subassembly's parameters are live standalone defaults.** The build passes only the
   departures it states, as `[key, value]` pairs, so "derive it" stays distinguishable from "not
   stated". `"auto"` is never packed.

6. **A registry row may name another registry's row, inside the registry.** A motor naming its
   gearbox, an interface naming its o-ring: data describing data, resolved once. It is the one
   cross-registry `include` that is honest, and it is not a licence for geometry to do the same.

7. **Analysis and geometry are separate.** Functions derive; a report module echoes and asserts; a
   geometry module draws. A module that draws does not also carry the fit checks of everything it
   draws. Reports are read by people, so a report line is one line: the quantity, the value, the
   band and the source.

8. **Minimal.** Every argument is consumed. Every exported function has a caller. A wrapper that
   forwards its arguments unchanged is deleted. A comment says what a number is and why; what it
   used to be is in git and `decisions.md`.

## Not yet settled

- Whether a subassembly resolving names itself (rule 2) is the right price for rendering
  standalone, or whether every name resolves in the entry file and `head.scad` carries a tiny
  profile of its own. The second removes eighteen includes from `head.scad`.
- How a subassembly splits into files without the pieces reading each other. `head()` is one
  module in three sections - derived, checks, geometry - because a module returns nothing, so the
  checks cannot move out without restating what they check. The next cut is by subsystem, where a
  real boundary shows.
