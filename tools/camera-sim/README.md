# Camera simulator

Tests Oche's webcam detection without a webcam. `fakecam.js` replaces the camera with a simulated overhead view of a black-and-white paper board, with sensor noise, magnets and their shadows, a blur as each magnet flies in, and a hand pulling them out. The page is then driven in headless Chromium through Playwright.

```sh
bash tools/camera-sim/suite.sh                     # every scenario against Oche.app's oche.html
node tools/camera-sim/run.mjs "$PWD/Oche.app/Contents/Resources/oche.html" '{"seed":3,"turns":6,"gap":500}'
node tools/camera-sim/idle.mjs "$PWD/Oche.app/Contents/Resources/oche.html"   # empty board: should score nothing
```

To replay a real recording (from the Record button in Oche's camera view), unzip it and run:

```sh
node tools/camera-sim/replay.mjs "$PWD/Oche.app/Contents/Resources/oche.html" path/to/unzipped-recording '{"sens":24}'
```

Scenario options: `seed`, `turns`, `gap` (ms between throws), `group` (mm between magnets in a turn), `magR` (magnet radius, mm), `magCol`/`hi` (magnet colour and highlight), `noise`, `shadow`.

The scripts import Playwright from `/opt/node22/lib/node_modules/playwright`. Change that path if Playwright is installed somewhere else.
