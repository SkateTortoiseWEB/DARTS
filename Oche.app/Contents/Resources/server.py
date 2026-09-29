#!/usr/bin/env python3
"""Oche local server.

Serves the Oche page and saves everything to files in the data folder
(~/Library/Application Support/Oche when started by Oche.app):
  matches.json       finished matches (leaderboard)
  beers.json         every beer logged (all-time beer counter)
  current-game.json  the game in progress (autosave)
  oche.html          an installed update of the page, if any
  server.py          an installed update of this server, if any (used next launch)

Run by hand:  python3 server.py  then open http://localhost:8765
No extra packages needed.
"""
import json
import os
import re
import sys
import threading
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

PORT = int(os.environ.get("OCHE_PORT", "8765"))
ROOT = Path(os.environ.get("OCHE_ROOT", Path(__file__).resolve().parent))  # where the bundled oche.html lives
DATA_DIR = Path(os.environ.get("OCHE_DATA_DIR", ROOT / "oche-data"))
STATE = DATA_DIR / "current-game.json"
COLLECTIONS = {"matches": DATA_DIR / "matches.json", "beers": DATA_DIR / "beers.json"}
PAGE_UPDATE = DATA_DIR / "oche.html"
SERVER_UPDATE = DATA_DIR / "server.py"
ID_RE = re.compile(r"[A-Za-z0-9_-]{1,64}")
lock = threading.Lock()


def write_atomic(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_suffix(path.suffix + ".tmp")
    if isinstance(data, bytes):
        tmp.write_bytes(data)
    else:
        tmp.write_text(data)
    os.replace(tmp, path)  # atomic, so a crash never leaves a half-written file


def load_list(path):
    try:
        data = json.loads(path.read_text())
        return data if isinstance(data, list) else []
    except (FileNotFoundError, json.JSONDecodeError):
        return []


class Handler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(ROOT), **kwargs)

    # ---------- helpers ----------
    def send_json(self, code, obj):
        body = json.dumps(obj).encode()
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        self.wfile.write(body)

    def read_body(self, limit):
        length = int(self.headers.get("Content-Length", 0))
        if length > limit:
            raise ValueError("too large")
        return self.rfile.read(length)

    def route(self):
        path = self.path.split("?")[0]
        m = re.fullmatch(r"/api/(matches|beers)(?:/([A-Za-z0-9_-]{1,64}))?", path)
        return path, m

    # ---------- GET ----------
    def do_GET(self):
        path, m = self.route()
        if path in ("/", "/index.html", "/oche.html"):
            page = PAGE_UPDATE if PAGE_UPDATE.exists() else ROOT / "oche.html"
            body = page.read_bytes()
            self.send_response(200)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.send_header("Content-Length", str(len(body)))
            self.send_header("Cache-Control", "no-store")
            self.end_headers()
            return self.wfile.write(body)
        if m and not m.group(2):
            with lock:
                return self.send_json(200, load_list(COLLECTIONS[m.group(1)]))
        if path == "/api/state":
            with lock:
                try:
                    return self.send_json(200, json.loads(STATE.read_text()))
                except (FileNotFoundError, json.JSONDecodeError):
                    return self.send_json(200, None)
        if path == "/api/update":
            return self.send_json(200, {"pageUpdated": PAGE_UPDATE.exists(), "serverUpdated": SERVER_UPDATE.exists()})
        return self.send_json(404, {"error": "not found"})

    # ---------- POST: add an item, or install an update ----------
    def do_POST(self):
        path, m = self.route()
        if m and not m.group(2):
            try:
                item = json.loads(self.read_body(200_000))
            except (ValueError, json.JSONDecodeError):
                return self.send_json(400, {"error": "bad json"})
            if not isinstance(item, dict) or not ID_RE.fullmatch(str(item.get("id", ""))):
                return self.send_json(400, {"error": "bad item"})
            file = COLLECTIONS[m.group(1)]
            with lock:
                items = [x for x in load_list(file) if x.get("id") != item["id"]]
                items.append(item)
                write_atomic(file, json.dumps(items, indent=1))
            return self.send_json(200, {"ok": True})
        if path in ("/api/update/page", "/api/update/server"):
            try:
                body = self.read_body(30_000_000)
            except ValueError:
                return self.send_json(400, {"error": "file too large"})
            text = body.decode("utf-8", errors="replace")
            if path.endswith("page"):
                if not (text.lstrip().lower().startswith("<!doctype html") and "Oche" in text):
                    return self.send_json(400, {"error": "that isn't an Oche page"})
                write_atomic(PAGE_UPDATE, body)
            else:
                if "Oche local server" not in text:
                    return self.send_json(400, {"error": "that isn't an Oche server file"})
                try:
                    compile(text, "server.py", "exec")
                except SyntaxError:
                    return self.send_json(400, {"error": "server file is broken"})
                write_atomic(SERVER_UPDATE, body)
            return self.send_json(200, {"ok": True})
        return self.send_json(404, {"error": "not found"})

    # ---------- PUT: autosave the game in progress ----------
    def do_PUT(self):
        if self.route()[0] != "/api/state":
            return self.send_json(404, {"error": "not found"})
        try:
            state = json.loads(self.read_body(5_000_000))
        except (ValueError, json.JSONDecodeError):
            return self.send_json(400, {"error": "bad json"})
        with lock:
            write_atomic(STATE, json.dumps(state))
        self.send_json(200, {"ok": True})

    # ---------- DELETE: remove an item, or undo installed updates ----------
    def do_DELETE(self):
        path, m = self.route()
        if m and m.group(2):
            file = COLLECTIONS[m.group(1)]
            with lock:
                write_atomic(file, json.dumps([x for x in load_list(file) if x.get("id") != m.group(2)], indent=1))
            return self.send_json(200, {"ok": True})
        if path == "/api/update":
            for f in (PAGE_UPDATE, SERVER_UPDATE):
                f.unlink(missing_ok=True)
            return self.send_json(200, {"ok": True})
        return self.send_json(404, {"error": "not found"})

    def log_message(self, *args):
        pass  # keep the log quiet


if __name__ == "__main__":
    host = "0.0.0.0" if "--lan" in sys.argv else "127.0.0.1"
    print(f"Oche running at http://localhost:{PORT}")
    print(f"Data saved in {DATA_DIR}")
    try:
        ThreadingHTTPServer((host, PORT), Handler).serve_forever()
    except KeyboardInterrupt:
        pass
