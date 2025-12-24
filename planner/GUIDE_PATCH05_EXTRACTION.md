# Guide d'extraction Patch 05 - Jours 57-70

## Étapes

### 1. Trouver l'image du Jour 57

Ouvrez les images suivantes et cherchez "اليوم 57":

**Batch 05:**
- `gestion_batches/batch_05/مستر_باك_باك_في_يوم_100_تسيير_واقتصاد_41.jpg`
- `gestion_batches/batch_05/مستر_باك_باك_في_يوم_100_تسيير_واقتصاد_42.jpg`
- `gestion_batches/batch_05/مستر_باك_باك_في_يوم_100_تسيير_واقتصاد_43.jpg`
- `gestion_batches/batch_05/مستر_باك_باك_في_يوم_100_تسيير_واقتصاد_44.jpg`
- ... etc

**Une fois trouvé**, notez le numéro d'image.

### 2. Pattern de mapping

Si Jour 57 = Image X, alors:
- Jour 57 = Image X
- Jour 58 = Image X+1
- Jour 59 = Image X+2
- ...
- Jour 70 = Image X+13

### 3. Matières à identifier

Pour chaque jour, identifiez les matières (subjects) dans l'image:

**Slugs disponibles:**
- `accounting` → التسيير المحاسبي والمالي / المحاسبة
- `economics` → الاقتصاد
- `law` → القانون
- `mathematics` → الرياضيات
- `arabic` → اللغة العربية
- `french` → اللغة الفرنسية / Français
- `english` → اللغة الإنجليزية / English
- `islamic-education` → التربية الإسلامية
- `history-geography` → التاريخ والجغرافيا
- `philosophy` → الفلسفة

### 4. Task Types

Identifiez le type de tâche pour chaque topic:

- `study` → دراسة / فهم / شرح
- `memorize` → حفظ
- `review` → مراجعة / تكرار
- `solve` → حل تمارين / حل موضوع / تطبيقات
- `exercise` → كتابة / تمرين / إنتاج كتابي

### 5. Jours spéciaux

- **Jour 63** (Day 63) = مكافأة الأسبوع 09 (Week 9 reward)
  - `day_type` = `'review'`
  - `title_ar` = `'مكافأة الأسبوع 09'`

- **Jour 70** (Day 70) = مكافأة الأسبوع 10 (Week 10 reward)
  - `day_type` = `'review'`
  - `title_ar` = `'مكافأة الأسبوع 10'`

## Template PHP à remplir

```php
private function getBatch5Days(): array
{
    return [
        // ==================== Day 57 ====================
        [
            'day_number' => 57,
            'day_type' => 'study', // or 'review' if it's a reward day
            'title_ar' => null, // or 'مكافأة الأسبوع XX' for reward days
            'subjects' => [
                [
                    'slug' => 'SUBJECT_SLUG_HERE',
                    'topics' => [
                        ['topic_ar' => 'COPIER LE TEXTE DE L\'IMAGE ICI', 'task_type' => 'TYPE_HERE'],
                        ['topic_ar' => 'AUTRE TOPIC SI PRÉSENT', 'task_type' => 'TYPE_HERE'],
                    ]
                ],
                [
                    'slug' => 'ANOTHER_SUBJECT_SLUG',
                    'topics' => [
                        ['topic_ar' => 'TOPIC TEXT', 'task_type' => 'TYPE_HERE'],
                    ]
                ],
                // Add more subjects as needed
            ]
        ],

        // ==================== Day 58 ====================
        [
            'day_number' => 58,
            'day_type' => 'study',
            'title_ar' => null,
            'subjects' => [
                // ... similar structure
            ]
        ],

        // ... Days 59-70
    ];
}
```

## Exemple concret (basé sur Patch 04 Day 43)

```php
[
    'day_number' => 43,
    'day_type' => 'study',
    'title_ar' => null,
    'subjects' => [
        [
            'slug' => 'accounting',
            'topics' => [
                ['topic_ar' => 'الوحدة 11: تحليل الميزانية الوظيفية', 'task_type' => 'study'],
            ]
        ],
        [
            'slug' => 'french',
            'topics' => [
                ['topic_ar' => 'La structure d\'un texte argumentatif', 'task_type' => 'study'],
                ['topic_ar' => 'L\'opposition et la concession', 'task_type' => 'study'],
            ]
        ],
        [
            'slug' => 'history-geography',
            'topics' => [
                ['topic_ar' => 'حفظ المصطلحات الجغرافية', 'task_type' => 'memorize'],
            ]
        ],
    ]
],
```

## Checklist

- [ ] Trouver l'image du Jour 57
- [ ] Extraire Jour 57 → remplacer dans le template
- [ ] Extraire Jour 58 → ajouter au tableau
- [ ] Extraire Jour 59
- [ ] Extraire Jour 60
- [ ] Extraire Jour 61
- [ ] Extraire Jour 62
- [ ] Extraire Jour 63 (Reward Week 9)
- [ ] Extraire Jour 64
- [ ] Extraire Jour 65
- [ ] Extraire Jour 66
- [ ] Extraire Jour 67
- [ ] Extraire Jour 68
- [ ] Extraire Jour 69
- [ ] Extraire Jour 70 (Reward Week 10)
- [ ] Tester le seeder
- [ ] Vérifier la base de données
