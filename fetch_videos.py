#!/usr/bin/env python3
"""
fetch_videos.py
----------------
* Reads the list of YouTube URLs from `link.md`.
* For each URL it:
  1️⃣ Retrieves video metadata (title, thumbnail URL) via `yt-dlp -j`.
  2️⃣ Downloads **360p** and **720p** MP4 files using `yt-dlp`.
  3️⃣ Downloads the thumbnail image.
  4️⃣ Saves the files under `assets/videos/` with a deterministic naming scheme:
     - `<index>_<sanitized_title>_360p.mp4`
     - `<index>_<sanitized_title>_720p.mp4`
     - `<index>_<sanitized_title>_thumb.jpg`
  5️⃣ Appends an entry to `assets/data/manifest.json` that mirrors the existing
     structure (see existing manifest for reference).  The `streamUrl` points to the
     **720p** local asset, and `thumbnailUrl` points to the downloaded thumbnail.
* After processing all URLs the script prints a short summary.

Usage:
    python3 fetch_videos.py

Prerequisites (run once):
    brew install yt-dlp ffmpeg
    pip install requests tqdm
"""

import json
import os
import re
import subprocess
import sys
import uuid
import math
import uuid
from pathlib import Path
from typing import List, Dict

import requests
from tqdm import tqdm

# ----------------------------------------------------------------------
# Configuration – adjust if your project structure changes
# ----------------------------------------------------------------------
PROJECT_ROOT = Path(__file__).resolve().parent
LINKS_FILE = PROJECT_ROOT / "link.md"
ASSETS_DIR = PROJECT_ROOT / "assets" / "videos"
MANIFEST_PATH = PROJECT_ROOT / "assets" / "data" / "manifest.json"

# Ensure directories exist
ASSETS_DIR.mkdir(parents=True, exist_ok=True)
MANIFEST_PATH.parent.mkdir(parents=True, exist_ok=True)

# ----------------------------------------------------------------------
# Helper utilities
# ----------------------------------------------------------------------
def run_cmd(cmd: List[str]) -> str:
    """Run a shell command, raise on error, return stdout."""
    result = subprocess.run(
        cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, check=False
    )
    if result.returncode != 0:
        sys.stderr.write(f"❌ Command failed: {' '.join(cmd)}\n{result.stderr}\n")
        sys.exit(1)
    return result.stdout.strip()

def sanitize_title(title: str) -> str:
    """Make a filesystem‑safe name from a YouTube title."""
    # Lowercase, replace spaces with underscores, strip non‑alphanum chars
    title = title.strip().lower()
    title = re.sub(r"[\s]+", "_", title)
    title = re.sub(r"[^a-z0-9_]+", "", title)
    return title[:50]  # truncate to avoid overly long filenames

def download_thumbnail(url: str, dest_path: Path) -> None:
    """Download an image via HTTP with a progress bar."""
    response = requests.get(url, stream=True, timeout=30)
    response.raise_for_status()
    total = int(response.headers.get("content-length", 0))
    with open(dest_path, "wb") as f, tqdm(
        total=total, unit="B", unit_scale=True, desc=f"Thumbnail {dest_path.name}"
    ) as bar:
        for chunk in response.iter_content(chunk_size=8192):
            if chunk:
                f.write(chunk)
                bar.update(len(chunk))

def download_video(url: str, out_dir: Path, height: int) -> Path:
    """Download a video at the given maximum height (360 or 720).
    The output filename includes the height to keep files separate.
    """
    # Use 'bestvideo+bestaudio' to ensure we capture higher quality streams (like 720p adaptive)
    # properly merged, rather than defaulting to a single pre-merged file (often 360p).
    # Fallback to 'best' if no separate streams found.
    fmt = f"bestvideo[height<={height}]+bestaudio/best[height<={height}]"
    # Include height in filename to avoid collisions between 360p and 720p downloads
    output_template = str(out_dir / f"%(id)s_{height}p.%(ext)s")
    cmd = [
        "yt-dlp",
        "-f",
        fmt,
        "--merge-output-format",
        "mp4",
        "--no-playlist",
        "-o",
        output_template,
        url,
    ]
    print(f"⬇️  Downloading {height}p → {url}")
    run_cmd(cmd)
    # Find the newly created file (should be the only .mp4 with that height suffix)
    mp4_files = list(out_dir.glob(f"*_{height}p.mp4"))
    if not mp4_files:
        raise FileNotFoundError(f"yt‑dlp did not produce an mp4 file for {url} at {height}p")
    mp4_files.sort(key=lambda p: p.stat().st_mtime, reverse=True)
    return mp4_files[0]


def load_manifest() -> Dict:
    if MANIFEST_PATH.is_file():
        with open(MANIFEST_PATH, "r", encoding="utf-8") as f:
            return json.load(f)
    # If the file does not exist, create a minimal skeleton
    return {"version": 1, "updatedAt": "2026-01-01T00:00:00Z", "items": []}

def save_manifest(manifest: Dict) -> None:
    with open(MANIFEST_PATH, "w", encoding="utf-8") as f:
        json.dump(manifest, f, indent=2, ensure_ascii=False)
    print(f"🗂️  Manifest saved to {MANIFEST_PATH}")
def bytes_to_mb_decimal(n_bytes: int) -> float:
    # MB theo thập phân (thường dùng khi hiển thị dung lượng cho user)
    return n_bytes / 1_000_000

