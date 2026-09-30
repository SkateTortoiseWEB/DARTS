// Oche board-mount camera ring: 1:4 desk model, to look at and tinker with.
// Simplified from camera-mount.scad (the real parts would be too fine at this size). No screws needed:
// the board sits on a peg in the middle of the frame and turns on it, and each camera tilts on a hinge pin
// cut from 1.75 mm filament.
//
// Parts (openscad -D 'part="frame"' -o mini_frame.stl mini-model.scad):
//   "board"     the dartboard, 113 mm across, rings and wires engraved and numbers raised so it's easy to paint
//   "frame"     hub + three arms + columns with tilt forks, one piece (prints flat, columns up)
//   "camera"    one camera: case, lens, light on top, hinge tongue (print 3)
//   "surround"  optional foam-ring look-alike with the three slots
//   "assembly"  put together, for looking at
//   "print_1"   board + 3 cameras (one print on a 220 mm bed)
//   "print_2"   frame (one print)
// Print in PLA, 0.12-0.16 mm layers for the board, 3 walls, 20 % infill, no supports.

part = "assembly";
S = 0.25;                  // scale of the real thing
tilt_preview = 12;

board_d = 451*S;           // 112.75
board_t = 38*S;            // 9.5
cam_r = 300*S;             // 75: camera distance from the bull
lens_z = (38 + 40)*S;      // 19.5: lens height from the board's back
rings = [6.35, 15.9, 99, 107, 162, 170]*S;
ORDER = [20, 1, 18, 4, 13, 6, 10, 15, 2, 17, 3, 19, 7, 16, 8, 11, 14, 9, 12, 5];

// frame
hub_d = 46; hub_t = 3;
arm_w = 6; arm_t = 3;
col = 5;
peg_d = 6; peg_h = 3;
// camera and hinge (not to scale: sized to print and work)
box = 11; box_d = 5;       // case
tongue_t = 3; tongue_l = 5;
pin_d = 1.95;              // hole for a piece of 1.75 mm filament (tighten to 1.85 if it flops)
fork_w = 2.5; fork_gap = tongue_t + .4; fork_above = 3.5;
hinge_below_lens = box/2 + tongue_l - 2;                  // 8.5
col_top = lens_z - hinge_below_lens - fork_above;         // 7.5
$fn = 64;

module board() {
  difference() {
    cylinder(d = board_d, h = board_t, $fn = 160);
    // engraved rings and wires on the face
    for (r = rings) translate([0, 0, board_t - .6]) difference() { cylinder(r = r + .25, h = 1, $fn = 160); cylinder(r = r - .25, h = 2, center = true, $fn = 160); }
    for (i = [0:19]) rotate(-(i*18 + 9)) translate([-.25, rings[1], board_t - .6]) cube([.5, rings[5] - rings[1], 1]);
    // the frame's peg goes in here
    translate([0, 0, -.01]) cylinder(d = peg_d + .4, h = peg_h + .5);
  }
  // numbers, raised
  for (i = [0:19]) rotate(-i*18) translate([0, 48.5, board_t - .01]) linear_extrude(.6)
    text(str(ORDER[i]), size = 4.2, halign = "center", valign = "center", font = "Liberation Sans:style=Bold");
}

module frame() {
  // hub and peg (the board's back is at z = 0, the wall side is below)
  translate([0, 0, -hub_t]) cylinder(d = hub_d, h = hub_t);
  cylinder(d = peg_d, h = peg_h);
  for (a = [0, 120, 240]) rotate(a) {
    translate([0, -arm_w/2, -hub_t]) cube([cam_r + col/2, arm_w, arm_t]);
    translate([cam_r - col/2, -col/2, -hub_t]) cube([col, col, col_top + hub_t]);
    hull() { translate([cam_r - col/2 - 8, -arm_w/2, -hub_t]) cube([1, arm_w, arm_t]); translate([cam_r - col/2 - .5, -col/2, -hub_t]) cube([.5, col, 9]); }
    // tilt fork: the hinge runs round the board, so the camera looks in at the bull
    translate([cam_r, 0, col_top]) difference() {
      for (s = [-1, 1]) translate([-col/2, s*(fork_gap/2 + fork_w/2) - fork_w/2, 0]) {
        cube([col, fork_w, fork_above]);
        translate([col/2, 0, fork_above]) rotate([-90, 0, 0]) cylinder(d = col, h = fork_w);
      }
      translate([0, 0, fork_above]) rotate([90, 0, 0]) cylinder(d = pin_d, h = 20, center = true);
    }
  }
}

// camera: lens looks along +z here, hinge tongue hangs below (-y) with its pin hole along x
module camera() {
  difference() {
    union() {
      translate([-box/2, -box/2, 0]) cube([box, box, box_d]);                      // case
      translate([0, 0, box_d]) cylinder(d = 5, h = 1.2);                           // lens holder
      translate([0, 0, box_d + 1.2]) cylinder(d = 3.6, h = 1.6);                    // lens
      translate([-5, box/2, 0]) cube([10, 3.2, box_d]);                            // LED light on top
      translate([-tongue_t/2, -box/2 - tongue_l, 0]) cube([tongue_t, tongue_l + .5, box_d]);   // hinge tongue
      translate([0, -hinge_below_lens, box_d/2]) rotate([0, 90, 0]) cylinder(d = box_d, h = tongue_t, center = true);
    }
    translate([0, -hinge_below_lens, box_d/2]) rotate([0, 90, 0]) cylinder(d = pin_d, h = 20, center = true);
    translate([0, 0, box_d + 2.4]) cylinder(d = 2, h = 1);                          // lens glass
    translate([-3.5, box/2 + 2.6, -.01]) cube([7, 1, box_d + .02]);                 // light's diffuser line
  }
}

module surround() {   // foam ring look-alike, with slots for the columns and channels for the arms
  difference() {
    cylinder(d = 175, h = board_t, $fn = 160);
    translate([0, 0, -1]) cylinder(d = board_d + .6, h = 30, $fn = 160);
    for (a = [0, 120, 240]) rotate(a) {
      translate([cam_r - col/2 - 9, -col/2 - .5, -1]) cube([col + 10, col + 1, 30]);
      translate([board_d/2 - 1, -arm_w/2 - .3, -1]) cube([cam_r - board_d/2 + 2, arm_w + .6, arm_t + 1]);
    }
  }
}

module assembly() {
  color("orange") translate([0, 0, 0]) frame();
  color("#222") board();
  color("dimgray", .5) translate([0, 0, -hub_t]) surround();
  // camera's own axes: lens +z, tongue -y, hinge x. On the frame: hinge along -y (round the board), tongue down, lens in at the bull
  for (a = [0, 120, 240]) rotate(a)
    translate([cam_r, 0, col_top + fork_above]) rotate([0, -tilt_preview, 0])
      multmatrix([[0, 0, -1, 0], [-1, 0, 0, 0], [0, 1, 0, 0], [0, 0, 0, 1]]) translate([0, hinge_below_lens, -box_d/2]) color("steelblue") camera();
}

if (part == "board") board();
else if (part == "frame") translate([0, 0, hub_t]) frame();
else if (part == "camera") camera();
else if (part == "surround") surround();
else if (part == "print_1") { translate([-20, 0, 0]) board(); for (i = [0:2]) translate([60, -40 + i*27, 0]) camera(); }
else if (part == "print_2") translate([0, 0, hub_t]) frame();
else assembly();
