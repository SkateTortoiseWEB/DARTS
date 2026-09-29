# Oche

A darts scorer that runs as a macOS app.

- `Oche.app/Contents/Resources/oche.html` is the whole scorer UI in one page.
- `Oche.app/Contents/Resources/server.py` is a small local server with no dependencies. It saves finished matches, beers and the game in progress as JSON in `~/Library/Application Support/Oche`.
- `Oche.app/Contents/MacOS/Oche` is the launcher. It starts the server and opens the page in a Chrome/Edge/Brave/Chromium app window. It falls back to Safari if none of those is installed, and to the plain file if Python is missing.

## Run without the app bundle

```sh
cd Oche.app/Contents/Resources
python3 server.py          # add --lan to allow other devices on your network
# then open http://localhost:8765
```

Without `OCHE_DATA_DIR` set, data is saved in `oche-data/` next to `server.py`.
