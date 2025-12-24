<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Str;

class MigrateTa7silBac extends Command
{
    protected $signature = 'migrate:ta7sil-bac
                            {--dry-run : Preview changes without executing}
                            {--with-files : Copy PDF files to memo_app storage}
                            {--year= : Migrate specific year only (e.g., 2008)}';

    protected $description = 'Migrate BAC data from Ta7sil app to Memo app';

    // Mapping: Ta7sil doc_specialities.title => Memo academic_streams.id
    private array $streamMapping = [
        'شعبة علوم تجريبية' => 1,    // علوم تجريبية
        'شعبة رياضيات' => 2,         // رياضيات
        'شعبة تقني رياضي' => 3,      // تقني رياضي
        'شعبة تسيير واقتصاد' => 4,   // تسيير واقتصاد
        'شعبة اداب وفلسفة' => 5,     // آداب وفلسفة
        'شعبة لغات أجنبية' => 6,     // لغات أجنبية
        'الشعب العلمية' => 1,         // Default to علوم تجريبية
    ];

    // Mapping: Ta7sil doc_subjects.title => Memo subjects by stream
    // Format: subject_name => [stream_id => subject_id]
    private array $subjectMapping = [
        'اللغة العربية' => [1 => 4, 2 => 13, 3 => 22, 4 => 32, 5 => 38, 6 => 48],
        'اللغة الفرنسية' => [1 => 5, 2 => 14, 3 => 23, 4 => 33, 5 => 40, 6 => 45],
        'اللغة الانجليزية' => [1 => 6, 2 => 15, 3 => 24, 4 => 34, 5 => 42, 6 => 46],
        'اللغة الإنجليزية' => [1 => 6, 2 => 15, 3 => 24, 4 => 34, 5 => 42, 6 => 46],
        'الرياضيات' => [1 => 1, 2 => 10, 3 => 19, 4 => 28, 5 => 44],
        'العلوم الطبيعية' => [1 => 3, 2 => 12],
        'العلوم الفيزيائية' => [1 => 2, 2 => 11, 3 => 20],
        'الفيزياء' => [1 => 2, 2 => 11, 3 => 20],
        'العلوم الإسلامية' => [1 => 9, 2 => 18, 3 => 27, 4 => 37, 5 => 43, 6 => 51],
        'التاريخ و الجغرافيا' => [1 => 8, 2 => 17, 3 => 26, 4 => 36, 5 => 41, 6 => 50],
        'التاريخ والجغرافيا' => [1 => 8, 2 => 17, 3 => 26, 4 => 36, 5 => 41, 6 => 50],
        'الفلسفة' => [1 => 7, 2 => 16, 3 => 25, 4 => 35, 5 => 39, 6 => 49],
        'الهندسة الكهربائية' => [3 => 21],
        'هندسة الطرائق' => [3 => 55],      // NEW: هندسة الطرائق (ID: 55)
        'الهندسة المدنية' => [3 => 53],    // NEW: الهندسة المدنية (ID: 53)
        'الهندسة الميكانيكية' => [3 => 54], // NEW: الهندسة الميكانيكية (ID: 54)
        'التسيير المحاسبي والمالي' => [4 => 31],
        'الاقتصاد و المناجمنت' => [4 => 29],
        'القانون' => [4 => 30],
        'اللغة الإسبانية' => [6 => 57],    // NEW: اللغة الإسبانية (ID: 57)
        'اللغة الألمانية' => [6 => 56],    // NEW: اللغة الألمانية (ID: 56)
    ];

    private int $createdYears = 0;
    private int $createdSessions = 0;
    private int $createdSubjects = 0;
    private int $copiedFiles = 0;
    private int $skippedFiles = 0;
    private array $errors = [];

