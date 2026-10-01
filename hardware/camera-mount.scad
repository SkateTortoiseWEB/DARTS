// Oche camera + light mounts for a dartboard (made for a Winmau Blade 6)
// Two ways to hold the cameras:
//   BOARD MOUNT (no holes in the wall): a hub sits between the back of the board and its Winmau hanging bracket,
//     held by the board's own centre screw. Three arms bolt into it, reach out behind the board and come forward
//     past its edge (through small slots cut in a foam surround) to hold each camera in front of the board.
//     The cameras move with the board, so calibration stays put.
//   WALL MOUNT: one arm per camera, screwed to the wall.
// Camera: 38 x 38 mm OV9732 USB board (DECXIN-1M-2012V1), M2.5 holes on a 34 mm square, M12 lens.
// Lens (maker's drawing): 2.84 mm, F2.0, field of view 65.1 deg across, 51.2 deg up/down, 77.3 deg diagonal;
// 13 mm square holder, lens top 9.6 mm above the board's front.
//
// Parts (set `part` below, or on the command line: openscad -D 'part="case_tub"' -o case_tub.stl camera-mount.scad)
//   "case_tub"   back of the camera case: holds the board, cable exit, vents, tilt hinge tongue
//   "case_lid"   front of the case: lens opening and the light tray above it (up to three 8 mm COB LED strip pieces)
//   "wall_arm"   one piece: plate that screws to the wall + column + tilt fork. The screw slots let it turn
//                about 12 degrees either way, so point the arrow at the bull before tightening
//   "assembly"   wall mount put together, for looking at (don't print this)
//   "print_all"  wall mount: case + wall arm laid out for printing
// Board mount parts (print 1 hub, 3 of everything else):
//   "hub"        backplate disc, 180 mm: fits a 220 mm printer bed
//   "arm_inner"  inner half of an arm (bolts into the hub)
//   "arm_outer"  outer half: column and tilt fork for the camera case
//   "splice"     small plate that joins the two arm halves (goes on the board side)
//   "board_assembly"  the whole board mount put together, for looking at
//   "print_board"     one hub + one set of arm parts laid out (each also fits the bed on its own)
//
// Board mount hardware: the board's centre screw, about 10 mm longer than now; per arm 2 x M4 x 10 countersunk bolts + nuts,
//   4 x M3 x 10 countersunk bolts + nuts (splice); optional 3 x wood screws 3.5 x 20 to stop the hub turning.
// Camera: 4 x M2 x 12 countersunk screws per case (through the lid and board, self-tapping into the tub's posts).
// Wall mount hardware:
//   1 x M3 x 20 bolt + nut (tilt), 2 x pan-head wood screws ~4 x 30 + washers + wall plugs.
// Put the board in the case with its USB connector towards the side with the cable slot (+x).
// Cables: the camera's USB cable leaves the case on one side and the light's USB lead leaves the light tray on the other;
//   on the board mount each runs down its own side: snap-in clips on the column, open cradles plus a cable tie on the arm.
// Print in PETG or ASA, 4 walls, 40 % infill, no supports needed in the orientations "print_all" uses.

part = "assembly";

/* ---------- measure these on your setup ---------- */
board_face_from_wall = 45;   // how far the dartboard's face sits out from the wall (Blade 6 ~38 mm thick + bracket)
lens_above_face      = 40;   // how far in front of the board face the lens should be (30-50 works)
tilt_preview         = 12;   // tilt towards the board in the assembly preview only, degrees
show_env             = true; // board_assembly preview: show the wall and foam surround

/* ---------- board mount: measure these ---------- */
board_d     = 451;   // dartboard diameter (Blade 6: 451)
board_t     = 38;    // dartboard thickness, front to back (Blade 6: about 38)
cam_r       = 300;   // camera distance from the bull: 300 for the OV9732's own 65 deg lens (sees the doubles ring with ~20 mm spare each side), 260-280 for a 2.1 mm lens
screw_d     = 6.5;   // hole for the board's centre screw
hub_d       = 180;   // hub diameter (Ender 3 bed is 220)
hub_t       = 10;    // hub thickness: the board sits this much further from the wall
arm_w       = 22;    // arm width
arm_t       = 6;     // arm thickness (sits in grooves in the hub, flush with its wall side)
split_r     = 165;   // where the two arm halves join

