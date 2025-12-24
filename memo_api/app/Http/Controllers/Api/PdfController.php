<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;

class PdfController extends Controller
{
    /**
     * Upload PDF to public/planner folder
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function uploadPlannerPdf(Request $request)
    {
        // Validation
        $validator = Validator::make($request->all(), [
            'pdf_file' => 'required|file|mimes:pdf|max:10240', // Max 10MB
            'file_name' => 'nullable|string|max:255',
            'type' => 'nullable|string|in:schedule,history',
            'user_id' => 'nullable|integer',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            $file = $request->file('pdf_file');

            // Get file size before moving (getSize() doesn't work after move)
            $fileSize = $file->getSize();

            // Generate file name
            $fileName = $request->input('file_name');
            if (!$fileName) {
                $type = $request->input('type', 'schedule');
                $date = date('d-m-Y');
                $fileName = "MEMO_{$type}_{$date}.pdf";
            }

            // Ensure .pdf extension
            if (!Str::endsWith(strtolower($fileName), '.pdf')) {
                $fileName .= '.pdf';
            }

            // Sanitize filename
            $fileName = $this->sanitizeFileName($fileName);

            // Define storage path: public/planner/
            $storagePath = 'planner';

            // Create directory if it doesn't exist
            $fullPath = public_path($storagePath);
            if (!file_exists($fullPath)) {
                mkdir($fullPath, 0755, true);
            }

            // Save file to public/planner/
            $file->move($fullPath, $fileName);

            // Generate public URL
            $url = url("planner/{$fileName}");

            // Optional: Save to database (for tracking)
            $this->savePdfRecord($request, $fileName, $url);

            return response()->json([
                'success' => true,
                'message' => 'PDF uploaded successfully',
                'data' => [
                    'file_name' => $fileName,
                    'url' => $url,
                    'path' => "planner/{$fileName}",
                    'size' => $fileSize,
                ]
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to upload PDF',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get list of PDFs in planner folder
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function listPlannerPdfs(Request $request)
    {
        try {
            $plannerPath = public_path('planner');

            if (!file_exists($plannerPath)) {
                return response()->json([
                    'success' => true,
                    'message' => 'Planner folder is empty',
                    'data' => []
                ]);
            }

            $files = [];
            $items = scandir($plannerPath);

            foreach ($items as $item) {
                if ($item === '.' || $item === '..') {
                    continue;
                }

                $filePath = $plannerPath . DIRECTORY_SEPARATOR . $item;

                if (is_file($filePath) && strtolower(pathinfo($item, PATHINFO_EXTENSION)) === 'pdf') {
                    $files[] = [
                        'name' => $item,
                        'url' => url("planner/{$item}"),
                        'size' => filesize($filePath),
                        'modified' => date('Y-m-d H:i:s', filemtime($filePath)),
                    ];
                }
            }

            // Sort by modified date (newest first)
            usort($files, function($a, $b) {
                return strtotime($b['modified']) - strtotime($a['modified']);
            });

            return response()->json([
                'success' => true,
                'message' => 'PDFs retrieved successfully',
                'data' => $files,
                'count' => count($files)
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to list PDFs',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Delete a PDF from planner folder
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function deletePlannerPdf(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'file_name' => 'required|string|max:255',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            $fileName = basename($request->input('file_name')); // Security: prevent path traversal
            $filePath = public_path("planner/{$fileName}");

            if (!file_exists($filePath)) {
                return response()->json([
                    'success' => false,
                    'message' => 'PDF file not found'
                ], 404);
            }

            // Delete file
            unlink($filePath);

            return response()->json([
                'success' => true,
                'message' => 'PDF deleted successfully'
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to delete PDF',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Download a PDF from planner folder
     *
     * @param string $fileName
     * @return \Symfony\Component\HttpFoundation\BinaryFileResponse
     */
    public function downloadPlannerPdf($fileName)
    {
        $fileName = basename($fileName); // Security: prevent path traversal
        $filePath = public_path("planner/{$fileName}");

        if (!file_exists($filePath)) {
            return response()->json([
                'success' => false,
                'message' => 'PDF file not found'
            ], 404);
        }

        return response()->download($filePath);
    }

    /**
     * Clean old PDFs (older than specified days)
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function cleanOldPdfs(Request $request)
    {
        $days = $request->input('days', 30); // Default: 30 days

        try {
            $plannerPath = public_path('planner');

            if (!file_exists($plannerPath)) {
                return response()->json([
                    'success' => true,
                    'message' => 'Planner folder does not exist',
                    'deleted' => 0
                ]);
            }

            $deletedCount = 0;
            $items = scandir($plannerPath);
            $cutoffTime = time() - ($days * 24 * 60 * 60);

            foreach ($items as $item) {
                if ($item === '.' || $item === '..') {
                    continue;
                }

                $filePath = $plannerPath . DIRECTORY_SEPARATOR . $item;

                if (is_file($filePath) && filemtime($filePath) < $cutoffTime) {
                    unlink($filePath);
                    $deletedCount++;
                }
            }

            return response()->json([
                'success' => true,
                'message' => "Deleted {$deletedCount} old PDF(s)",
                'deleted' => $deletedCount
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to clean old PDFs',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Sanitize file name to prevent security issues
     *
     * @param string $fileName
     * @return string
     */
    private function sanitizeFileName($fileName)
    {
        // Remove any path components
        $fileName = basename($fileName);

        // Remove any special characters except dash, underscore, dot
        $fileName = preg_replace('/[^a-zA-Z0-9._-]/', '_', $fileName);

        // Remove multiple consecutive underscores
        $fileName = preg_replace('/_+/', '_', $fileName);

        return $fileName;
    }

    /**
     * Save PDF record to database (optional - for tracking)
     *
     * @param Request $request
     * @param string $fileName
     * @param string $url
     * @return void
     */
    private function savePdfRecord(Request $request, $fileName, $url)
    {
        // Optional: Create a 'pdfs' table to track uploaded PDFs
        // Uncomment if you want to track PDFs in database

        /*
        \DB::table('planner_pdfs')->insert([
            'user_id' => $request->input('user_id'),
            'file_name' => $fileName,
            'url' => $url,
            'type' => $request->input('type', 'schedule'),
            'created_at' => now(),
            'updated_at' => now(),
        ]);
        */
    }
}
