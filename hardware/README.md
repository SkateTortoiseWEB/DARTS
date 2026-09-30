# Camera mounts

Three cameras, each with its own small LED light, around the dartboard. Designed for a Winmau Blade 6 on its Winmau bracket,
with the 38 × 38 mm OV9732 USB camera board (DECXIN-1M-2012V1: M2.5 holes on a 34 mm square, 13 mm lens holder,
2.84 mm lens seeing 65° across and 51° up and down). Many "100°" OV9732 listings use this same board and lens;
check the hole spacing (34 mm) when yours arrive.

There are two ways to hold the cameras. Both use the same camera case.

- **Board mount (recommended, no holes in the wall):** a hub sits behind the board, held by the board's own centre
  screw, with three arms that come forward past the board's edge. The cameras move with the board, so calibration
  stays right even if the board shifts on its bracket.
- **Wall mount:** one arm per camera, screwed to the wall.

## Board mount

![front](preview-board-front.png) ![back, without the wall and foam](preview-board-back.png)

### Parts

| File | How many | Printed size | Notes |
|---|---|---|---|
| `stl/board-mount/hub.stl` | 1 | 180 × 180 × 10 mm | goes between the board and its bracket |
| `stl/board-mount/arm_inner.stl` | 3 | 125 × 37 × 8 mm | bolts into the hub; cable clips on both sides |
| `stl/board-mount/arm_outer.stl` | 3 | 143 × 37 × 65 mm | column and tilt fork for the camera; cable clips on both sides |
| `stl/board-mount/splice.stl` | 3 | 46 × 22 × 4 mm | joins the two arm halves |
| `stl/case_tub.stl` | 3 | | back of the camera case |
| `stl/case_lid.stl` | 3 | 56 × 75 × 6.5 mm | front of the case, with the light tray above the lens |

![parts](preview-board-parts.png)

![one camera from outside the board: the clips on the column and arm](preview-camera-closeup.png)

Everything fits an Ender 3 / Ender 3 SE bed (220 × 220 mm) and prints flat as exported, without supports.

