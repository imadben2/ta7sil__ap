#!/usr/bin/env python3
"""
Script to batch images from gestion folder into PDF files
Groups images by numeric order into batches
"""

import os
import re
from pathlib import Path

# Configuration
GESTION_DIR = Path(__file__).parent / "gestion"
OUTPUT_DIR = Path(__file__).parent / "batches"
BATCH_SIZE = 10  # Number of images per batch

def extract_number(filename):
    """Extract the numeric suffix from filename like 'xxx_55.jpg' -> 55"""
    match = re.search(r'_(\d+)\.jpg$', filename)
    if match:
        return int(match.group(1))
    return 0

def main():
    # Get all jpg files
    jpg_files = list(GESTION_DIR.glob("*.jpg"))
    print(f"Found {len(jpg_files)} images in gestion folder")

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

        # Create batch folder
        batch_folder = OUTPUT_DIR / f"batch_{i:02d}"
        batch_folder.mkdir(exist_ok=True)

        # Create symbolic links or copy files
        for file in batch:
            dest = batch_folder / file.name
            if not dest.exists():
                # Copy file (Windows compatible)
                import shutil
                shutil.copy2(file, dest)

        print(f"   -> Saved to: {batch_folder}")

    print("-" * 50)
    print(f"Done! Created {len(batches)} batch folders in {OUTPUT_DIR}")

if __name__ == "__main__":
    main()