/* ---------- camera board ---------- */
pcb      = 38;     // board is pcb x pcb
pcb_t    = 1.6;
hole_sp  = 34;     // mounting holes are on a hole_sp square
holder   = 13;     // square lens holder on the front (8 mm tall; lens top 9.6 mm, so it stands 3 mm proud of the lid)
front_gap = 4;     // space between board front and lid (parts + lens holder screw ears)
back_gap  = 7;     // space behind the board (the connector sticks out 5.1 mm)
// screws that hold the board: M2 (the board's 2.55 mm holes take M2 or M2.5)
screw_pilot = 1.6;   // hole in the posts the screws self-tap into (M2.5: 2.1)
screw_clear = 2.4;   // hole through the lid (M2.5: 2.9)
screw_head  = 4.2;   // countersink for the head (M2.5: 5.4)

/* ---------- light: a tray above the lens for short pieces of 5 V COB LED strip ---------- */
light_w     = 56;     // tray width (along the strips)
light_h     = 32;     // tray height above the case
light_t     = 4;      // tray thickness
strip_w     = 8;      // COB strip width (8 mm is the common 320 LEDs/m strip)
strip_rows  = 3;      // grooves: use the middle one for a single piece, all three for a brighter light
strip_len   = 43;     // longest piece that fits a groove
strip_depth = 1.0;    // groove depth; the strip stands a little proud
strip_pitch = strip_w + 1.4;

/* ---------- cables ---------- */
cable_d   = 4.4;      // clip hole: fits USB cables up to about 4.4 mm thick
clip_wall = 1.6;
clip_gap  = 2.8;      // opening the cable snaps in through
clip_len  = 10;

/* ---------- general ---------- */
wall = 2;
lid_t = 2.5;
clr = 0.3;          // fit clearance
$fn = 48;

inner = pcb + 2*clr;                  // tub inside width
outer = inner + 2*wall;
tub_floor_z = -pcb_t - back_gap - wall;   // board front is z = 0, lens points +z
lid_z = front_gap;                    // lid inner face

// tilt hinge: tongue under the case (the side that faces the wall), axis along x
tongue_t = 6;
tongue_len = 15;
hinge_y = -(outer/2 + tongue_len - 5);        // hole centre, relative to the lens axis
hinge_z = (tub_floor_z + lid_z)/2;

// arm
plate_t = 6;
fork_gap = tongue_t + 0.6;
fork_w = 5;
col_w = fork_gap + 2*fork_w; col_d = 16;
fork_above = 9;            // hole centre above the column top
slot_r = 24;               // screw slots, radius from the column centre
cam_from_wall = board_face_from_wall + lens_above_face;
col_h = cam_from_wall - plate_t - fork_above - (-hinge_y);
assert(col_h > 4, "Arm too short for these settings: increase board_face_from_wall or lens_above_face");

/* ---------- helpers ---------- */
// ring of wedge-shaped teeth on the z = 0 plane, pointing +z. Two of these facing each other lock at any 15 deg step.
module rosette(r_in, r_out, n = 24, h = 0.9) {
  p = 360/n;
  for (i = [0:n-1]) rotate(i*p)
    hull() for (pt = [[r_in*cos(-p/2), r_in*sin(-p/2), 0], [r_in*cos(p/2), r_in*sin(p/2), 0], [r_in, 0, h],
                      [r_out*cos(-p/2), r_out*sin(-p/2), 0], [r_out*cos(p/2), r_out*sin(p/2), 0], [r_out, 0, h]])
      translate(pt) cube(0.01, center = true);
}
module hexnut_pocket(flats, depth) { cylinder(d = flats/cos(30), h = depth, $fn = 6); }
module rbox(size, r = 2) {   // box with rounded vertical edges, centred in x/y, from z = 0
  hull() for (x = [-1, 1], y = [-1, 1]) translate([x*(size[0]/2 - r), y*(size[1]/2 - r), 0]) cylinder(r = r, h = size[2]);
}

