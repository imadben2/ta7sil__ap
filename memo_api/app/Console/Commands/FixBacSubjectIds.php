<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\BacSubject;
use App\Models\Subject;
use Illuminate\Support\Facades\DB;

class FixBacSubjectIds extends Command
{
    protected $signature = 'bac:fix-subject-ids {--dry-run : Afficher sans modifier}';
    protected $description = 'Corrige les subject_id dans bac_subjects en se basant sur le titre';

    /**
     * Mapping des variations de noms de matières vers le nom standard
     */
    private function getNameVariations(): array
    {
        return [
            // Variations -> Nom standard dans la table subjects
            'اللغة الانجليزية' => 'اللغة الإنجليزية',  // ا vs إ
            'العلوم الفيزيائية' => 'الفيزياء',
            'العلوم الطبيعية' => 'علوم الطبيعة والحياة',
            'التاريخ و الجغرافيا' => 'التاريخ والجغرافيا',  // و vs والـ
            'الاقتصاد و المناجمنت' => 'الاقتصاد والمانجمنت',
            'التسيير المحاسبي والمالي' => 'المحاسبة والمالية',
        ];
    }

    public function handle()
    {
        $dryRun = $this->option('dry-run');

        if ($dryRun) {
            $this->info('=== MODE DRY-RUN (aucune modification) ===');
        }

        // Mapping des noms de matières vers les bons subject_id
        $subjects = Subject::all();
        $subjectMapping = $subjects->mapWithKeys(function ($subject) {
            return [$subject->name_ar => $subject->id];
        })->toArray();

        // Ajouter les variations de noms
        $variations = $this->getNameVariations();
        foreach ($variations as $variant => $standard) {
            if (isset($subjectMapping[$standard])) {
                $subjectMapping[$variant] = $subjectMapping[$standard];
            }
        }

        $this->info('Matières trouvées: ' . count($subjects));

        $fixed = 0;
        $errors = 0;
        $skipped = 0;

        // Récupérer tous les bac_subjects
        $bacSubjects = BacSubject::with(['subject', 'academicStream'])->get();

        foreach ($bacSubjects as $bacSubject) {
            // Extraire le nom de la matière du titre
            // Format: "بكالوريا 2023 - الرياضيات - الموضوع"
            $parts = explode(' - ', $bacSubject->title_ar);

            if (count($parts) >= 2) {
                $subjectName = trim($parts[1]); // Le nom de la matière est la 2ème partie

                // Chercher le bon subject_id (avec variations)
                $correctSubjectId = $subjectMapping[$subjectName] ?? null;

                // Si trouvé, vérifier que le stream correspond
                if ($correctSubjectId) {
                    // Chercher un subject avec le même nom ET le même academic_stream_id
                    $matchingSubject = $subjects->first(function ($s) use ($subjectName, $bacSubject, $variations) {
                        $nameToMatch = $variations[$subjectName] ?? $subjectName;
                        return $s->name_ar === $nameToMatch && $s->academic_stream_id === $bacSubject->academic_stream_id;
                    });

                    if ($matchingSubject) {
                        $correctSubjectId = $matchingSubject->id;
                    }
                }

                if ($correctSubjectId && $correctSubjectId != $bacSubject->subject_id) {
                    if ($dryRun) {
                        $this->line("→ ID {$bacSubject->id}: subject_id {$bacSubject->subject_id} → {$correctSubjectId} ({$subjectName})");
                    } else {
                        $bacSubject->subject_id = $correctSubjectId;
                        $bacSubject->save();
                        $this->line("✓ Corrigé ID {$bacSubject->id}: {$subjectName}");
                    }
                    $fixed++;
                } elseif (!$correctSubjectId) {
                    $this->warn("⚠ Matière non trouvée: '{$subjectName}' (ID {$bacSubject->id})");
                    $errors++;
                } else {
                    $skipped++;
                }
            }
        }

        $this->newLine();

        if ($dryRun) {
            $this->info("=== RÉSUMÉ (dry-run) ===");
            $this->info("À corriger: {$fixed}");
            $this->info("Déjà corrects: {$skipped}");
            $this->info("Erreurs: {$errors}");
            $this->newLine();
            $this->comment("Exécutez sans --dry-run pour appliquer les modifications.");
        } else {
            $this->info("=== RÉSUMÉ ===");
            $this->info("Corrigés: {$fixed}");
            $this->info("Déjà corrects: {$skipped}");
            $this->info("Erreurs: {$errors}");
        }

        return 0;
    }
}
