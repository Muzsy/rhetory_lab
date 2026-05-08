#!/usr/bin/env python3
"""
Exports rhetoric_lab to Google Drive as a ZIP file.
Usage: python3 export_to_drive.py [--dry-run]
"""

import os
import json
import zipfile
import tempfile
from pathlib import Path
from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build
from googleapiclient.http import MediaFileUpload
from googleapiclient.errors import HttpError

# === CONFIG ===
SOURCE_DIR = Path("/home/muszy/projects/rhetoric_lab")
DRIVE_FOLDER_ID = "1jopZI2j-Mr_ZeAK03fgOVA-SfKmP1Jrx"  # rhetoric_lab Drive folder
TOKEN_PATH = Path.home() / ".hermes" / "google_token.json"

# Exclusions (path prefixes relative to SOURCE_DIR)
EXCLUDE_PREFIXES = [
    ".git",
    ".dart_tool",
    ".idea",
    ".gradle",
    "build",
    "tmp",
    ".env.local",
    ".flutter-plugins-dependencies",
    "supabase/.temp",
    "supabase/cli-latest",
    "rhetorium.iml",
    ".vscode",
    "node_modules",
]

# Files (not dirs) to exclude by name
EXCLUDE_NAMES = {
    ".DS_Store",
    "local.properties",
    ".generated",
}

# === DRIVE SETUP ===
def get_drive_service():
    creds = Credentials.from_authorized_user_info(json.load(open(TOKEN_PATH)))
    return build('drive', 'v3', credentials=creds)

def should_exclude(path: Path) -> bool:
    """Check if a path should be excluded."""
    rel = str(path.relative_to(SOURCE_DIR))
    
    if path.name in EXCLUDE_NAMES:
        return True
    
    for prefix in EXCLUDE_PREFIXES:
        if rel.startswith(prefix) or f"/{prefix}/" in rel:
            return True
    
    return False

def create_zip(source_dir, dry_run=False):
    """Create a zip of the source directory."""
    zip_name = f"rhetoric_lab_export.zip"
    zip_path = source_dir / zip_name
    
    if dry_run:
        print(f"  [DRY] Would create: {zip_path}")
        return None
    
    if zip_path.exists():
        os.remove(zip_path)
    
    with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zf:
        for root, dirs, filenames in os.walk(source_dir):
            root_path = Path(root)
            
            # Filter out excluded directories
            dirs[:] = [d for d in dirs if not should_exclude(root_path / d)]
            
            for fname in filenames:
                fpath = root_path / fname
                if should_exclude(fpath):
                    continue
                arcname = fpath.relative_to(source_dir)
                zf.write(fpath, arcname)
                print(f"  Added: {arcname}")
    
    print(f"  Created: {zip_path} ({os.path.getsize(zip_path) / 1024:.1f} KB)")
    return zip_path

def upload_zip(drive, zip_path, parent_id, dry_run=False):
    """Upload zip file to Drive."""
    name = zip_path.name
    
    if dry_run:
        print(f"  [DRY] Would upload: {name}")
        return
    
    media = MediaFileUpload(str(zip_path))
    
    # Check if already exists
    results = drive.files().list(
        q=f"name='{name}' and '{parent_id}' in parents and mimeType!='application/vnd.google-apps.folder'",
        spaces='drive',
        fields='files(id, name)'
    ).execute()
    
    existing = results.get('files', [])
    
    if existing:
        print(f"  Updating existing: {name}")
        file_id = existing[0]['id']
        drive.files().update(fileId=file_id, media_body=media).execute()
    else:
        print(f"  Uploading: {name}")
        file_metadata = {'name': name, 'parents': [parent_id]}
        drive.files().create(body=file_metadata, media_body=media, fields='id,name,webViewLink').execute()

def main():
    import sys
    dry_run = "--dry-run" in sys.argv
    
    print(f"rhetoric_lab → Google Drive (as ZIP)")
    print(f"Source: {SOURCE_DIR}")
    print(f"Destination: rhetoric_lab folder (ID: {DRIVE_FOLDER_ID})")
    print()
    
    if dry_run:
        print("DRY RUN")
        print()
    
    # Count files first
    count = 0
    for root, dirs, filenames in os.walk(SOURCE_DIR):
        root_path = Path(root)
        dirs[:] = [d for d in dirs if not should_exclude(root_path / d)]
        for fname in filenames:
            if not should_exclude(root_path / fname):
                count += 1
    
    print(f"Files to archive: {count}")
    print()
    
    # Create zip
    print("Creating ZIP...")
    zip_path = create_zip(SOURCE_DIR, dry_run)
    
    if zip_path is None:
        print("(dry run, skipping upload)")
        return
    
    # Upload
    print()
    print("Uploading to Drive...")
    drive = get_drive_service()
    upload_zip(drive, zip_path, DRIVE_FOLDER_ID)
    
    print()
    print("Done!")

if __name__ == "__main__":
    main()