/* ---------- case tub (back half) ---------- */
module case_tub() {
  difference() {
    union() {
      translate([0, 0, tub_floor_z]) rbox([outer, outer, lid_z - tub_floor_z]);
      // tilt tongue under the case
      translate([-tongue_t/2, -outer/2 - tongue_len, tub_floor_z]) cube([tongue_t, tongue_len + 1, lid_z - tub_floor_z]);
      translate([0, hinge_y, hinge_z]) rotate([0, 90, 0]) cylinder(d = 12, h = tongue_t, center = true);
    }
    // inside
    translate([0, 0, tub_floor_z + wall]) rbox([inner, inner, 50], r = 1);
    // cable exit at the bottom of the back (connector side), with room for the plug
    translate([outer/2 - wall - 1, -7, tub_floor_z + wall]) cube([wall + 2, 14, back_gap - 1]);
    // vents in the back
    for (x = [-12, -6, 0, 6, 12]) translate([x - 1.2, -8, tub_floor_z - 1]) cube([2.4, 20, wall + 2]);
    // tilt bolt hole
    translate([0, hinge_y, hinge_z]) rotate([0, 90, 0]) cylinder(d = 3.4, h = 20, center = true);
  }
  // posts the board sits on; the screws self-tap into them
  for (x = [-1, 1], y = [-1, 1]) translate([x*hole_sp/2, y*hole_sp/2, tub_floor_z + wall - 0.01])
    difference() { cylinder(d = 4.4, h = back_gap + 0.01); cylinder(d = screw_pilot, h = 50); }
  // teeth on both faces of the tongue
  for (s = [-1, 1]) translate([s*tongue_t/2, hinge_y, hinge_z]) rotate([0, s*90, 0]) rosette(2.2, 5.8);
  // cable tie anchor under the cable exit (strain relief)
  translate([outer/2 + 2.5, 0, tub_floor_z + 1.5]) difference() {
    cube([6, 16, 3], center = true);
    cube([8, 4, 1.6], center = true);
  }
}

