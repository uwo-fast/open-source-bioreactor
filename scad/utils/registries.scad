/**
 * @brief Look a registered row up by its name.
 *
 * A designation travels as a NAME, not as a row: a customizer parameter set carries VALUES, not
 * references, so a .json can say "jar_10L_220x305" but cannot say the variable of that name. Every
 * registry that a build may designate therefore needs a by-name lookup, and vessels.scad has had
 * one since the first parameter set. This is that function with the rows list lifted out, so the
 * other registries get it in one line instead of a copy each.
 *
 * THE ROWS LIST IS AN ARGUMENT, and that is not a style choice. A function resolves globals from
 * its OWN file, so a lookup written here could never see `shafts` or `orings` - it has to be handed
 * them. Each registry wraps this below its swept list, where the list is in scope:
 *
 *     use <../utils/registries.scad>;
 *     function shaft_by_name(name) = registry_by_name(shafts, name);
 *
 * A MISS RETURNS UNDEF, and the CONSUMER owes the assert. That split is deliberate: this file
 * cannot name the registry that was searched, and "no row called X" is useless without it. It also
 * matters more than it looks - a failing assert exits 0 in OpenSCAD, so the assert's ERROR line on
 * stderr is the only thing the justfile's greps can catch. A lookup that quietly returned undef
 * into geometry would render a lid full of undef and report success.
 *
 * A DUPLICATE NAME ALSO RETURNS UNDEF rather than the first match, which is what vessel_by_name has
 * always done. Two rows answering to one name is a defect in the registry, and returning either one
 * would pick a part by list order. That is why the consumer's assert should say "or registered
 * twice" rather than only "no such row".
 *
 * "auto" never reaches here. It is a mode, not a name, and the consumer branches on it before
 * resolving - see docs/design-conventions.md, "Three layers, and where a parameter lives".
 */
function registry_by_name(rows, name) =
  let (_m = [for (r = rows) if (r[0] == name) r]) len(_m) == 1 ? _m[0] : undef;
