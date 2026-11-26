/**
 * @brief Look up a registered row by name.
 *
 * Build designations are passed as names, so every registry a build can designate wraps this
 * function below its list, where the list is in scope (a function resolves globals from its own
 * file):
 *
 *     use <../utils/registries.scad>;
 *     function shaft_by_name(name) = registry_by_name(shafts, name, "ssllsn");
 *
 * Rows are read by position, so `fields` describes the row layout. It is a signature with one
 * letter per field (s string, n number, l list, b bool; upper case if the field may also be
 * undef), or a list of signatures when a trailing field is optional. A plain number is also
 * accepted and checks only the length. Every row is checked on every lookup, not only the
 * requested one. A row with a missing or extra field, or a list where a number belongs, fails here
 * instead of returning the wrong value. Two swapped fields of the same type still pass; only named
 * fields would catch that.
 *
 * A missing name returns undef, and so does a duplicate name: two rows with the same name is a
 * defect, not a choice by list order. The caller must assert on the result, because only it can
 * name the registry searched. A failing assert exits 0, so the checks detect its ERROR line.
 */
function registry_by_name(rows, name, fields) =
  let (_checked = registry_checked(rows, fields))
  let (_m = [for (r = _checked) if (r[0] == name) r]) len(_m) == 1 ? _m[0] : undef;

// Returns the rows after checking that each fits one of the signatures. Also used directly for a
// registry whose rows have no name.
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
