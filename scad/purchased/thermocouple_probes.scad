// parameters for physical realization of various thermocouple probes
// DO NOT FORMAT THIS FILE, as it is manually spaced out for readability

// All Type K, 304 stainless sheath, grounded junction, 4 ft fiberglass lead, rated to 900 F -
// far past anything this reactor does, including autoclaving. What separates the rows is the
// thread they screw into, how far they reach, and how thick the sheath is.

// The row names its NPT thread rather than transcribing the thread's diameter, so the port that
// cuts it and the probe that screws in read the same row - see utils/npt_threads.scad. The hex
// and the body follow from that thread, so they are derived in the accessors and are not here.

// Thread size is a geometry decision, not just a plumbing one: a 1/2 NPT mount needs the full-size
// bayonet, while 1/8 NPT fits a smaller one. On a twelve-port lid that is the difference between
// seven big ports and six, and so between a 142 mm and a 130 mm smallest mouth - see
// docs/ports-layout.md.

// INSULATED vs noninsulated is the ungrounded-junction option. It costs more and is worth checking
// before choosing: a grounded sheath puts the probe electrically in the culture alongside the pH
// and DO electrodes, which is the classic source of ground-loop error in those readings. Whether
// this rig needs the isolated variant has NOT been established - flagged, not decided.

// Lengths are the nominal inch immersion depths, 76.2 / 152.4 / 228.6 / 304.8 mm. Pick one that
// reaches the culture without fouling the impeller; nothing here checks that for you yet.

// The rows name a registered NPT thread rather than transcribing its diameter, so this has to be
// included here and not left to whoever includes this file - a consumer reaching it through `use`
// would leave every thread undef and every port sized as if it had none.
include <../utils/npt_threads.scad>;

//                                     ["name"               part_no      thread     [neck_d, neck_h, flats_h, body_h, tip_d,  tip_h,  wire_d, wire_h]]
generic_thermocouple_probe =           ["generic",           "",          npt_1_2,   [10,     12,     5,       20,     3.5,    115,    2.5,    10    ]];

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

// The swept list carries REAL parts only. generic_thermocouple_probe stays defined and out of it:
// its part number is "" because there is nothing to order - it is a shape, not a product - and a
// placeholder in here would make "it builds" cover a probe nobody can buy. A real part that has
// been discontinued is a different case and stays swept, with the deviation recorded beside the
// list. Same treatment as generic_vessel, atlas_probe and generic_strip_light.
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
// A row from its name - see utils/registries.scad. A miss returns undef; the consumer asserts.
function thermocouple_probe_by_name(name) = registry_by_name(thermocouple_probes, name);

// example usage - keep commented, this file is include'd
// thermocouple_probe(mcmaster_3872K117_thermocouple_probe, position_base=true);
