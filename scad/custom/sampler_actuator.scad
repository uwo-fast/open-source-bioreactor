/**
 * @file sampler_actuator.scad
 * @brief The syringe actuator as the sampler carries it, drawn from its own library
 * @author Cameron K. Brooks
 * @copyright 2026
 *
 * Its own file because sampler.scad includes NopSCADlib, whose assembly() shadows the actuator
 * library's: from here the library's is the only one in scope. Actuator frame: x along the syringe's
 * axis, the nozzle towards -x, z up from the plate's underside; sampler.scad places it.
 */

use <syringe-actuator/cad/main.scad>

// The actuator L in its body at crank angle a (180 is the plunger pushed in), with its syringe and
// motor. The body's own mount screws are left out: the sampler's face screws come up into it instead.
module sampler_actuator(L, a) {
  assembly(L, a, bought=true, body=false);
  color("lightsteelblue", 0.35) {
    body(get(L, "body"));
    lid(get(L, "body"));
    cap(get(L, "body"));
  }
}
