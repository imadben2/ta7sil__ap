#!/usr/bin/env python3
"""
Script to convert adab PDF to images and batch them into adab_batch folders
"""

import os
import re
import shutil
from pathlib import Path

try:
    from pdf2image import convert_from_path
except ImportError:
    print("Installing pdf2image...")
    os.system("pip install pdf2image")
    from pdf2image import convert_from_path

# Configuration
PDF_FILE = Path(__file__).parent / "مستر باك - آداب وفلسفة (1).pdf"
IMAGES_DIR = Path(__file__).parent / "adab"
OUTPUT_DIR = Path(__file__).parent / "adab_batch"
BATCH_SIZE = 10  # Number of images per batch

def main():
    # Check if PDF exists
    if not PDF_FILE.exists():
        print(f"Error: PDF file not found: {PDF_FILE}")
        return

    # Create images directory
    IMAGES_DIR.mkdir(exist_ok=True)

    # Check if images already exist
    existing_images = list(IMAGES_DIR.glob("*.jpg"))

    if existing_images:
        print(f"Found {len(existing_images)} existing images in adab folder")
        jpg_files = existing_images
    else:
        print(f"Converting PDF to images: {PDF_FILE.name}")
        print("This may take a few minutes...")

        try:
            # Convert PDF to images
            images = convert_from_path(str(PDF_FILE), dpi=150, fmt='jpeg')
            print(f"Converted {len(images)} pages")

            # Save images
            for i, image in enumerate(images, 1):
                image_path = IMAGES_DIR / f"adab_page_{i:03d}.jpg"
                image.save(str(image_path), 'JPEG', quality=85)
                print(f"  Saved: {image_path.name}")

            jpg_files = list(IMAGES_DIR.glob("*.jpg"))
        except Exception as e:
            print(f"Error converting PDF: {e}")
            print("\nNote: pdf2image requires poppler to be installed.")
            print("On Windows, download from: https://github.com/osber/poppler-windows/releases")
            print("Then add the 'bin' folder to your PATH")
            return

    # Sort by page number
    def extract_number(filename):
        match = re.search(r'_(\d+)\.jpg$', str(filename))
        if match:
            return int(match.group(1))
        return 0

    jpg_files.sort(key=lambda f: extract_number(f.name))

    print(f"\nTotal images: {len(jpg_files)}")

    # Create output directory
    OUTPUT_DIR.mkdir(exist_ok=True)

    # Create batches
    batches = []
    current_batch = []

    for file in jpg_files:
        current_batch.append(file)
        if len(current_batch) == BATCH_SIZE:
            batches.append(current_batch)
            current_batch = []

    # Add remaining files as last batch
    if current_batch:
        batches.append(current_batch)

    print(f"Total batches: {len(batches)}")
    print(f"Batch size: {BATCH_SIZE} images per batch")
    print("-" * 50)

    # Create batch folders
    for i, batch in enumerate(batches, 1):
        start_num = extract_number(batch[0].name)
        end_num = extract_number(batch[-1].name)
        print(f"Batch {i}: {len(batch)} images (pages {start_num} to {end_num})")

        # Create batch folder
        batch_folder = OUTPUT_DIR / f"adab_batch_{i:02d}"
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