**Print settings:** PETG if you can (PLA slowly bends under load, and the cameras mustn't move), 0.2 mm layers, 4 walls,
40 % infill (100 % for the arms if you like), no supports. For the hub, a brim helps it stay flat.

### Hardware

- The board's centre screw, **about 10 mm longer** than the one it came with (the hub is 10 mm thick)
- Per arm: 2 × **M4 × 16** countersunk bolts + nuts (hub to arm), 4 × **M3 × 12** countersunk bolts + nuts (splice)
- Per camera: 4 × **M2.5 × 12** screws (board into case), 1 × **M3 × 20** bolt + nut (tilt hinge)
- Optional: 3 × small wood screws (about 3.5 × 16 mm) through the hub into the back of the board, so the hub can't turn
- Per light: a short piece of 5 V USB COB LED strip, 8 mm wide (see [Light](#light))
- A few small cable ties (to hold each light's lead)

### Fitting it

1. Take the board off the wall and look at the back. **The hub goes between the board and whatever the board hangs by.**
   Remove the centre screw, put the hub against the board (flat side to the board, grooves facing the wall), put the
   bracket part back on top and fix it all with the longer screw. If your bracket part is held by several screws
   rather than one, drill matching holes through the hub.
2. Bolt the three inner arms into the hub's grooves (bolt heads sink into the board side, nuts in the pockets), then
   the outer arms to the inner arms with a splice plate across each joint (splice on the board side).
3. **Foam surround:** each column passes through the foam about 300 mm from the bull. Cut a slot about
   50 × 35 mm through the foam for each one (room for the column and its cable clips), and a shallow channel in the
   foam's back for the arm (38 mm wide, 8 mm deep).
4. Hang the board back up and turn it so the arms point where you want the cameras. Evenly spaced is best:
   12, 4 and 8 o'clock, or 2, 6 and 10.
5. Fit the cameras in their cases, stick the lights in their trays and hang each case in its fork with the M3 bolt.
   Then run the cables (see [Cables](#cables)).
6. In Oche's camera setup, check each camera sees the whole board, then tighten the tilt bolts and calibrate.

### Measure and adjust

At the top of `camera-mount.scad`:

- `board_t` (38): the board's thickness, front to back
- `lens_above_face` (40): how far in front of the board's face the lenses sit
- `cam_r` (300): camera distance from the bull. 300 suits the lens the OV9732 comes with (65° across: it sees
  the doubles ring with about 20 mm to spare on each side); with a
  2.1 mm lens (about 85° across) 260-280 gives a sharper view
- `screw_d` (6.5): the hole for the board's centre screw

Export a part with, for example, `openscad -D 'part="hub"' -o stl/board-mount/hub.stl camera-mount.scad`.
Parts: `hub`, `arm_inner`, `arm_outer`, `splice`, `case_tub`, `case_lid`, `wall_arm`; previews `board_assembly`,
`print_board`, `assembly`, `print_all`.

## Light

The lid has a tray above the lens with three 8 mm grooves, for pieces of **5 V USB COB LED strip** (the 320 LEDs/m
kind, natural white). Choose the plain "USB" version or one with an on/off switch, **never a dimmer or touch dimmer**:
dimmers flicker too fast for your eye but not for the camera, which sees moving bands.

![light tray](preview-light-tray.png)

- **One piece per camera:** cut the strip on its marked copper pads so the piece with the USB lead is at most 43 mm
  long. Stick it in the **middle groove** with its own adhesive, USB end towards the pocket. The lump where the lead
  joins sits in the pocket, and the lead leaves through the notch.
- **Brighter (three pieces):** stick two more 43 mm pieces in the outer grooves, all facing the same way, and join
  them at the far end with short wires (+ to +, − to −); there's a channel across the ends for them.
- Tie the lead down through the two slots beside the pocket, so a tug on the cable can't pull the strip off.
- Power the lights from a powered USB hub or a USB charger, not from the Mac directly.

## Cables

Each camera has two USB-A cables: the camera's own cable, which leaves the case on one side, and the light's lead,
which leaves the tray on the other. On the board mount each runs down its own side: two clips on each side of the
column, then three on each side of the outer arm and two on each side of the inner arm. The clips open sideways
(on the column) and towards the board (on the arm), so the cables push in from the side and the USB plugs never have
to go through anything. Leave a small loop between the case and the first clip so the camera can still tilt.
At the hub, bring all six cables together behind the board and down to the USB hub.

The clips fit cables up to about 4.4 mm thick (change `cable_d` for thicker ones).

## Mini model (1:4, to try it out)

![mini](preview-mini.png)

A desk-sized version of the board mount, to look at and tinker with before printing the real thing
(`mini-model.scad`, STLs in `stl/mini/`). Simplified so it prints well: no screws, the board sits on a peg in the middle
of the frame and turns on it, and each camera tilts on a hinge pin cut from 1.75 mm filament.

| File | How many | Size | Rough print time (Ender 3 SE) |
|---|---|---|---|
| `mini_board.stl` | 1 | 113 mm across | 1.5-2 h (0.12-0.16 mm layers for crisp numbers) |
| `mini_frame.stl` | 1 | 120 × 138 mm | about 1 h |
| `mini_camera.stl` | 3 | 11 × 20 mm | about 15 min each |
| `mini_surround.stl` | 1, optional | 175 mm across | 2-3 h |

PLA is fine, 3 walls, 20 % infill, no supports. To put it together: push the board onto the frame's peg, cut three
short pieces of filament, push each through a fork and its camera's hinge tongue, and tilt the cameras towards the
board. If a pin is loose, change `pin_d` to 1.85 and reprint the camera. The engraved rings and raised numbers make
the board easy to paint.

## Wall mount

![assembled](preview-assembly.png)

`stl/wall-mount/wall_arm.stl` plus the same camera case. Screw each arm to the wall 300 mm from the bull (evenly
spaced), with the arrow on the plate pointing at the bull; the curved slots let it turn 12° either way. Set
`board_face_from_wall` to how far your board's face sits out from the wall. Hardware per arm: the camera and tilt
parts above, plus 2 pan-head wood screws with washers and wall plugs.

## Camera case assembly

1. Focus the lens first (turn it until the board is sharp at about 30 cm), then put the board in the case with its
   USB connector towards the cable slot.
2. Lid on, 4 × M2.5 screws through the lid and board into the posts.
3. Stick the LED strip in the lid's light tray (see [Light](#light)).
4. Hang the case in the fork with the M3 bolt; the teeth hold the tilt once it's tight.
5. Cable-tie the camera cable to the anchor under the case's cable slot.
