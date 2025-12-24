#!/usr/bin/env python3
"""
Script to open images one by one for manual data extraction
"""

from pathlib import Path
import os
import sys

def main():
    base_path = Path(r'c:\Dev2026\1\planner\gestion_batches')

    images = []

    # Collect all images from batch 05 and 06
    for batch_num in [5, 6]:
        batch_name = f'batch_0{batch_num}'
        batch_path = base_path / batch_name

        if batch_num == 5:
            img_range = range(41, 51)
        else:  # batch 06
            img_range = range(51, 56)

        for img_num in img_range:
            img_name = f'مستر_باك_باك_في_يوم_100_تسيير_واقتصاد_{img_num}.jpg'
            img_path = batch_path / img_name

            if img_path.exists():
                images.append((img_num, img_path))

    print("=" * 70)
    print("IMAGES POUR PATCH 05 (Days 57-70)")
    print("=" * 70)
    print()
    print(f"Total images trouvées: {len(images)}")
    print()

    for idx, (img_num, img_path) in enumerate(images, 1):
        print(f"{idx}. Image {img_num}: {img_path.name}")

    print()
    print("=" * 70)
    print()

    # Ask if user wants to open images
    response = input("Voulez-vous ouvrir les images une par une? (o/n): ")

    if response.lower() in ['o', 'oui', 'y', 'yes']:
        print()
        for idx, (img_num, img_path) in enumerate(images, 1):
            print(f"\n[{idx}/{len(images)}] Ouverture de l'image {img_num}...")
            print(f"Chemin: {img_path}")

            # Open image with default viewer
            os.startfile(str(img_path))

            input(f"Appuyez sur Entrée pour ouvrir l'image suivante (ou Ctrl+C pour arrêter)...")

        print("\n✅ Toutes les images ont été ouvertes!")
    else:
        print("\nVous pouvez ouvrir les images manuellement:")
        print(f"Dossier: {base_path}")

if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n⚠️ Arrêt demandé par l'utilisateur")
        sys.exit(0)
