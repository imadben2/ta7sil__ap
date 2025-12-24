<?php

namespace App\Services;

use App\Models\User;
use App\Models\PlannerSchedule;
use App\Models\PlannerStudySession;
use Barryvdh\DomPDF\Facade\Pdf;
use Carbon\Carbon;
use Illuminate\Support\Facades\Log;

class SchedulePdfService
{
    /**
     * Generate PDF for a planner schedule
     *
     * @param User $user
     * @param PlannerSchedule $schedule
     * @return array ['success' => bool, 'file_path' => string, 'url' => string, 'error' => string|null]
     */
    public function generateSchedulePdf(User $user, PlannerSchedule $schedule): array
    {
        try {
            // Load sessions with subjects
            $sessions = PlannerStudySession::where('schedule_id', $schedule->id)
                ->whereNull('deleted_at')
                ->with('subject')
                ->orderBy('scheduled_date')
                ->orderBy('scheduled_start_time')
                ->get();

            // Group sessions by date
            $sessionsByDate = $sessions->groupBy(function ($session) {
                return Carbon::parse($session->scheduled_date)->format('Y-m-d');
            });

            // Prepare data for PDF
            $data = [
                'user' => $user,
                'schedule' => $schedule,
                'sessionsByDate' => $sessionsByDate,
                'startDate' => Carbon::parse($schedule->start_date),
                'endDate' => Carbon::parse($schedule->end_date),
                'totalSessions' => $sessions->where('is_break', false)->count(),
                'totalBreaks' => $sessions->where('is_break', true)->count(),
                'totalStudyMinutes' => $sessions->where('is_break', false)->sum('duration_minutes'),
                'generatedAt' => now(),
            ];

            // Generate PDF with Arabic support
            $pdf = Pdf::loadView('pdf.schedule', $data);

            // Configure PDF options for RTL Arabic support
            $pdf->setOptions([
                'isHtml5ParserEnabled' => true,
                'isRemoteEnabled' => true,
                'defaultFont' => 'DejaVu Sans',
                'isFontSubsettingEnabled' => true,
                'isPhpEnabled' => true,
            ]);

            // Set paper size
            $pdf->setPaper('a4', 'portrait');

            // Create directory if it doesn't exist
            $directory = public_path('planner');
            if (!file_exists($directory)) {
                mkdir($directory, 0755, true);
            }

            // Generate filename: user_id_date_schedule_id_timestamp.pdf
            $date = now()->format('Y-m-d');
            $timestamp = now()->format('His');
            $fileName = "schedule_{$user->id}_{$date}_{$schedule->id}_{$timestamp}.pdf";
            $filePath = $directory . DIRECTORY_SEPARATOR . $fileName;

            // Save PDF
            $pdf->save($filePath);

            // Generate URL
            $url = url("planner/{$fileName}");

            Log::info("[SchedulePdfService] PDF generated successfully", [
                'user_id' => $user->id,
                'schedule_id' => $schedule->id,
                'file_path' => $filePath,
                'url' => $url,
            ]);

            return [
                'success' => true,
                'file_name' => $fileName,
                'file_path' => "planner/{$fileName}",
                'url' => $url,
                'error' => null,
            ];

        } catch (\Exception $e) {
            Log::error("[SchedulePdfService] Failed to generate PDF", [
                'user_id' => $user->id,
                'schedule_id' => $schedule->id,
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);

            return [
                'success' => false,
                'file_name' => null,
                'file_path' => null,
                'url' => null,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Delete old PDFs for a user (cleanup)
     *
     * @param int $userId
     * @param int $keepCount Number of recent PDFs to keep
     * @return int Number of deleted files
     */
    public function cleanupUserPdfs(int $userId, int $keepCount = 5): int
    {
        $directory = public_path('planner');
        if (!file_exists($directory)) {
            return 0;
        }

        // Find all PDFs for this user
        $pattern = "schedule_{$userId}_*.pdf";
        $files = glob($directory . DIRECTORY_SEPARATOR . $pattern);

        if (count($files) <= $keepCount) {
            return 0;
        }

        // Sort by modification time (newest first)
        usort($files, function ($a, $b) {
            return filemtime($b) - filemtime($a);
        });

        // Delete old files
        $deletedCount = 0;
        for ($i = $keepCount; $i < count($files); $i++) {
            if (unlink($files[$i])) {
                $deletedCount++;
            }
        }

        return $deletedCount;
    }
}
