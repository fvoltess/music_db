#!/usr/bin/env python3
"""
Ingest Spotify playlists into a MySQL database.

CSV format (default path = scraper/playlists.csv):
  person_id,person_name,playlist_url
  u01,Fede,https://open.spotify.com/playlist/...

Env vars (loaded from  .env):
  SPOTIFY_CLIENT_ID=...
  SPOTIFY_CLIENT_SECRET=...
  MYSQL_HOST=localhost
  MYSQL_PORT=3306
  MYSQL_DB=spotify_graph
  MYSQL_USER=...
  MYSQL_PASS=...
Optional:
  USE_OAUTH=0
  MAX_PLAYLISTS_PER_PERSON=5
  CSV_PATH=/absolute/path/to/playlists.csv   (override)
"""

import csv, os, sys, time, re
from typing import Dict, Any, List
from pathlib import Path

import requests
import mysql.connector as mysql

# ---------------------- .env loader (robust) ----------------------
_loaded_from = None
_looked_paths: List[str] = []

def load_env_file() -> str | None:
    """Search common locations for env files and load them (first match wins)."""
    global _looked_paths
    try:
        from dotenv import load_dotenv  # type: ignore
    except Exception:
        return None  # dotenv not installed; rely on shell env

    here = Path(__file__).resolve()
    repo_root = here.parents[1]          # project root (this file is in scraper/)
    cwd = Path.cwd()
    home = Path.home()

    # explicit override
    hint = os.getenv("MUSIC_DB_ENV")
    candidates: List[Path] = []
    if hint:
        candidates.append(Path(hint))

    # project root
    candidates += [
        repo_root / "music_db.env",
        repo_root / ".env",
        repo_root / ".env.example",
    ]
    # next to this script
    candidates += [
        here.parent / "music_db.env",
        here.parent / ".env",
        here.parent / ".env.example",
    ]
    # current working dir
    candidates += [
        cwd / "music_db.env",
        cwd / ".env",
        cwd / ".env.example",
    ]
    # home dir fallback
    candidates += [
        home / "music_db.env",
        home / ".env",
        home / ".env.example",
    ]

    _looked_paths = [str(p) for p in candidates]
    for p in candidates:
        if p.exists():
            load_dotenv(p, override=False)
            return str(p)
    return None

_loaded_from = load_env_file()

# ---------------------- Config ----------------------
SCRIPT_DIR = Path(__file__).resolve().parent
CSV_PATH = os.getenv("CSV_PATH", str(SCRIPT_DIR / "playlists.csv"))  # default to scraper/playlists.csv

MAX_PLAYLISTS_PER_PERSON = int(os.getenv("MAX_PLAYLISTS_PER_PERSON", "999"))
USE_OAUTH = os.getenv("USE_OAUTH", "0") == "1"

SPOTIFY_CLIENT_ID = os.getenv("SPOTIFY_CLIENT_ID")
SPOTIFY_CLIENT_SECRET = os.getenv("SPOTIFY_CLIENT_SECRET")

MYSQL_HOST = os.getenv("MYSQL_HOST", "localhost")
MYSQL_PORT = int(os.getenv("MYSQL_PORT", "3306"))
MYSQL_DB   = os.getenv("MYSQL_DB", "spotify_graph")
MYSQL_USER = os.getenv("MYSQL_USER", "root")
MYSQL_PASS = os.getenv("MYSQL_PASS", "")

if not SPOTIFY_CLIENT_ID or not SPOTIFY_CLIENT_SECRET:
    where_hint = f"\nLoaded from: {_loaded_from}" if _loaded_from else ""
    looked = ("\nLooked for env file at:\n  - " + "\n  - ".join(_looked_paths)) if _looked_paths else ""
    sys.exit(
        "Missing SPOTIFY_CLIENT_ID or SPOTIFY_CLIENT_SECRET."
        + where_hint
        + looked
        + "\nFixes:\n"
          "  • Put your keys in music_db.env / .env / .env.example, OR\n"
          "  • Set MUSIC_DB_ENV=/full/path/to/your.env, OR\n"
          "  • export SPOTIFY_CLIENT_ID/SECRET in your shell."
    )

# ---------------------- Spotify Auth ----------------------
def get_client_credentials_token() -> str:
    auth_url = "https://accounts.spotify.com/api/token"
    resp = requests.post(
        auth_url,
        data={"grant_type": "client_credentials"},
        auth=(SPOTIFY_CLIENT_ID, SPOTIFY_CLIENT_SECRET),
        timeout=30,
    )
    resp.raise_for_status()
    return resp.json()["access_token"]

