<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\BacSubject;
use Illuminate\Support\Facades\DB;

class MergeBacSubjectsDuplicates extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'bac:merge-duplicates {--dry-run : Afficher les doublons sans les fusionner}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Fusionne les lignes sujet/correction en doublons dans la table bac_subjects';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $dryRun = $this->option('dry-run');

        if ($dryRun) {
            $this->info('=== MODE DRY-RUN (aucune modification) ===');
        }

        $this->info('Recherche des doublons...');

        // Trouver les doublons (même year, session, subject, stream)
        $duplicates = DB::table('bac_subjects')
            ->select('bac_year_id', 'bac_session_id', 'subject_id', 'academic_stream_id')
            ->selectRaw('COUNT(*) as count')
            ->selectRaw('GROUP_CONCAT(id) as ids')
            ->groupBy('bac_year_id', 'bac_session_id', 'subject_id', 'academic_stream_id')
            ->having('count', '>', 1)
            ->get();

        $this->info("Groupes de doublons trouvés: " . $duplicates->count());

        if ($duplicates->count() === 0) {
            $this->info('Aucun doublon à fusionner.');
            return 0;
        }

        $merged = 0;
        $skipped = 0;

        foreach ($duplicates as $dup) {
            $ids = explode(',', $dup->ids);
            $rows = BacSubject::whereIn('id', $ids)->get();

            // Séparer sujet (الموضوع) et correction (التصحيح)
            $sujet = $rows->first(fn($r) => str_contains($r->title_ar, 'الموضوع'));
            $correction = $rows->first(fn($r) => str_contains($r->title_ar, 'التصحيح'));

            if ($sujet && $correction) {
                if ($dryRun) {
                    $this->line("→ [À fusionner] ID {$sujet->id} (الموضوع) + ID {$correction->id} (التصحيح)");
                    $this->line("   Titre: {$sujet->title_ar}");
                } else {
                    // Copier le fichier correction vers correction_file_path du sujet
                    $sujet->correction_file_path = $correction->file_path;

                    // Cumuler les statistiques
                    $sujet->views_count += $correction->views_count;
                    $sujet->downloads_count += $correction->downloads_count;
                    $sujet->simulations_count += $correction->simulations_count;

                    $sujet->save();

                    // Supprimer la ligne correction (devenue inutile)
                    $correction->delete();

                    $this->line("✓ Fusionné: ID {$sujet->id} - {$sujet->title_ar}");
                }
                $merged++;
            } else {
                // Cas où on ne peut pas identifier clairement sujet/correction
                $this->warn("⚠ Ignoré (pas de paire sujet/correction claire): IDs " . implode(', ', $ids));
                $skipped++;
            }
        }

        $this->newLine();

        if ($dryRun) {
            $this->info("=== RÉSUMÉ (dry-run) ===");
            $this->info("Doublons à fusionner: {$merged}");
            $this->info("Ignorés: {$skipped}");
            $this->newLine();
            $this->comment("Exécutez sans --dry-run pour appliquer les modifications.");
        } else {
            $this->info("=== RÉSUMÉ ===");
            $this->info("Doublons fusionnés: {$merged}");
            $this->info("Ignorés: {$skipped}");
        }

        return 0;
    }
}
