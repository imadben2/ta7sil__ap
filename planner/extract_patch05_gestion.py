#!/usr/bin/env python3
"""
Extract text from management stream images for Patch 05 (Days 57-70)
Using Google Cloud Vision API
"""

import os
import sys
from pathlib import Path
import json

try:
    from google.cloud import vision
except ImportError:
    print("Installing google-cloud-vision...")
    os.system("pip install google-cloud-vision")
    from google.cloud import vision

# Set Google Cloud credentials
credentials_path = Path(__file__).parent / 'bac-study-vision-key.json'
if credentials_path.exists():
    os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = str(credentials_path)
else:
    print(f"⚠️ Warning: Credentials file not found at {credentials_path}")
    print("   The script will fail if credentials are not set.")

def extract_text_from_image(image_path):
    """Extract text from image using Google Vision API"""
    client = vision.ImageAnnotatorClient()

    with open(image_path, 'rb') as image_file:
        content = image_file.read()

    image = vision.Image(content=content)
    response = client.text_detection(image=image)

    if response.error.message:
        raise Exception(f'{response.error.message}')

    texts = response.text_annotations
    if texts:
        return texts[0].description
    return ""

def main():
    """Extract text from images 41-55 (estimated to contain Days 57-70)"""

    base_path = Path(r'c:\Dev2026\1\planner\gestion_batches')

    # Images to process
    batches = [
        ('batch_05', range(41, 51)),  # Images 41-50
        ('batch_06', range(51, 56)),  # Images 51-55
    ]

    results = []

    print("=" * 70)
    print("EXTRACTING TEXT FROM MANAGEMENT STREAM IMAGES (Patch 05)")
    print("=" * 70)
    print()

    for batch_name, image_range in batches:
        batch_path = base_path / batch_name

        for img_num in image_range:
            image_name = f'مستر_باك_باك_في_يوم_100_تسيير_واقتصاد_{img_num}.jpg'
            image_path = batch_path / image_name

            if not image_path.exists():
                print(f"⚠️  Image not found: {image_name}")
                continue

            print(f"📖 Processing Image {img_num}...")

            try:
                text = extract_text_from_image(str(image_path))

                # Try to detect day number
                import re
                day_match = re.search(r'اليوم\s*(\d+)', text)
                day_number = int(day_match.group(1)) if day_match else None

                result = {
                    'image_number': img_num,
                    'day_number': day_number,
                    'full_text': text
                }

                results.append(result)

                if day_number:
                    print(f"   ✅ Day {day_number} detected")
                    # Show first 200 characters
                    preview = text.replace('\n', ' ')[:200]
                    print(f"   Preview: {preview}...")
                else:
                    print(f"   ⚠️  Day number not detected")

                print()

            except Exception as e:
                print(f"   ❌ Error: {e}")
                print()
                continue

    # Save results to JSON
    output_file = Path(__file__).parent / 'patch05_extraction_results.json'
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(results, f, ensure_ascii=False, indent=2)

    print("=" * 70)
    print(f"✅ Extraction complete: {len(results)} images processed")
    print(f"📄 Results saved to: {output_file}")
    print("=" * 70)
    print()

    # Summary
    days_found = sorted([r['day_number'] for r in results if r['day_number']])
    if days_found:
        print(f"📊 Days detected: {days_found}")
        print(f"   Range: Day {min(days_found)} - Day {max(days_found)}")
        print(f"   Total: {len(days_found)} days")

        # Check if we have all days 57-70
        expected_days = set(range(57, 71))
        found_days = set(days_found)
        missing_days = expected_days - found_days

        if missing_days:
            print(f"\n⚠️  Missing days: {sorted(missing_days)}")
        else:
            print(f"\n✅ All days 57-70 found!")
    else:
        print("⚠️  No days detected in images")

    print()
    print("Next step: Review patch05_extraction_results.json and structure data for PHP seeder")

if __name__ == '__main__':
    main()
