/**
 * @brief Look a registered row up by its name.
 *
 * A designation travels as a name, so every registry a build may designate wraps this below its
 * swept list, where the list is in scope (a function resolves globals from its own file):
 *
 *     use <../utils/registries.scad>;
 *     function shaft_by_name(name) = registry_by_name(shafts, name, "ssllsn");
 *
 * Rows are read by position, so `fields` says what a row carries: a signature, one letter a field -
 * s a string, n a number, l a list, b a bool, the capital where the field may also be undef - or
 * a list of signatures where a trailing field is optional. A bare count is accepted and checks the
 * length alone. Every row is checked on every lookup, the one asked for or not: a row that lost or
 * gained a field, or holds a list where a number goes, fails here rather than reading the wrong
 * value. Two fields of the same type swapped still pass; only named fields would catch that.
 *
 * A miss returns undef, and so does a duplicate name - two rows answering to one name is a defect,
 * not a pick by list order. The consumer owes the assert, because only it can name the registry
 * that was searched, and a failing assert exits 0 so its ERROR line is what the checks catch.
 */
function registry_by_name(rows, name, fields) =
  let (_checked = registry_checked(rows, fields))
  let (_m = [for (r = _checked) if (r[0] == name) r]) len(_m) == 1 ? _m[0] : undef;

// The rows, once every one fits one of the signatures; for a registry whose rows carry no name.
function registry_checked(rows, fields) =
  let (
    _n = is_list(fields) ? fields : [fields],
    _bad = [for (r = rows) if (len([for (f = _n) if (registry_row_fits(r, f)) f]) == 0) r[0]]
  )
  assert(len(_bad) == 0, str("registry rows ", _bad, " do not fit ", fields))
  rows;

function registry_row_fits(row, fields) =
  is_num(fields) ? len(row) == fields
  : len(row) == len(fields) && len([for (i = [0:len(fields) - 1]) if (!registry_field_fits(row[i], fields[i])) i]) == 0;

function registry_field_fits(v, t) =
  t == "s" ? is_string(v)
  : t == "n" ? is_num(v)
  : t == "l" ? is_list(v)
  : t == "b" ? is_bool(v)
  : t == "S" ? is_undef(v) || is_string(v)
  : t == "N" ? is_undef(v) || is_num(v)
  : t == "L" ? is_undef(v) || is_list(v)
  : t == "B" ? is_undef(v) || is_bool(v)
  : assert(false, str("registry signature letter \"", t, "\" is not one of s n l b S N L B"));
