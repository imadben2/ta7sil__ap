#!/usr/bin/env python3
"""
Quick script to identify which image contains Day 57
We'll check images 40-55 to find the starting point
"""

from pathlib import Path

# Check both batch folders
batches = [
    ('batch_05', range(41, 51)),
    ('batch_06', range(51, 56)),
]

print("Images available for Days 57-70:")
print("=" * 60)

for batch_name, img_range in batches:
    print(f"\n{batch_name}:")
    batch_path = Path(r'c:\Dev2026\1\planner\gestion_batches') / batch_name

    for img_num in img_range:
        img_name = f'مستر_باك_باك_في_يوم_100_تسيير_واقتصاد_{img_num}.jpg'
        img_path = batch_path / img_name

        if img_path.exists():
            print(f"  Image {img_num}: {img_path}")

print("\n" + "=" * 60)
print("\nBased on previous pattern:")
print("- Patch 01 (Days 1-14)   ≈ Images 1-14")
print("- Patch 02 (Days 15-28)  ≈ Images 15-28")
print("- Patch 03 (Days 29-42)  ≈ Images 29-42")
print("- Patch 04 (Days 43-56)  ≈ Images 30-43 (some overlap)")
print("- Patch 05 (Days 57-70)  ≈ Images 44-57 (estimated)")
print("\n⚠️ We need to manually check images 41-55 to find Day 57")
print("   Please visually inspect images to identify اليوم 57")