def get_auth_header(token: str) -> Dict[str, str]:
    return {"Authorization": f"Bearer {token}"}

# ---------------------- Helpers ----------------------
def extract_playlist_id(url: str) -> str:
    url = url.strip()
    m = re.search(r"playlist/([a-zA-Z0-9]+)", url)
    if m:
        return m.group(1)
    m = re.search(r"spotify:playlist:([a-zA-Z0-9]+)", url)
    if m:
        return m.group(1)
    if re.fullmatch(r"[a-zA-Z0-9]+", url):
        return url
    raise ValueError(f"Could not parse playlist ID: {url}")

def batched(iterable, n):
    batch = []
    for item in iterable:
        batch.append(item)
        if len(batch) == n:
            yield batch
            batch = []
    if batch:
        yield batch

# ---------------------- MySQL ----------------------
def get_conn():
    try:
        return mysql.connect(
            host=MYSQL_HOST, port=MYSQL_PORT, database=MYSQL_DB,
            user=MYSQL_USER, password=MYSQL_PASS, autocommit=True
        )
    except mysql.Error as e:
        if getattr(e, "errno", None) == 1045:
            raise SystemExit(
                f"MySQL access denied for user '{MYSQL_USER}'@'{MYSQL_HOST}'.\n"
                f"Check MYSQL_USER/MYSQL_PASS and privileges on '{MYSQL_DB}'."
            )
        elif getattr(e, "errno", None) == 1049:
            raise SystemExit(
                f"MySQL database '{MYSQL_DB}' does not exist.\n"
                f"Create it with: CREATE DATABASE {MYSQL_DB} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
            )
        else:
            raise

DDL = [
    """CREATE TABLE IF NOT EXISTS people (
         person_id VARCHAR(64) PRIMARY KEY,
         person_name VARCHAR(255) NOT NULL
       ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;""",
    """CREATE TABLE IF NOT EXISTS playlists (
         playlist_id VARCHAR(64) PRIMARY KEY,
         name VARCHAR(512),
         description TEXT,
         owner_spotify_id VARCHAR(128),
         owner_display_name VARCHAR(255),
         followers INT,
         href VARCHAR(512),
         snapshot_id VARCHAR(128)
       ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;""",
    """CREATE TABLE IF NOT EXISTS people_playlists (
         person_id VARCHAR(64),
         playlist_id VARCHAR(64),
         PRIMARY KEY(person_id, playlist_id)
       ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;""",
    """CREATE TABLE IF NOT EXISTS tracks (
         track_id VARCHAR(64) PRIMARY KEY,
         name VARCHAR(512),
         album VARCHAR(512),
         release_date VARCHAR(32),
         duration_ms INT,
         popularity INT,
         is_local TINYINT(1),
         href VARCHAR(512)
       ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;""",
    """CREATE TABLE IF NOT EXISTS artists (
         artist_id VARCHAR(64) PRIMARY KEY,
         name VARCHAR(255),
         href VARCHAR(512)
       ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;""",
    """CREATE TABLE IF NOT EXISTS track_artists (
         track_id VARCHAR(64),
         artist_id VARCHAR(64),
         PRIMARY KEY(track_id, artist_id)
       ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;""",
    """CREATE TABLE IF NOT EXISTS playlist_tracks (
         playlist_id VARCHAR(64),
         track_id VARCHAR(64),
         added_at DATETIME NULL,
         added_by VARCHAR(128) NULL,
         disc_number INT NULL,
         track_number INT NULL,
         PRIMARY KEY(playlist_id, track_id)
       ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;"""
]

UPSERT_PERSON = "INSERT INTO people (person_id, person_name) VALUES (%s,%s) ON DUPLICATE KEY UPDATE person_name=VALUES(person_name);"
UPSERT_PLAYLIST = "INSERT INTO playlists (playlist_id, name, description, owner_spotify_id, owner_display_name, followers, href, snapshot_id) VALUES (%s,%s,%s,%s,%s,%s,%s,%s) ON DUPLICATE KEY UPDATE name=VALUES(name), description=VALUES(description), followers=VALUES(followers);"
UPSERT_PEOPLE_PLAYLISTS = "INSERT IGNORE INTO people_playlists (person_id, playlist_id) VALUES (%s,%s);"
UPSERT_TRACK = "INSERT INTO tracks (track_id, name, album, release_date, duration_ms, popularity, is_local, href) VALUES (%s,%s,%s,%s,%s,%s,%s,%s) ON DUPLICATE KEY UPDATE name=VALUES(name), album=VALUES(album);"
UPSERT_ARTIST = "INSERT INTO artists (artist_id, name, href) VALUES (%s,%s,%s) ON DUPLICATE KEY UPDATE name=VALUES(name);"
UPSERT_TRACK_ARTIST = "INSERT IGNORE INTO track_artists (track_id, artist_id) VALUES (%s,%s);"
UPSERT_PLAYLIST_TRACK = "INSERT IGNORE INTO playlist_tracks (playlist_id, track_id, added_at, added_by, disc_number, track_number) VALUES (%s,%s,%s,%s,%s,%s);"