/* ---------- case lid (front half + light plate) ---------- */
module case_lid() {
  zf = lid_z + lid_t;                       // front face: lid and light tray are flush
  yc = outer/2 + light_h/2;                 // middle of the tray
  gx0 = -light_w/2 + 12;                    // where the strip grooves start (the USB end)
  difference() {
    union() {
      translate([0, 0, lid_z]) rbox([outer, outer, lid_t]);
      // light tray above the lens: joins the lid at the front, thicker behind where it clears the tub
      translate([-light_w/2, outer/2 - 2, lid_z]) cube([light_w, light_h + 2, lid_t]);
      translate([0, outer/2 + clr + .2 + (light_h - clr - .2)/2, zf - light_t]) rbox([light_w, light_h - clr - .2, light_t], r = 3);
      // lip that sits inside the tub so the lid registers
      translate([0, 0, lid_z - 1.5]) rbox([inner - 0.4, inner - 0.4, 1.6], r = 1);
    }
    // hollow the lip
    translate([0, 0, lid_z - 2]) rbox([inner - 3.4, inner - 3.4, 2], r = 1);
    // lens holder passes through
    translate([0, 0, lid_z - 5]) linear_extrude(20) square(holder + 1, center = true);
    // screw holes with countersinks
    for (x = [-1, 1], y = [-1, 1]) translate([x*hole_sp/2, y*hole_sp/2, 0]) {
      cylinder(d = screw_clear, h = 50, center = true);
      translate([0, 0, zf - (screw_head - screw_clear)/2]) cylinder(d1 = screw_clear, d2 = screw_head, h = (screw_head - screw_clear)/2 + .01);
    }
    // grooves for the strip pieces, USB end at -x
    for (i = [0:strip_rows - 1]) translate([gx0, yc + (i - (strip_rows - 1)/2)*strip_pitch - (strip_w + .6)/2, zf - strip_depth])
      cube([strip_len, strip_w + .6, 5]);
    // channel across the far ends for the short wires that join extra pieces (+ to +, - to -)
    translate([gx0 + strip_len - 4, yc - (strip_rows - 1)/2*strip_pitch - 3, zf - 1.8]) cube([4, (strip_rows - 1)*strip_pitch + 6, 5]);
    // pocket for the lump where the USB lead joins the strip, and a notch where the lead leaves the tray
    translate([-light_w/2 + 2, yc - 5.5, zf - 2.4]) cube([gx0 + light_w/2 - 2 + .01, 11, 5]);
    translate([-light_w/2 - 1, yc - 2.5, zf - 2.4]) cube([4, 5, 5]);
    // cable tie slots either side of the pocket: tie the lead down so a tug can't pull the strip off
    for (y = [-1, 1]) translate([-light_w/2 + 6.5, yc + y*9.5, 0]) cube([3.2, 5, 50], center = true);
  }
  // spacers that clamp the board (sit on the board around its holes)
  for (x = [-1, 1], y = [-1, 1]) translate([x*hole_sp/2, y*hole_sp/2, 0])
    difference() { cylinder(d = 4.4, h = lid_z); cylinder(d = screw_clear, h = 50, center = true); }
}
// the LED strip pieces, for previews only
module light_strips(n = strip_rows) {
  for (i = [0:n - 1]) translate([-light_w/2 + 12.5, outer/2 + light_h/2 + (i - (n - 1)/2)*strip_pitch - strip_w/2, lid_z + lid_t - strip_depth])
    { color("white") cube([strip_len - 1, strip_w, 1.6]); color("gold") translate([0, strip_w/2 - 1.5, 1.6]) cube([strip_len - 1, 3, .1]); }
}

/* ---------- cable clips ---------- */
clip_b = cable_d + 2*clip_wall;             // clip block size
// cable cradle on the +y side face of an arm (face at y = arm_w/2), running along x. Open at the top, nothing flexes:
// printed flat, a snap-in clip's lips would bend across the layer lines and snap off. The cable lies in it and a
// cable tie through the slot in the arm goes under, round the cradle and over the cable.
cradle_h = arm_t;                           // flush with the arm (cable_d + clip_wall must stay <= arm_t)
module arm_clip(x) {
  translate([x, arm_w/2, arm_z0]) difference() {
    translate([-clip_len/2, -.8, 0]) cube([clip_len, cable_d + .2 + 2 + .8, cradle_h]);
    hull() { translate([0, (cable_d + .2)/2, clip_wall + cable_d/2]) rotate([0, 90, 0]) cylinder(d = cable_d + .2, h = clip_len + 2, center = true);
             translate([-clip_len/2 - 1, 0, clip_wall + cable_d/2]) cube([clip_len + 2, cable_d + .2, cradle_h]); }
  }
}
// slot for the cable tie, through the arm beside each cradle
module arm_clip_tie(x) { translate([x, arm_w/2 - 2, arm_z0 + arm_t/2]) cube([4.2, 2, arm_t + 2], center = true); }
// vertical clip on the +y side face of the column, opening outwards; the slope underneath prints without support
module col_clip(z) {
  translate([cam_r, col_w/2, 0]) difference() {
    hull() { translate([-clip_b/2, -.8, z]) cube([clip_b, clip_b + .8, clip_len]); translate([-clip_b/2, -.8, z - clip_b - 1]) cube([clip_b, .8, .01]); }
    translate([0, clip_b/2, z - clip_b - 2]) cylinder(d = cable_d, h = clip_len + clip_b + 4);
    translate([-clip_gap/2, clip_b/2, z - clip_b - 2]) cube([clip_gap, clip_b, clip_len + clip_b + 4]);
  }
}

