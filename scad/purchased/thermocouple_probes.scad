// parameters for physical realization of various thermocouple probes
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

// All Type K, 304 sheath, grounded junction, 4 ft fiberglass lead, rated to 900 F. The rows differ
// by thread, reach and sheath diameter. The row names its NPT thread (utils/npt_threads.scad);
// hex and body derive from it.
//
// Ungrounded ("insulated") is the option to check: a grounded sheath puts the probe electrically
// in the culture beside the pH and DO electrodes, the classic ground-loop source. Not decided.
//
// Lengths are the nominal inch immersion depths, 76.2 / 152.4 / 228.6 / 304.8 mm.
include <../utils/npt_threads.scad>;

//                                       ["name"               part_no      thread     [neck_d, neck_h, flats_h, body_h, tip_d,  tip_h,  wire_d, wire_h]]
generic_thermocouple_probe =             ["generic",           "",          npt_1_2,   [10,     12,     5,       20,     3.5,    115,    2.5,    10    ]];

// 1/8 NPT male - the small-mount option, and the only one a reduced-size port can take.
mcmaster_3872K127_thermocouple_probe   = ["mcmaster_3872K127",  "3872K127",  npt_1_8,  [6,      10,     4,       15,     3.175,  76.2,   3,      25   ]];  // 3 in x 1/8 in
mcmaster_3872K128_thermocouple_probe   = ["mcmaster_3872K128",  "3872K128",  npt_1_8,  [6,      10,     4,       15,     4.7625, 76.2,   3,      25   ]];  // 3 in x 3/16 in
mcmaster_3872K129_thermocouple_probe   = ["mcmaster_3872K129",  "3872K129",  npt_1_8,  [6,      10,     4,       15,     3.175,  152.4,  3,      25   ]];  // 6 in x 1/8 in
mcmaster_3872K13_thermocouple_probe    = ["mcmaster_3872K13",   "3872K13",   npt_1_8,  [6,      10,     4,       15,     4.7625, 152.4,  3,      25   ]];  // 6 in x 3/16 in
mcmaster_3872K131_thermocouple_probe   = ["mcmaster_3872K131",  "3872K131",  npt_1_8,  [6,      10,     4,       15,     3.175,  228.6,  3,      25   ]];  // 9 in x 1/8 in
mcmaster_3872K132_thermocouple_probe   = ["mcmaster_3872K132",  "3872K132",  npt_1_8,  [6,      10,     4,       15,     4.7625, 228.6,  3,      25   ]];  // 9 in x 3/16 in
mcmaster_3872K133_thermocouple_probe   = ["mcmaster_3872K133",  "3872K133",  npt_1_8,  [6,      10,     4,       15,     3.175,  304.8,  3,      25   ]];  // 12 in x 1/8 in
mcmaster_3872K134_thermocouple_probe   = ["mcmaster_3872K134",  "3872K134",  npt_1_8,  [6,      10,     4,       15,     4.7625, 304.8,  3,      25   ]];  // 12 in x 3/16 in

// 1/2 NPT male - what the design uses today.
mcmaster_1245N29_thermocouple_probe    = ["mcmaster_1245N29",   "1245N29",   npt_1_2,  [10,     12,     5,       20,     3.175,  76.2,   3,      25   ]];  // 3 in x 1/8 in
mcmaster_1245N25_thermocouple_probe    = ["mcmaster_1245N25",   "1245N25",   npt_1_2,  [10,     12,     5,       20,     4.7625, 76.2,   3,      25   ]];  // 3 in x 3/16 in, ungrounded
mcmaster_1245N12_thermocouple_probe    = ["mcmaster_1245N12",   "1245N12",   npt_1_2,  [10,     12,     5,       20,     4.7625, 76.2,   3,      25   ]];  // 3 in x 3/16 in
mcmaster_1245N31_thermocouple_probe    = ["mcmaster_1245N31",   "1245N31",   npt_1_2,  [10,     12,     5,       20,     3.175,  152.4,  3,      25   ]];  // 6 in x 1/8 in
mcmaster_1245N26_thermocouple_probe    = ["mcmaster_1245N26",   "1245N26",   npt_1_2,  [10,     12,     5,       20,     4.7625, 152.4,  3,      25   ]];  // 6 in x 3/16 in, ungrounded
mcmaster_1245N15_thermocouple_probe    = ["mcmaster_1245N15",   "1245N15",   npt_1_2,  [10,     12,     5,       20,     4.7625, 152.4,  3,      25   ]];  // 6 in x 3/16 in
mcmaster_3872K117_thermocouple_probe   = ["mcmaster_3872K117",  "3872K117",  npt_1_2,  [10,     12,     5,       20,     3.175,  228.6,  3,      25   ]];  // 9 in x 1/8 in
mcmaster_1245N18_thermocouple_probe    = ["mcmaster_1245N18",   "1245N18",   npt_1_2,  [10,     12,     5,       20,     4.7625, 228.6,  3,      25   ]];  // 9 in x 3/16 in
mcmaster_3872K118_thermocouple_probe   = ["mcmaster_3872K118",  "3872K118",  npt_1_2,  [10,     12,     5,       20,     3.175,  304.8,  3,      25   ]];  // 12 in x 1/8 in
mcmaster_1245N22_thermocouple_probe    = ["mcmaster_1245N22",   "1245N22",   npt_1_2,  [10,     12,     5,       20,     4.7625, 304.8,  3,      25   ]];  // 12 in x 3/16 in

// Real parts only; generic_thermocouple_probe stays defined and out of it.
thermocouple_probes = [mcmaster_3872K127_thermocouple_probe,
  mcmaster_3872K128_thermocouple_probe, mcmaster_3872K129_thermocouple_probe,
  mcmaster_3872K13_thermocouple_probe, mcmaster_3872K131_thermocouple_probe,
  mcmaster_3872K132_thermocouple_probe, mcmaster_3872K133_thermocouple_probe,
  mcmaster_3872K134_thermocouple_probe, mcmaster_1245N29_thermocouple_probe,
  mcmaster_1245N25_thermocouple_probe, mcmaster_1245N12_thermocouple_probe,
  mcmaster_1245N31_thermocouple_probe, mcmaster_1245N26_thermocouple_probe,
  mcmaster_1245N15_thermocouple_probe, mcmaster_3872K117_thermocouple_probe,
  mcmaster_1245N18_thermocouple_probe, mcmaster_3872K118_thermocouple_probe,
  mcmaster_1245N22_thermocouple_probe];

use <thermocouple_probe.scad>;

use <../utils/registries.scad>;
function thermocouple_probe_by_name(name) = registry_by_name(thermocouple_probes, name);

// example usage - keep commented, this file is include'd
// thermocouple_probe(mcmaster_3872K117_thermocouple_probe, position_base=true);