def ensure_schema(conn):
    cur = conn.cursor()
    for stmt in DDL:
        cur.execute(stmt)
    cur.close()

# ---------------------- Spotify API ----------------------
BASE = "https://api.spotify.com/v1"

def get_playlist(playlist_id: str, token: str) -> Dict[str, Any]:
    url = f"{BASE}/playlists/{playlist_id}"
    resp = requests.get(url, headers=get_auth_header(token), timeout=30)
    resp.raise_for_status()
    data = resp.json()

    # handle paging
    items = data.get("tracks", {}).get("items", [])
    next_url = data.get("tracks", {}).get("next")
    while next_url:
        r = requests.get(next_url, headers=get_auth_header(token), timeout=30)
        r.raise_for_status()
        page = r.json()
        items.extend(page.get("items", []))
        next_url = page.get("next")
        time.sleep(0.05)
    data["tracks"]["items"] = items
    return data

# ---------------------- Main ----------------------
def read_csv_rows(path: str) -> List[Dict[str, str]]:
    rows: List[Dict[str, str]] = []
    with open(path, newline="", encoding="utf-8") as f:
        for row in csv.DictReader(f):
            # skip blank/partial lines
            if not row or not row.get("playlist_url"):
                continue
            rows.append(row)
    return rows

def main():
    # sanity: CSV exists?
    if not Path(CSV_PATH).exists():
        sys.exit(f"CSV file not found at: {CSV_PATH}\n"
                 f"Set CSV_PATH env var or place playlists.csv at {SCRIPT_DIR}")

    token = get_client_credentials_token()

    conn = get_conn()
    ensure_schema(conn)
    cur = conn.cursor()

    rows = read_csv_rows(CSV_PATH)
    grouped: Dict[str, List[Dict[str, str]]] = {}
    for r in rows:
        pid = r["person_id"].strip()
        grouped.setdefault(pid, []).append(r)

    for pid, plist in grouped.items():
        if len(plist) > MAX_PLAYLISTS_PER_PERSON:
            plist = plist[:MAX_PLAYLISTS_PER_PERSON]
        person_name = plist[0]["person_name"].strip()
        cur.execute(UPSERT_PERSON, (pid, person_name))

        for row in plist:
            pl_id = extract_playlist_id(row["playlist_url"])
            try:
                pdata = get_playlist(pl_id, token)
            except Exception as e:
                print(f"[ERROR] {pid} {person_name} {pl_id}: {e}")
                continue

            cur.execute(UPSERT_PLAYLIST, (
                pdata["id"], pdata["name"], pdata.get("description"),
                pdata["owner"]["id"], pdata["owner"]["display_name"],
                pdata["followers"]["total"], pdata["href"], pdata["snapshot_id"]
            ))
            cur.execute(UPSERT_PEOPLE_PLAYLISTS, (pid, pdata["id"]))

            items = pdata.get("tracks", {}).get("items", [])
            track_rows, artist_rows, track_artist_rows, playlist_track_rows = [], [], [], []
            for it in items:
                t = it.get("track")
                if not t or not t.get("id"):
                    continue
                tid = t["id"]
                track_rows.append((tid, t["name"], t["album"]["name"], t["album"]["release_date"],
                                   t["duration_ms"], t["popularity"], int(bool(t["is_local"])), t["href"]))
                for a in t.get("artists", []):
                    artist_rows.append((a["id"], a["name"], a["href"]))
                    track_artist_rows.append((tid, a["id"]))
                playlist_track_rows.append((pdata["id"], tid, it.get("added_at"), (it.get("added_by") or {}).get("id"),
                                            t.get("disc_number"), t.get("track_number")))

            for batch in batched(track_rows, 500): cur.executemany(UPSERT_TRACK, batch)
            for batch in batched(artist_rows, 500): cur.executemany(UPSERT_ARTIST, batch)
            for batch in batched(track_artist_rows, 500): cur.executemany(UPSERT_TRACK_ARTIST, batch)
            for batch in batched(playlist_track_rows, 500): cur.executemany(UPSERT_PLAYLIST_TRACK, batch)

            print(f"[OK] {pdata['name']} ({len(items)} tracks)")

    cur.close(); conn.close()
    print("Done.")

if __name__ == "__main__":
    main()