/* ---------- wall arm: plate + column + fork, one piece ---------- */
module wall_arm() {
  difference() {
    hull() { cylinder(r = 15, h = plate_t); for (x = [-1, 1]) translate([x*slot_r, 0, 0]) cylinder(r = 9, h = plate_t); }
    // curved slots for the wall screws: turn the plate up to 12 degrees either way before tightening
    for (x = [-1, 1]) rotate(x > 0 ? 0 : 180)
      for (a = [-12:2:10]) hull() for (b = [a, a + 2]) rotate(b) translate([slot_r, 0, -1]) cylinder(d = 4.6, h = plate_t + 2);
    // arrow showing which way the camera looks: point it at the bull
    translate([0, 0, plate_t - 0.8]) linear_extrude(1) polygon([[0, -14.5], [-3.5, -11], [-1.2, -11], [-1.2, -8.5], [1.2, -8.5], [1.2, -11], [3.5, -11]]);
  }
  // column
  translate([-col_w/2, -col_d/2, plate_t - 0.01]) cube([col_w, col_d, col_h + 0.02]);
  // fork at the top: the case tongue fits between the prongs
  translate([0, 0, plate_t + col_h]) difference() {
    union() for (s = [-1, 1]) translate([s*(fork_gap/2 + fork_w/2), 0, 0]) {
      translate([-fork_w/2, -col_d/2, 0]) cube([fork_w, col_d, fork_above]);
      translate([0, 0, fork_above]) rotate([0, 90, 0]) cylinder(d = col_d, h = fork_w, center = true);
    }
    translate([0, 0, fork_above]) rotate([0, 90, 0]) cylinder(d = 3.4, h = 50, center = true);
    // nut trap on one prong
    translate([fork_gap/2 + fork_w - 2.4, 0, fork_above]) rotate([0, 90, 0]) rotate(30) hexnut_pocket(5.8, 5);
  }
  // teeth on the inside faces of the prongs
  for (s = [-1, 1]) translate([s*fork_gap/2, 0, plate_t + col_h + fork_above]) rotate([0, -s*90, 0]) rosette(2.2, 5.8);
}

/* ---------- board mount ---------- */
// coordinates: x = out from the bull, z = 0 at the back of the dartboard, + towards the front, - towards the wall
lens_z = board_t + lens_above_face;                       // camera lens height in front of the board's back
b_col_top = lens_z - fork_above - (-hinge_y);             // top of the column the fork sits on
assert(cam_r - col_d/2 > board_d/2 + 3, "cam_r puts the column into the board: make it bigger");
arm_z0 = -hub_t;                                          // arms: wall-side face flush with the hub's
module m4_cs(){ cylinder(d = 4.5, h = 60, center = true); translate([0, 0, -2.6]) cylinder(d1 = 4.5, d2 = 9, h = 2.61); }   // countersink opening at z = 0
module m3_cs(){ cylinder(d = 3.4, h = 60, center = true); translate([0, 0, -1.8]) cylinder(d1 = 3.4, d2 = 6.6, h = 1.81); }
arm_bolts = [55, 80];                                     // hub-to-arm bolts, distance from the bull
splice_bolts = [split_r - 16, split_r - 6, split_r + 6, split_r + 16];

