/**
 * @brief Look a registered row up by its name.
 *
 * A designation travels as a name, so every registry a build may designate wraps this below its
 * swept list, where the list is in scope (a function resolves globals from its own file):
 *
 *     use <../utils/registries.scad>;
 *     function shaft_by_name(name) = registry_by_name(shafts, name);
 *
 * A miss returns undef, and so does a duplicate name - two rows answering to one name is a defect,
 * not a pick by list order. The consumer owes the assert, because only it can name the registry
 * that was searched, and a failing assert exits 0 so its ERROR line is what the checks catch.
 */
function registry_by_name(rows, name) =
  let (_m = [for (r = rows) if (r[0] == name) r]) len(_m) == 1 ? _m[0] : undef;
