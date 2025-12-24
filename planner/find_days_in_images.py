#!/usr/bin/env python3
"""
Scan all images in gestion_batches to find which image corresponds to which day
Uses simple image viewer to manually identify days
"""

from pathlib import Path
import os

def main():
    base_path = Path(r'c:\Dev2026\1\planner\gestion_batches')

    # Collect all images from all batches
    all_images = []

    for batch_num in range(1, 7):  # batch_01 to batch_06
        batch_name = f'batch_0{batch_num}'
        batch_path = base_path / batch_name

        if batch_path.exists():
            images = sorted(batch_path.glob('*.jpg'))
            for img in images:
                # Extract image number from filename
                img_num = int(img.stem.split('_')[-1])
                all_images.append((img_num, img))

    # Sort by image number
    all_images.sort(key=lambda x: x[0])

    print("=" * 70)
    print("LISTE DES IMAGES DISPONIBLES")
    print("=" * 70)
    print()

    for img_num, img_path in all_images:
        print(f"Image {img_num:2d}: {img_path.name}")

    print()
    print("=" * 70)
    print(f"Total images: {len(all_images)}")
    print("=" * 70)
    print()

    # Based on previous patches pattern, estimate where days 57-70 should be
    print("ESTIMATION basée sur les patches précédents:")
    print("-" * 70)
    print("Patch 01 (Days 1-14)   ≈ Images 1-14")
    print("Patch 02 (Days 15-28)  ≈ Images 15-28")
    print("Patch 03 (Days 29-42)  ≈ Images 29-42")
    print("Patch 04 (Days 43-56)  ≈ Images 30-43")
    print()
    print("DONC:")
    print("Patch 05 (Days 57-70)  ≈ Images 44-57 (estimation)")
    print()
    print("Images à vérifier: 41-55")
    print("-" * 70)
    print()

    # Create mapping file
    mapping_file = Path(__file__).parent / 'image_day_mapping.txt'

    with open(mapping_file, 'w', encoding='utf-8') as f:
        f.write("IMAGE → DAY MAPPING (À REMPLIR MANUELLEMENT)\n")
        f.write("=" * 70 + "\n\n")
        f.write("Instructions:\n")
        f.write("1. Ouvrez chaque image\n")
        f.write("2. Cherchez 'اليوم' suivi d'un numéro\n")
        f.write("3. Remplissez le mapping ci-dessous\n\n")
        f.write("-" * 70 + "\n\n")

        for img_num in range(41, 56):
            f.write(f"Image {img_num} = Day _____\n")

        f.write("\n" + "=" * 70 + "\n")
        f.write("\nAPRÈS AVOIR REMPLI LE MAPPING:\n")
        f.write("Utilisez ce mapping pour créer le seeder PHP\n")

    print(f"✅ Fichier de mapping créé: {mapping_file}")
    print()
    print("PROCHAINES ÉTAPES:")
    print("1. Ouvrez les images 41-55 une par une")
    print("2. Pour chaque image, notez le numéro du jour (اليوم XX)")
    print("3. Remplissez le fichier: image_day_mapping.txt")
    print()

if __name__ == '__main__':
    main()
