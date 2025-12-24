#!/usr/bin/env python3
"""
Script to batch images from lettre folder into lettre_batch folders
Groups images by numeric order into batches
"""

import os
import re
import shutil
from pathlib import Path

# Configuration
LETTRE_DIR = Path(__file__).parent / "lettre"
OUTPUT_DIR = Path(__file__).parent / "lettre_batch"
BATCH_SIZE = 10  # Number of images per batch

def extract_number(filename):
    """Extract the numeric suffix from filename like 'xxx_55.jpg' -> 55"""
    match = re.search(r'_(\d+)\.jpg$', filename)
    if match:
        return int(match.group(1))
    return 0

def main():
    # Get all jpg files
    jpg_files = list(LETTRE_DIR.glob("*.jpg"))
    print(f"Found {len(jpg_files)} images in lettre folder")

    # Sort by numeric order
    jpg_files.sort(key=lambda f: extract_number(f.name))

    # Create output directory
    OUTPUT_DIR.mkdir(exist_ok=True)

    # Create batches
    batches = []
    current_batch = []

    for i, file in enumerate(jpg_files, 1):
        current_batch.append(file)
        if len(current_batch) == BATCH_SIZE:
            batches.append(current_batch)
            current_batch = []

    # Add remaining files as last batch
    if current_batch:
        batches.append(current_batch)

    print(f"\nTotal batches: {len(batches)}")
    print(f"Batch size: {BATCH_SIZE} images per batch")
    print("-" * 50)

    # Report batches
    for i, batch in enumerate(batches, 1):
        start_num = extract_number(batch[0].name)
        end_num = extract_number(batch[-1].name)
        print(f"Batch {i}: {len(batch)} images (pages {start_num} to {end_num})")

        # Create batch folder with lettre_batch name
        batch_folder = OUTPUT_DIR / f"lettre_batch_{i:02d}"
        batch_folder.mkdir(exist_ok=True)

        # Copy files
        for file in batch:
            dest = batch_folder / file.name
            if not dest.exists():
                shutil.copy2(file, dest)

        print(f"   -> Saved to: {batch_folder}")

    print("-" * 50)
    print(f"Done! Created {len(batches)} batch folders in {OUTPUT_DIR}")

if __name__ == "__main__":
    main()
