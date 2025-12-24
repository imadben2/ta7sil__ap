# Patch 05 - Jours 57-70 - Guide Complet

## Statut Actuel ✅

- ✅ **Suppression des données incorrectes** - TERMINÉE
  - 14 jours supprimés
  - 45 affectations supprimées
  - Base de données nettoyée

- 🔄 **Extraction des nouvelles données** - EN COURS
  - Nécessite extraction manuelle (pas de credentials Google Cloud Vision)

---

## Fichiers Créés

### 1. Templates et Guides
- **`GUIDE_PATCH05_EXTRACTION.md`** - Guide détaillé d'extraction
- **`manual_extraction_template.txt`** - Template pour noter les données
- **`batch5_template.php`** - Template PHP à remplir
- **`PATCH05_README.md`** - Ce fichier

### 2. Scripts Utilitaires
- **`view_images.py`** - Ouvre les images une par une
- **`delete_patch05.php`** - Script de suppression (déjà exécuté)
- **`extract_patch05_gestion.py`** - Script OCR (nécessite credentials)

---

## Processus d'Extraction Manuel

### Étape 1: Visualiser les Images

```bash
cd c:\Dev2026\1\planner
python view_images.py
```

Ou ouvrez manuellement:
- `gestion_batches/batch_05/` - Images 41-50
- `gestion_batches/batch_06/` - Images 51-55

### Étape 2: Identifier le Mapping

Pour chaque image, trouvez le numéro du jour (اليوم XX):

| Image | Jour | Trouvé? |
|-------|------|---------|
| 41    | ?    | ❌      |
| 42    | ?    | ❌      |
| 43    | ?    | ❌      |
| 44    | ?    | ❌      |
| 45    | ?    | ❌      |
| 46    | ?    | ❌      |
| 47    | ?    | ❌      |
| 48    | ?    | ❌      |
| 49    | ?    | ❌      |
| 50    | ?    | ❌      |
| 51    | ?    | ❌      |
| 52    | ?    | ❌      |
| 53    | ?    | ❌      |
| 54    | ?    | ❌      |
| 55    | ?    | ❌      |

### Étape 3: Extraire les Données

Pour chaque jour (57-70), notez:

1. **Numéro du jour**
2. **Type**: `study` ou `review` (jours 63 et 70)
3. **Matières présentes** et leurs topics
4. **Type de tâche** pour chaque topic

Utilisez `manual_extraction_template.txt` pour structurer vos notes.

### Étape 4: Remplir le Template PHP

Ouvrez `batch5_template.php` et remplissez avec les données extraites.

Structure par jour:
```php
[
    'day_number' => 57,
    'day_type' => 'study',
    'title_ar' => null,
    'subjects' => [
        [
            'slug' => 'accounting',
            'topics' => [
                ['topic_ar' => 'الوحدة 13: ...', 'task_type' => 'study'],
                ['topic_ar' => 'حل تمارين', 'task_type' => 'solve'],
            ]
        ],
        [
            'slug' => 'french',
            'topics' => [
                ['topic_ar' => 'Le texte argumentatif', 'task_type' => 'study'],
            ]
        ],
    ]
],
```

### Étape 5: Mettre à Jour le Seeder

1. Ouvrez `memo_api/database/seeders/BacStudyScheduleManagementSeeder.php`
2. Localisez la méthode `getBatch5Days()` (ligne ~1773)
3. Remplacez le contenu par vos données

### Étape 6: Tester

```bash
cd c:\Dev2026\1\memo_api
php artisan db:seed --class=BacStudyScheduleManagementSeeder
```

### Étape 7: Vérifier

```bash
php artisan tinker --execute="echo DB::table('bac_study_days')->join('academic_streams', 'bac_study_days.academic_stream_id', '=', 'academic_streams.id')->where('academic_streams.slug', 'management-economics')->whereBetween('day_number', [57, 70])->count();"
```

Résultat attendu: **14**

---

## Subject Slugs (Référence Rapide)

| Slug | Matière (AR) | Matière (FR) |
|------|-------------|--------------|
| `accounting` | التسيير المحاسبي والمالي | Comptabilité |
| `economics` | الاقتصاد | Économie |
| `law` | القانون | Droit |
| `mathematics` | الرياضيات | Mathématiques |
| `arabic` | اللغة العربية | Arabe |
| `french` | اللغة الفرنسية | Français |
| `english` | اللغة الإنجليزية | Anglais |
| `islamic-education` | التربية الإسلامية | Éducation islamique |
| `history-geography` | التاريخ والجغرافيا | Histoire-Géo |
| `philosophy` | الفلسفة | Philosophie |

---

## Task Types (Référence Rapide)

| Type | Indicateurs (AR) | Description |
|------|-----------------|-------------|
| `study` | دراسة / فهم / شرح | Nouveau contenu |
| `memorize` | حفظ | Mémorisation |
| `review` | مراجعة / تكرار | Révision |
| `solve` | حل تمارين / حل موضوع | Exercices |
| `exercise` | كتابة / تمرين | Production |

---

## Jours Spéciaux

### Jour 63 - Récompense Semaine 9
```php
[
    'day_number' => 63,
    'day_type' => 'review',
    'title_ar' => 'مكافأة الأسبوع 09',
    'subjects' => [
        // Topics de révision
    ]
],
```

### Jour 70 - Récompense Semaine 10
```php
[
    'day_number' => 70,
    'day_type' => 'review',
    'title_ar' => 'مكافأة الأسبوع 10',
    'subjects' => [
        // Topics de révision
    ]
],
```

---

## Pattern Observé des Patches Précédents

Basé sur les patches 1-4:

**Patch 01 (Days 1-14):**
- ~3 matières par jour
- ~2-3 topics par matière
- Day 7 et 14 = review

**Patch 02-04 (Days 15-56):**
- Structure similaire
- Jours 21, 28, 35, 42, 49, 56 = review
- Plus de "حل موضوع بكالوريا" vers la fin

**Patch 05 attendu (Days 57-70):**
- Probablement plus de révisions
- Sujets de baccalauréat complets
- Focus sur consolidation

---

## Troubleshooting

### Problème: "Day already exists"
```bash
# Vérifier si le jour existe déjà
php artisan tinker --execute="DB::table('bac_study_days')->where('day_number', 57)->where('academic_stream_id', 4)->exists() ? 'EXISTS' : 'NOT FOUND';"

# Supprimer manuellement
php delete_patch05.php
```

### Problème: "Subject not found"
Vérifiez que le slug est correct dans la liste ci-dessus.

### Problème: Données mal formatées
Vérifiez:
- Guillemets échappés: `L\'opposition`
- Structure de tableau correcte
- Virgules entre les éléments

---

## Contact / Support

Pour toute question sur le processus d'extraction, référez-vous à:
- `docs/project_tree.md`
- `.claude/plans/greedy-crafting-ocean.md`
