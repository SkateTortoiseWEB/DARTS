# Oche

A darts scorer for the Mac, with camera scoring. Version 2.0.

## Playing

- **Game setup** opens first: choose 1–4 players (or add a new one), 301 / 501 / 701, first to 1–5 legs, double or straight out.
- **Scoring:** by camera, with the **Keypad** (top bar, or <kbd>K</kbd>), or by clicking the board on screen.
- **Top bar:** Undo, Keypad, camera status, New game, Settings, and **Next player**, which lights up when a turn is over and becomes
  **Rematch** at the end of a match (same players and settings, the next player throws first).
- The caller announces scores and checkouts; 180s, ton-plus scores, busts and game shots get their own animations.
- The leaderboard keeps wins, matches played, fewest darts per leg and beers (<kbd>B</kbd>) for every player.

## Camera

**Camera setup** (the camera button in the top bar, or <kbd>C</kbd>) goes through four steps:

1. **Camera:** pick which one and start it.
2. **Calibrate:** click where the outer edge of the double ring crosses four wires (a small board shows which). Up to five
   more points are optional and even out clicking errors; the panel shows how well the points agree, in mm. Scroll to zoom,
   right-drag to move around, drag a point to adjust it. Mappings can be saved and opened (the same format as
   `tools/mapping-practice.html`).
3. **Rings (optional):** click along the bull, treble and double wires to measure your board's actual ring sizes. Scoring
   then uses them.
4. **Test:** throw and see what it reads. Darts aren't scored into the game while setup is open. Detection settings and
   a troubleshooting recorder are here too.

## Parts of the project

| Path | What it is |
|---|---|
| `Oche.app` | The Mac app. `Contents/Resources/oche.html` is the whole app in one page (fonts and sounds built in); `server.py` saves results; `Contents/MacOS/Oche` launches both. |
| `hardware/` | 3D-printable camera + light wall mounts (OpenSCAD source, STLs, build guide). |
| `tools/mapping-practice.html` | Practice page: map a dartboard photo, measure rings, save the mapping. |
| `tools/camera-sim/` | Simulated webcam and recording replay, for testing camera detection. |
| `tools/tests/` | Automated checks of the app (`bash tools/tests/run.sh`). |

## Running without the app bundle

```sh
cd Oche.app/Contents/Resources
python3 server.py          # add --lan to allow other devices on your network
# then open http://localhost:8765
```

Without `OCHE_DATA_DIR` set, results are saved in `oche-data/` next to `server.py`. Opening `oche.html` directly
also works, but then results are only kept in that browser.

## Updating an installed Oche

Settings → **About and updates** → **Install update file**, and choose the new `oche.html`. Results, players,
calibration and the game in progress are kept.
