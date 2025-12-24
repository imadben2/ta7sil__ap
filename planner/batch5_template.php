/**
 * Batch 5: Days 57-70 (Weeks 9-10)
 *
 * INSTRUCTIONS:
 * 1. Ouvrez les images 41-55 dans gestion_batches/
 * 2. Pour chaque jour, remplissez le tableau ci-dessous
 * 3. Remplacez les données dans BacStudyScheduleManagementSeeder.php
 */
private function getBatch5Days(): array
{
    return [
        // ==================== Day 57 ====================
        [
            'day_number' => 57,
            'day_type' => 'study',
            'title_ar' => null,
            'subjects' => [
                [
                    'slug' => 'SUBJECT_SLUG',  // accounting, economics, law, mathematics, etc.
                    'topics' => [
                        ['topic_ar' => 'COPIER LE TEXTE DE L\'IMAGE', 'task_type' => 'study'],
                        // Ajouter d'autres topics si nécessaire
                    ]
                ],
                // Ajouter d'autres matières
            ]
        ],

        // ==================== Day 58 ====================
        [
            'day_number' => 58,
            'day_type' => 'study',
            'title_ar' => null,
            'subjects' => [
                // À remplir
            ]
        ],

        // ==================== Day 59 ====================
        [
            'day_number' => 59,
            'day_type' => 'study',
            'title_ar' => null,
            'subjects' => [
                // À remplir
            ]
        ],

        // ==================== Day 60 ====================
        [
            'day_number' => 60,
            'day_type' => 'study',
            'title_ar' => null,
            'subjects' => [
                // À remplir
            ]
        ],

        // ==================== Day 61 ====================
        [
            'day_number' => 61,
            'day_type' => 'study',
            'title_ar' => null,
            'subjects' => [
                // À remplir
            ]
        ],

        // ==================== Day 62 ====================
        [
            'day_number' => 62,
            'day_type' => 'study',
            'title_ar' => null,
            'subjects' => [
                // À remplir
            ]
        ],

        // ==================== Day 63 - Week 09 Reward ====================
        [
            'day_number' => 63,
            'day_type' => 'review',
            'title_ar' => 'مكافأة الأسبوع 09',
            'subjects' => [
                // Généralement: review topics pour plusieurs matières
            ]
        ],

        // ==================== Day 64 ====================
        [
            'day_number' => 64,
            'day_type' => 'study',
            'title_ar' => null,
            'subjects' => [
                // À remplir
            ]
        ],

        // ==================== Day 65 ====================
        [
            'day_number' => 65,
            'day_type' => 'study',
            'title_ar' => null,
            'subjects' => [
                // À remplir
            ]
        ],

        // ==================== Day 66 ====================
        [
            'day_number' => 66,
            'day_type' => 'study',
            'title_ar' => null,
            'subjects' => [
                // À remplir
            ]
        ],

        // ==================== Day 67 ====================
        [
            'day_number' => 67,
            'day_type' => 'study',
            'title_ar' => null,
            'subjects' => [
                // À remplir
            ]
        ],

        // ==================== Day 68 ====================
        [
            'day_number' => 68,
            'day_type' => 'study',
            'title_ar' => null,
            'subjects' => [
                // À remplir
            ]
        ],

        // ==================== Day 69 ====================
        [
            'day_number' => 69,
            'day_type' => 'study',
            'title_ar' => null,
            'subjects' => [
                // À remplir
            ]
        ],

        // ==================== Day 70 - Week 10 Reward ====================
        [
            'day_number' => 70,
            'day_type' => 'review',
            'title_ar' => 'مكافأة الأسبوع 10',
            'subjects' => [
                // Généralement: review topics pour plusieurs matières
            ]
        ],
    ];
}

/*
SUBJECT SLUGS DISPONIBLES:
- accounting          → التسيير المحاسبي والمالي
- economics           → الاقتصاد
- law                 → القانون
- mathematics         → الرياضيات
- arabic              → اللغة العربية
- french              → اللغة الفرنسية
- english             → اللغة الإنجليزية
- islamic-education   → التربية الإسلامية
- history-geography   → التاريخ والجغرافيا
- philosophy          → الفلسفة

TASK TYPES:
- study      → دراسة / فهم
- memorize   → حفظ
- review     → مراجعة / تكرار
- solve      → حل تمارين / حل موضوع
- exercise   → كتابة / تمرين
*/