# ----------------------------------------------------------------------
# Main workflow
# ----------------------------------------------------------------------
def main() -> None:
    # 1️⃣ Read URLs from link.md (ignore empty lines / comments)
    if not LINKS_FILE.is_file():
        sys.stderr.write(f"❌ link.md not found at {LINKS_FILE}\n")
        sys.exit(1)
    # Read URLs – ignore any leading '+' from diff blocks and skip empty/comment lines
    raw_urls = [
        line.strip().lstrip('+').strip()
        for line in LINKS_FILE.read_text().splitlines()
        if line.strip() and line.strip().lstrip('+').strip().startswith('http')
    ]
    if not raw_urls:
        print("⚠️  No URLs found in link.md")
        return

    manifest = load_manifest()
    start_index = len(manifest.get("items", [])) + 1

    for idx, url in enumerate(raw_urls, start=start_index):
        print(f"\n🔎  Processing [{idx}] {url}")
        # 2️⃣ Get video metadata via yt‑dlp JSON dump
        meta_json = run_cmd(["yt-dlp", "-j", url])
        meta = json.loads(meta_json)
        title_raw = meta.get("title", f"video_{idx}")
        title = sanitize_title(title_raw)
        thumbnail_url = meta.get("thumbnail")

        # 4️⃣ Rename files to deterministic scheme
        # 4️⃣ Define paths and create subdirectories
        VIDEOS_360_DIR = ASSETS_DIR / "360p"
        VIDEOS_720_DIR = ASSETS_DIR / "720p"
        IMAGES_DIR = ASSETS_DIR / "images"
        
        for d in [VIDEOS_360_DIR, VIDEOS_720_DIR, IMAGES_DIR]:
            d.mkdir(parents=True, exist_ok=True)

        base_name = f"{idx:02d}_{title}"
        dest_360 = VIDEOS_360_DIR / f"{base_name}_360p.mp4"
        dest_720 = VIDEOS_720_DIR / f"{base_name}_720p.mp4"
        thumb_path = IMAGES_DIR / f"{base_name}_thumb.jpg"

        # Check if files already exist (Resume capability)
        if dest_360.exists() and dest_720.exists():
            print(f"⏩  Files for '{title}' already exist. Skipping download.")
        else:
            # 3️⃣ Download 360p & 720p versions
            try:
                # Add --cookies-from-browser chrome if you get 403 errors
                # cmd.extend(["--cookies-from-browser", "chrome"])
                
                # Check and download 360p
                if not dest_360.exists():
                    file_360 = download_video(url, VIDEOS_360_DIR, height=360)
                    file_360.rename(dest_360)
                
                # Check and download 720p
                if not dest_720.exists():
                    file_720 = download_video(url, VIDEOS_720_DIR, height=720)
                    file_720.rename(dest_720)
                
                print(f"✅  Saved video files: {dest_360.name}, {dest_720.name}")
            except Exception as e:
                print(f"❌  Failed to download video for {url}: {e}")
                # If one fails, we might want to skip adding to manifest to avoid broken entries
                continue

        # 5️⃣ Download thumbnail (if available)
        if thumbnail_url:
            if thumb_path.exists():
                 print(f"⏩  Thumbnail already exists: {thumb_path.name}")
            else:
                try:
                    download_thumbnail(thumbnail_url, thumb_path)
                    print(f"✅  Saved thumbnail: {thumb_path.name}")
                except Exception as e:
                    print(f"⚠️  Could not download thumbnail: {e}")
                    thumb_path = None
        else:
            print("⚠️  No thumbnail URL found in metadata.")

        # 6️⃣ Append entry to manifest
        qualities = []

        if dest_360.exists():
            size_360_mb = bytes_to_mb_decimal(dest_360.stat().st_size)
            qualities.append({
                "label": "360p",
                "url": f"assets/videos/360p/{dest_360.name}",
                "sizeMB": math.ceil(size_360_mb)
            })

        if dest_720.exists():
            size_720_mb = bytes_to_mb_decimal(dest_720.stat().st_size)
            qualities.append({
                "label": "720p",
                "url": f"assets/videos/720p/{dest_720.name}",
                "sizeMB": math.ceil(size_720_mb)
            })

        # streamUrl: ưu tiên 720p, không có thì 360p, không có nữa thì ""
        stream_url = ""
        if dest_720.exists():
            stream_url = f"assets/videos/720p/{dest_720.name}"
        elif dest_360.exists():
            stream_url = f"assets/videos/360p/{dest_360.name}"

        entry = {
            "id": str(uuid.uuid4()),
            "title": title_raw,
            "description": meta.get("description", ""),
            "durationSec": meta.get("duration", 0),
            "thumbnailUrl": f"assets/videos/images/{thumb_path.name}" if thumb_path and thumb_path.exists() else "",
            "streamUrl": stream_url,
            "download": {
                "qualities": qualities
            },
            "tags": meta.get("tags", [])
        }
        manifest.setdefault("items", []).append(entry)
        print(f"📝  Manifest entry added for '{title_raw}'.")
        
        # Save incrementally
        save_manifest(manifest)

    # 7️⃣ Save updated manifest
    save_manifest(manifest)
    print("\n✅  All done! 🎉")

if __name__ == "__main__":
    main()