module hub() {
  difference() {
    translate([0, 0, -hub_t]) cylinder(d = hub_d, h = hub_t, $fn = 120);
    cylinder(d = screw_d, h = 60, center = true);                     // the board's centre screw
    for (a = [0, 120, 240]) rotate(a) {
      translate([40, -(arm_w + 2*clr)/2, -hub_t - 1]) cube([hub_d, arm_w + 2*clr, arm_t + 1]);   // arm groove
      for (x = arm_bolts) translate([x, 0, 0]) m4_cs();             // bolt heads sink into the board side
    }
    for (a = [60, 180, 300]) rotate(a) {
      translate([62, 0, 0]) cylinder(d = 26, h = 60, center = true); // lighten
      translate([28, 0, 0]) { cylinder(d = 3.8, h = 60, center = true);   // optional wood screw into the board's back
        translate([0, 0, -hub_t - .01]) cylinder(d1 = 7.5, d2 = 3.8, h = 2.2); }
    }
  }
}
module arm_bar(x0, x1) { translate([x0, -arm_w/2, arm_z0]) cube([x1 - x0, arm_w, arm_t]); }
module nut_pockets(xs, flats, depth) { for (x = xs) translate([x, 0, arm_z0 - .01]) rotate(30) hexnut_pocket(flats, depth); }
module tie_slots(xs) { for (x = xs) translate([x, 0, arm_z0 + arm_t/2]) cube([3.4, 6, arm_t + 2], center = true); }
arm_inner_clips = [101, 128];                              // outside the hub, clear of the splice
arm_outer_clips = [200, 228, 256];
module arm_inner() {
  for (m = [0, 1]) mirror([0, m, 0]) for (x = arm_inner_clips) arm_clip(x);
  difference() {
    arm_bar(40, split_r);
    for (m = [0, 1]) mirror([0, m, 0]) for (x = arm_inner_clips) arm_clip_tie(x);
    for (x = arm_bolts) translate([x, 0, 0]) cylinder(d = 4.5, h = 60, center = true);
    nut_pockets(arm_bolts, 7.2, 3.4);
    for (x = [splice_bolts[0], splice_bolts[1]]) translate([x, 0, 0]) cylinder(d = 3.4, h = 60, center = true);
    nut_pockets([splice_bolts[0], splice_bolts[1]], 5.8, 2.6);
    tie_slots([112, 135]);
  }
}
module arm_outer() {
  x1 = cam_r + col_d/2;
  // cable clips: camera cable down one side, light lead down the other
  for (m = [0, 1]) mirror([0, m, 0]) { for (x = arm_outer_clips) arm_clip(x); for (z = [b_col_top - 30, b_col_top - 13]) col_clip(z); }
  difference() {
    union() {
      arm_bar(split_r, x1);
      // column up past the board's edge, braced to the arm
      translate([cam_r - col_d/2, -col_w/2, arm_z0]) cube([col_d, col_w, b_col_top - arm_z0 + .01]);
      hull() { translate([cam_r - col_d/2 - 26, -arm_w/2, arm_z0]) cube([1, arm_w, arm_t]); translate([cam_r - col_d/2 - .01, -col_w/2, arm_z0]) cube([1, col_w, 30]); }
    }
    for (x = [splice_bolts[2], splice_bolts[3]]) translate([x, 0, 0]) cylinder(d = 3.4, h = 60, center = true);
    nut_pockets([splice_bolts[2], splice_bolts[3]], 5.8, 2.6);
    tie_slots([205, 235]);
    for (m = [0, 1]) mirror([0, m, 0]) for (x = arm_outer_clips) arm_clip_tie(x);
  }
  // tilt fork on top; hinge axis runs round the board (y), so the camera looks in towards the bull (-x)
  translate([cam_r, 0, b_col_top]) rotate(-90) difference() {
    union() for (s = [-1, 1]) translate([s*(fork_gap/2 + fork_w/2), 0, 0]) {
      translate([-fork_w/2, -col_d/2, 0]) cube([fork_w, col_d, fork_above]);
      translate([0, 0, fork_above]) rotate([0, 90, 0]) cylinder(d = col_d, h = fork_w, center = true);
    }
    translate([0, 0, fork_above]) rotate([0, 90, 0]) cylinder(d = 3.4, h = 50, center = true);
    translate([fork_gap/2 + fork_w - 2.4, 0, fork_above]) rotate([0, 90, 0]) rotate(30) hexnut_pocket(5.8, 5);
  }
  translate([cam_r, 0, b_col_top + fork_above]) rotate(-90) for (s = [-1, 1]) translate([s*fork_gap/2, 0, 0]) rotate([0, -s*90, 0]) rosette(2.2, 5.8);
}
// joins the two halves; sits in the gap between the arm and the back of the board, bolt heads flush on the board side
module splice() {
  difference() {
    translate([split_r - 23, -arm_w/2, arm_z0 + arm_t]) cube([46, arm_w, hub_t - arm_t - .4]);
    for (x = splice_bolts) translate([x, 0, 0]) m3_cs();
  }
}
module board_assembly() {
  if (show_env) color("gainsboro", .35) translate([0, 0, -hub_t - 14]) cylinder(d = 760, h = 1, $fn = 120);    // wall
  if (show_env) color("dimgray") difference() { cylinder(d = 700, h = board_t + 4, $fn = 120); translate([0, 0, -1]) cylinder(d = board_d + 1, h = 60, $fn = 120);
    for (a = [0, 120, 240]) rotate(a) translate([cam_r - col_d/2 - 28, -13, -1]) cube([col_d + 32, 26, 60]); }   // foam surround, slots cut for the arms
  color("#1b1b1b") cylinder(d = board_d, h = board_t, $fn = 120);
  color("#efdfb9") translate([0, 0, board_t]) cylinder(r = 170, h = .6, $fn = 120);
  color("orange") hub();
  for (a = [0, 120, 240]) rotate(a) {
    color("orange") { arm_inner(); arm_outer(); } color("gold") splice();
    translate([cam_r, 0, b_col_top + fork_above]) rotate(-90) rotate([tilt_preview, 0, 0]) rotate([90, 0, 0]) translate([0, -hinge_y, -hinge_z]) {
      color("steelblue") { case_tub(); case_lid(); } light_strips();
      color("black") { linear_extrude(8) square(holder, center = true); cylinder(d = 14, h = 9.6); }
    }
  }
}
module print_board() {   // one hub + one set of arm parts; print the arm parts 3 times
  translate([0, 0, 0]) rotate([180, 0, 0]) hub();
  translate([-165, -115, -arm_z0]) arm_inner();
  translate([-175, -158, -arm_z0]) arm_outer();
  translate([-180, 115, -(arm_z0 + arm_t)]) splice();
}