    public function handle()
    {
        $this->info('=== Ta7sil BAC Migration ===');
        $this->newLine();

        $dryRun = $this->option('dry-run');
        $withFiles = $this->option('with-files');
        $specificYear = $this->option('year');

        if ($dryRun) {
            $this->warn('DRY RUN MODE - No changes will be made');
            $this->newLine();
        }

        // Configure ta7sil database connection
        config(['database.connections.ta7sil' => [
            'driver' => 'mysql',
            'host' => '127.0.0.1',
            'port' => '3306',
            'database' => 'tasilc75_tahssil_bundle',
            'username' => 'root',
            'password' => '',
            'charset' => 'utf8mb4',
            'collation' => 'utf8mb4_unicode_ci',
        ]]);

        // Step 1: Create missing bac_years
        $this->info('Step 1: Creating missing BAC years...');
        $this->createMissingYears($dryRun);

        // Step 2: Create bac_sessions for new years
        $this->info('Step 2: Creating BAC sessions...');
        $this->createMissingSessions($dryRun);

        // Step 3: Migrate BAC subjects
        $this->info('Step 3: Migrating BAC subjects...');
        $this->migrateBacSubjects($dryRun, $withFiles, $specificYear);

        // Summary
        $this->newLine();
        $this->info('=== Migration Summary ===');
        $this->table(
            ['Metric', 'Count'],
            [
                ['BAC Years Created', $this->createdYears],
                ['BAC Sessions Created', $this->createdSessions],
                ['BAC Subjects Created', $this->createdSubjects],
                ['Files Copied', $this->copiedFiles],
                ['Files Skipped', $this->skippedFiles],
                ['Errors', count($this->errors)],
            ]
        );

        if (count($this->errors) > 0) {
            $this->newLine();
            $this->error('Errors encountered:');
            foreach (array_slice($this->errors, 0, 20) as $error) {
                $this->line("  - {$error}");
            }
            if (count($this->errors) > 20) {
                $this->line("  ... and " . (count($this->errors) - 20) . " more errors");
            }
        }

        // Cleanup temp file
        if (File::exists(base_path('check_data.php'))) {
            File::delete(base_path('check_data.php'));
        }

        return Command::SUCCESS;
    }

    private function createMissingYears(bool $dryRun): void
    {
        // Get years from ta7sil (extract year number from title)
        $ta7silYears = DB::connection('ta7sil')
            ->table('doc_years')
            ->get()
            ->map(function ($year) {
                // Extract year number from "2008 مواضيع وحلول بكالوريا"
                preg_match('/(\d{4})/', $year->title, $matches);
                return $matches[1] ?? null;
            })
            ->filter()
            ->unique()
            ->values();

        // Get existing years in memo_app
        $existingYears = DB::table('bac_years')->pluck('year')->toArray();

        foreach ($ta7silYears as $year) {
            $yearInt = (int) $year;
            if (!in_array($yearInt, $existingYears)) {
                $this->line("  Creating year: {$yearInt}");
                if (!$dryRun) {
                    DB::table('bac_years')->insert([
                        'year' => $yearInt,
                        'is_active' => true,
                    ]);
                }
                $this->createdYears++;
            }
        }
        $this->info("  Created {$this->createdYears} new years");
    }

    private function createMissingSessions(bool $dryRun): void
    {
        // Get all bac_years
        $years = DB::table('bac_years')->get();

        // Get existing sessions
        $existingSessions = DB::table('bac_sessions')
            ->select('bac_year_id', 'session_type')
            ->get()
            ->groupBy('bac_year_id');

        foreach ($years as $year) {
            // Check if this year has a main session
            $hasMainSession = isset($existingSessions[$year->id]) &&
                $existingSessions[$year->id]->contains('session_type', 'main');

            if (!$hasMainSession) {
                $this->line("  Creating main session for year: {$year->year}");
                if (!$dryRun) {
                    DB::table('bac_sessions')->insert([
                        'name_ar' => 'الدورة العادية',
                        'slug' => "main-{$year->year}",
                        'bac_year_id' => $year->id,
                        'session_type' => 'main',
                        'exam_date' => "{$year->year}-06-01",
                    ]);
                }
                $this->createdSessions++;
            }
        }
        $this->info("  Created {$this->createdSessions} new sessions");
    }

