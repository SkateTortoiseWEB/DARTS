// Oche camera + light mount for a wall-hung dartboard (made for a Winmau Blade 6)
// Camera: 38 x 38 mm OV9732 USB board (DECXIN-1M-2012V1), M2.5 holes on a 34 mm square, M12 lens.
//
// Parts (set `part` below, or on the command line: openscad -D 'part="case_tub"' -o case_tub.stl camera-mount.scad)
//   "case_tub"   back of the camera case: holds the board, cable exit, vents, tilt hinge tongue
//   "case_lid"   front of the case: lens opening and the plate the light is strapped to
//   "wall_arm"   one piece: plate that screws to the wall + column + tilt fork. The screw slots let it turn
//                about 12 degrees either way, so point the arrow at the bull before tightening
//   "assembly"   everything put together, for looking at (don't print this)
//   "print_all"  all three parts laid out for printing
//
// Hardware per mount: 4 x M2.5 x 12 screws (board, self-tapping into the tub),
//   1 x M3 x 20 bolt + nut (tilt), 2 x pan-head wood screws ~4 x 30 + washers + wall plugs.
// Put the board in the case with its USB connector towards the side with the cable slot (+x).
// Print in PETG or ASA, 4 walls, 40 % infill, no supports needed in the orientations "print_all" uses.

part = "assembly";

/* ---------- measure these on your setup ---------- */
board_face_from_wall = 45;   // how far the dartboard's face sits out from the wall (Blade 6 ~38 mm thick + bracket)
lens_above_face      = 40;   // how far in front of the board face the lens should be (30-50 works)
tilt_preview         = 12;   // tilt towards the board in the assembly preview only, degrees

/* ---------- camera board ---------- */
pcb      = 38;     // board is pcb x pcb
pcb_t    = 1.6;
hole_sp  = 34;     // mounting holes are on a hole_sp square
holder   = 13;     // square lens holder on the front
front_gap = 4;     // space between board front and lid (parts + lens holder screw ears)
back_gap  = 7;     // space behind the board (the connector sticks out 5.1 mm)

/* ---------- light ---------- */
light_plate_h = 26;   // height of the plate above the lens that the LED bar is strapped to
light_plate_w = 46;

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
  // posts the board sits on; M2.5 screws self-tap into them
  for (x = [-1, 1], y = [-1, 1]) translate([x*hole_sp/2, y*hole_sp/2, tub_floor_z + wall - 0.01])
    difference() { cylinder(d = 4.4, h = back_gap + 0.01); cylinder(d = 2.1, h = 50); }
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
  difference() {
    union() {
      translate([0, 0, lid_z]) rbox([outer, outer, lid_t]);
      // plate above the lens for the LED bar (strap it on with two cable ties)
      translate([-light_plate_w/2, outer/2 - 2, lid_z]) cube([light_plate_w, light_plate_h + 2, lid_t]);
      // lip that sits inside the tub so the lid registers
      translate([0, 0, lid_z - 1.5]) rbox([inner - 0.4, inner - 0.4, 1.6], r = 1);
    }
    // hollow the lip
    translate([0, 0, lid_z - 2]) rbox([inner - 3.4, inner - 3.4, 2], r = 1);
    // lens holder passes through
    translate([0, 0, lid_z - 5]) linear_extrude(20) square(holder + 1, center = true);
    // screw holes with countersinks
    for (x = [-1, 1], y = [-1, 1]) translate([x*hole_sp/2, y*hole_sp/2, 0]) {
      cylinder(d = 2.9, h = 50, center = true);
      translate([0, 0, lid_z + lid_t - 1.4]) cylinder(d1 = 2.9, d2 = 5.4, h = 1.41);
    }
    // cable tie slots in the light plate
    for (x = [-1, 1], y = [outer/2 + 6, outer/2 + light_plate_h - 6])
      translate([x*(light_plate_w/2 - 6), y, lid_z - 1]) cube([3.2, 5, 10], center = true);
  }
  // spacers that clamp the board (sit on the board around its holes)
  for (x = [-1, 1], y = [-1, 1]) translate([x*hole_sp/2, y*hole_sp/2, 0])
    difference() { cylinder(d = 4.4, h = lid_z); cylinder(d = 2.9, h = 50, center = true); }
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

/* ---------- layouts ---------- */
module assembly() {
  // wall is the z = 0 plane; the arm sticks straight out along +z
  color("gainsboro") translate([0, 0, -0.5]) cube([160, 160, 1], center = true);
  color("orange") wall_arm();
  // the case hangs on the fork: hinge axis x, lens looking along -y (along the wall, where the arrow points),
  // tilted towards the wall by tilt_preview
  translate([0, 0, plate_t + col_h + fork_above]) rotate([tilt_preview, 0, 0]) rotate([90, 0, 0]) translate([0, -hinge_y, -hinge_z]) {
    color("steelblue") { case_tub(); case_lid(); }
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
else if (part == "print_all") print_all();
else assembly();
