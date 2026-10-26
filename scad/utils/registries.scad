/**
 * @brief Look a registered row up by its name.
 *
 * A designation travels as a name, so every registry a build may designate wraps this below its
 * swept list, where the list is in scope (a function resolves globals from its own file):
 *
 *     use <../utils/registries.scad>;
 *     function shaft_by_name(name) = registry_by_name(shafts, name, 6);
 *
 * Rows are read by position, so `fields` is how many a row carries, or the list of counts allowed
 * where a trailing field is optional. Every row is checked on every lookup, the one asked for or
 * not: a row that lost or gained a field fails here rather than reading its neighbour's value.
 *
 * A miss returns undef, and so does a duplicate name - two rows answering to one name is a defect,
 * not a pick by list order. The consumer owes the assert, because only it can name the registry
 * that was searched, and a failing assert exits 0 so its ERROR line is what the checks catch.
 */
function registry_by_name(rows, name, fields) =
  let (
    _n = is_list(fields) ? fields : [fields],
    _bad = [for (r = rows) if (len([for (n = _n) if (len(r) == n) n]) == 0) r[0]]
  )
  assert(len(_bad) == 0, str("registry rows ", _bad, " do not carry ", fields, " fields"))
  let (_m = [for (r = rows) if (r[0] == name) r]) len(_m) == 1 ? _m[0] : undef;