    private function migrateBacSubjects(bool $dryRun, bool $withFiles, ?string $specificYear): void
    {
        // Build year mapping: ta7sil year_id => memo bac_year_id
        $ta7silYears = DB::connection('ta7sil')->table('doc_years')->get();
        $memoYears = DB::table('bac_years')->get()->keyBy('year');

        // For dry-run, we need to simulate the years that would be created
        $simulatedYearId = 1000; // Start with high ID to avoid conflicts

        $yearMapping = [];
        foreach ($ta7silYears as $ty) {
            preg_match('/(\d{4})/', $ty->title, $matches);
            if (isset($matches[1])) {
                $yearInt = (int)$matches[1];
                if (isset($memoYears[$yearInt])) {
                    $yearMapping[$ty->id] = [
                        'bac_year_id' => $memoYears[$yearInt]->id,
                        'year' => $yearInt,
                    ];
                } elseif ($dryRun) {
                    // In dry-run, simulate the year that would be created
                    $yearMapping[$ty->id] = [
                        'bac_year_id' => $simulatedYearId++,
                        'year' => $yearInt,
                    ];
                }
            }
        }

        // Get bac_sessions mapping: bac_year_id => session_id
        $sessions = DB::table('bac_sessions')
            ->where('session_type', 'main')
            ->get()
            ->keyBy('bac_year_id');

        // For dry-run, simulate sessions for years that would be created
        $simulatedSessionId = 1000;
        if ($dryRun) {
            foreach ($yearMapping as $tyId => $yearInfo) {
                if (!isset($sessions[$yearInfo['bac_year_id']])) {
                    $sessions[$yearInfo['bac_year_id']] = (object)[
                        'id' => $simulatedSessionId++,
                        'bac_year_id' => $yearInfo['bac_year_id'],
                        'session_type' => 'main',
                    ];
                }
            }
        }

        // Get specialities mapping
        $specialities = DB::connection('ta7sil')
            ->table('doc_specialities')
            ->get()
            ->keyBy('id');

        // Get subjects mapping
        $ta7silSubjects = DB::connection('ta7sil')
            ->table('doc_subjects')
            ->get()
            ->keyBy('id');

        // Get subject_specialities
        $subjectSpecialities = DB::connection('ta7sil')
            ->table('doc_subject_specialities')
            ->get()
            ->keyBy('id');

        // Get doc_subject_years with files
        $query = DB::connection('ta7sil')
            ->table('doc_subject_years')
            ->select('doc_subject_years.*');

        $subjectYears = $query->get();

        $this->output->progressStart($subjectYears->count());

        foreach ($subjectYears as $sy) {
            $this->output->progressAdvance();

            // Skip if year not in mapping
            if (!isset($yearMapping[$sy->doc_year_id])) {
                continue;
            }

            $yearInfo = $yearMapping[$sy->doc_year_id];

            // Skip if filtering by specific year
            if ($specificYear && $yearInfo['year'] != (int)$specificYear) {
                continue;
            }

            // Get session for this year
            if (!isset($sessions[$yearInfo['bac_year_id']])) {
                $this->errors[] = "No session found for year ID: {$yearInfo['bac_year_id']}";
                continue;
            }
            $sessionId = $sessions[$yearInfo['bac_year_id']]->id;

            // Get speciality (stream)
            $streamId = 1; // Default to علوم تجريبية
            if ($sy->doc_subject_specialitie_id && isset($subjectSpecialities[$sy->doc_subject_specialitie_id])) {
                $subjectSpec = $subjectSpecialities[$sy->doc_subject_specialitie_id];
                if (isset($specialities[$subjectSpec->doc_specialities_id])) {
                    $specTitle = $specialities[$subjectSpec->doc_specialities_id]->title;
                    $streamId = $this->streamMapping[$specTitle] ?? 1;
                }
            }

            // Get subject
            $subjectTitle = $sy->subject_title;
            $subjectId = $this->getSubjectId($subjectTitle, $streamId);

            if (!$subjectId) {
                $this->errors[] = "No subject mapping for: {$subjectTitle} (stream: {$streamId})";
                continue;
            }

            // Get files for this subject-year
            $files = DB::connection('ta7sil')
                ->table('doc_files')
                ->where('doc_subject_year_id', $sy->id)
                ->get();

            if ($files->isEmpty()) {
                continue;
            }

            // Process each file
            foreach ($files as $file) {
                $this->createBacSubject(
                    $dryRun,
                    $withFiles,
                    $yearInfo,
                    $sessionId,
                    $subjectId,
                    $streamId,
                    $subjectTitle,
                    $file
                );
            }
        }

        $this->output->progressFinish();
        $this->info("  Created {$this->createdSubjects} BAC subjects");
    }