/* ---------- layouts ---------- */
module assembly() {
  // wall is the z = 0 plane; the arm sticks straight out along +z
  color("gainsboro") translate([0, 0, -0.5]) cube([160, 160, 1], center = true);
  color("orange") wall_arm();
  // the case hangs on the fork: hinge axis x, lens looking along -y (along the wall, where the arrow points),
  // tilted towards the wall by tilt_preview
  translate([0, 0, plate_t + col_h + fork_above]) rotate([tilt_preview, 0, 0]) rotate([90, 0, 0]) translate([0, -hinge_y, -hinge_z]) {
    color("steelblue") { case_tub(); case_lid(); } light_strips();
    color("darkgreen") translate([0, 0, -pcb_t]) linear_extrude(pcb_t) square(pcb, center = true);
    color("black") { linear_extrude(8) square(holder, center = true); cylinder(d = 14, h = 9.6); }
  }
}
module print_all() {
  translate([-55, 0, -tub_floor_z]) case_tub();
  translate([0, 0, lid_z + lid_t]) rotate([180, 0, 0]) case_lid();
  translate([65, 0, 0]) wall_arm();
}

if (part == "case_tub") translate([0, 0, -tub_floor_z]) case_tub();
else if (part == "case_lid") translate([0, 0, lid_z + lid_t]) rotate([180, 0, 0]) case_lid();
else if (part == "wall_arm") wall_arm();
else if (part == "hub") rotate([180, 0, 0]) hub();                       // board side down
else if (part == "arm_inner") translate([0, 0, -arm_z0]) arm_inner();
else if (part == "arm_outer") translate([0, 0, -arm_z0]) arm_outer();
else if (part == "splice") translate([0, 0, -(arm_z0 + arm_t)]) splice();
else if (part == "board_assembly") board_assembly();
else if (part == "print_board") print_board();
else if (part == "print_all") print_all();
else assembly();