    private function getSubjectId(string $subjectTitle, int $streamId): ?int
    {
        // Clean up subject title
        $subjectTitle = trim($subjectTitle);

        if (isset($this->subjectMapping[$subjectTitle])) {
            $mapping = $this->subjectMapping[$subjectTitle];
            return $mapping[$streamId] ?? reset($mapping); // Return first match if stream not found
        }

        return null;
    }

    private function createBacSubject(
        bool $dryRun,
        bool $withFiles,
        array $yearInfo,
        int $sessionId,
        int $subjectId,
        int $streamId,
        string $subjectTitle,
        object $file
    ): void {
        // Generate title
        $title = "بكالوريا {$yearInfo['year']} - {$subjectTitle}";
        if ($file->title) {
            $title .= " - {$file->title}";
        }

        // Check for duplicates
        $exists = DB::table('bac_subjects')
            ->where('bac_year_id', $yearInfo['bac_year_id'])
            ->where('subject_id', $subjectId)
            ->where('academic_stream_id', $streamId)
            ->where('title_ar', $title)
            ->exists();

        if ($exists) {
            $this->skippedFiles++;
            return;
        }

        // Process files
        $filePath = null;
        $correctionPath = null;

        if ($withFiles && $file->link) {
            $filePath = $this->copyFile($file->link, 'bac_subjects', $dryRun);
        } elseif ($file->link) {
            // Just reference the old path for now
            $filePath = $file->link;
        }

        if ($withFiles && $file->link_solution) {
            $correctionPath = $this->copyFile($file->link_solution, 'bac_corrections', $dryRun);
        } elseif ($file->link_solution) {
            $correctionPath = $file->link_solution;
        }

        // Skip if we couldn't get the main file path
        if (!$filePath) {
            $this->skippedFiles++;
            return;
        }

        if (!$dryRun) {
            DB::table('bac_subjects')->insert([
                'bac_year_id' => $yearInfo['bac_year_id'],
                'bac_session_id' => $sessionId,
                'subject_id' => $subjectId,
                'academic_stream_id' => $streamId,
                'title_ar' => $title,
                'file_path' => $filePath,
                'correction_file_path' => $correctionPath,
                'duration_minutes' => 180, // Default 3 hours
                'total_points' => 20,
                'difficulty_rating' => null,
                'average_score' => null,
                'views_count' => 0,
                'downloads_count' => 0,
                'simulations_count' => 0,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }

        $this->createdSubjects++;
    }

    private function copyFile(string $sourcePath, string $targetDir, bool $dryRun): ?string
    {
        // Clean source path
        $sourcePath = ltrim($sourcePath, '/');

        // Build full source path
        $ta7silBase = 'd:/memooo/ta7sil/public/';
        $fullSourcePath = $ta7silBase . $sourcePath;

        if (!File::exists($fullSourcePath)) {
            // Try alternative paths
            $alternatives = [
                $ta7silBase . 'uploads/doc/' . basename($sourcePath),
                $ta7silBase . $sourcePath,
            ];

            $found = false;
            foreach ($alternatives as $alt) {
                if (File::exists($alt)) {
                    $fullSourcePath = $alt;
                    $found = true;
                    break;
                }
            }

            if (!$found) {
                $this->errors[] = "File not found: {$sourcePath}";
                return null;
            }
        }

        // Generate new filename
        $extension = pathinfo($fullSourcePath, PATHINFO_EXTENSION) ?: 'pdf';
        $newFilename = time() . '_' . Str::random(10) . '.' . $extension;

        // Target path in storage
        $targetPath = storage_path("app/public/{$targetDir}/{$newFilename}");

        // Ensure target directory exists
        $targetDirPath = dirname($targetPath);
        if (!File::isDirectory($targetDirPath) && !$dryRun) {
            File::makeDirectory($targetDirPath, 0755, true);
        }

        // Copy file
        if (!$dryRun) {
            if (File::copy($fullSourcePath, $targetPath)) {
                $this->copiedFiles++;
                return "{$targetDir}/{$newFilename}";
            } else {
                $this->errors[] = "Failed to copy: {$sourcePath}";
                return null;
            }
        }

        $this->copiedFiles++;
        return "{$targetDir}/{$newFilename}";
    }
}
