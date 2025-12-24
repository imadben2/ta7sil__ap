<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\BacService;
use App\Services\BacSimulationService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;

class BacArchiveController extends Controller
{
    protected $bacService;
    protected $simulationService;

    public function __construct(BacService $bacService, BacSimulationService $simulationService)
    {
        $this->bacService = $bacService;
        $this->simulationService = $simulationService;
    }

    /**
     * Get all BAC years
     * GET /api/v1/bac/years
     */
    public function getBacYears()
    {
        try {
            $years = \App\Models\BacYear::where('is_active', true)
                ->orderBy('year', 'desc')
                ->get()
                ->map(function ($year) {
                    return [
                        'id' => $year->id,
                        'year' => $year->year,
                        'slug' => (string)$year->year,
                        'name_ar' => 'باكالوريا ' . $year->year,
                        'is_active' => $year->is_active,
                    ];
                });

            return response()->json([
                'success' => true,
                'data' => $years
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'فشل في جلب السنوات',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get subjects for a specific BAC year (directly, without session)
     * GET /api/v1/bac/years/{yearSlug}/subjects
     *
     * Filters by user's academic stream if authenticated
     * Query params:
     * - stream_id: filter by specific stream (optional)
     */
    public function getSubjectsByYear(Request $request, $yearSlug)
    {
        try {
            // Find year by slug (year number)
            $year = \App\Models\BacYear::where('year', $yearSlug)
                ->where('is_active', true)
                ->first();

            if (!$year) {
                return response()->json([
                    'success' => false,
                    'message' => 'السنة غير موجودة'
                ], 404);
            }

            // Build query
            $query = \App\Models\BacSubject::where('bac_year_id', $year->id)
                ->with(['bacYear', 'bacSession', 'subject', 'academicStream']);

            // Filter by stream_id query param first (explicit filter takes priority)
            if ($request->has('stream_id')) {
                $query->where('academic_stream_id', $request->query('stream_id'));
            } else {
                // Otherwise, filter by user's academic stream if authenticated
                $user = $request->user();
                if ($user) {
                    $academicProfile = $user->academicProfile;
                    if ($academicProfile && $academicProfile->academic_stream_id) {
                        $query->where('academic_stream_id', $academicProfile->academic_stream_id);
                    }
                }
            }

            $subjects = $query->get()->map(function ($bacSubject) {
                    return [
                        'id' => $bacSubject->id,
                        'title_ar' => $bacSubject->title_ar,
                        'name_ar' => $bacSubject->subject->name_ar,
                        'slug' => $bacSubject->id . '-' . \Str::slug($bacSubject->subject->name_ar),
                        'coefficient' => $bacSubject->coefficient ?? 1,
                        'color' => $bacSubject->subject->color ?? '#6366F1',
                        'icon' => $bacSubject->subject->icon ?? 'book',
                        'subject' => [
                            'id' => $bacSubject->subject->id,
                            'name_ar' => $bacSubject->subject->name_ar,
                        ],
                        'session' => [
                            'id' => $bacSubject->bacSession->id,
                            'name_ar' => $bacSubject->bacSession->name_ar,
                            'slug' => $bacSubject->bacSession->slug,
                        ],
                        'stream' => [
                            'id' => $bacSubject->academicStream->id,
                            'name_ar' => $bacSubject->academicStream->name_ar,
                        ],
                        'year' => $bacSubject->bacYear->year,
                        'duration_minutes' => $bacSubject->duration_minutes,
                        'views_count' => $bacSubject->views_count ?? 0,
                        'downloads_count' => $bacSubject->downloads_count ?? 0,
                        'has_correction' => $bacSubject->correction_file_path !== null,
                        'file_url' => $bacSubject->getFileUrl(),
                        'correction_url' => $bacSubject->getCorrectionUrl(),
                        'download_url' => $bacSubject->getSignedDownloadUrl(),
                        'correction_download_url' => $bacSubject->getSignedCorrectionUrl(),
                    ];
                });

            return response()->json([
                'success' => true,
                'data' => $subjects
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'فشل في جلب المواد',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get sessions for a specific BAC year
     * GET /api/v1/bac/years/{yearSlug}/sessions
     */
    public function getBacSessions($yearSlug)
    {
        try {
            // Find year by slug (year number)
            $year = \App\Models\BacYear::where('year', $yearSlug)
                ->where('is_active', true)
                ->first();

            if (!$year) {
                return response()->json([
                    'success' => false,
                    'message' => 'السنة غير موجودة'
                ], 404);
            }

            $sessions = \App\Models\BacSession::all()
                ->map(function ($session) use ($year) {
                    return [
                        'id' => $session->id,
                        'name_ar' => $session->name_ar,
                        'slug' => $session->slug,
                        'year_id' => $year->id,
                    ];
                });

            return response()->json([
                'success' => true,
                'data' => $sessions
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'فشل في جلب الدورات',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get subjects for a specific session
     * GET /api/v1/bac/sessions/{sessionSlug}/subjects
     */
    public function getBacSubjects($sessionSlug)
    {
        try {
            $session = \App\Models\BacSession::where('slug', $sessionSlug)->first();

            if (!$session) {
                return response()->json([
                    'success' => false,
                    'message' => 'الدورة غير موجودة'
                ], 404);
            }

            $subjects = \App\Models\BacSubject::where('bac_session_id', $session->id)
                ->with(['bacYear', 'subject', 'academicStream'])
                ->get()
                ->map(function ($bacSubject) {
                    return [
                        'id' => $bacSubject->id,
                        'title_ar' => $bacSubject->title_ar,
                        'slug' => $bacSubject->id . '-' . \Str::slug($bacSubject->subject->name_ar),
                        'subject' => [
                            'id' => $bacSubject->subject->id,
                            'name_ar' => $bacSubject->subject->name_ar,
                        ],
                        'stream' => [
                            'id' => $bacSubject->academicStream->id,
                            'name_ar' => $bacSubject->academicStream->name_ar,
                        ],
                        'year' => $bacSubject->bacYear->year,
                        'duration_minutes' => $bacSubject->duration_minutes,
                        'views_count' => $bacSubject->views_count,
                        'downloads_count' => $bacSubject->downloads_count,
                    ];
                });

            return response()->json([
                'success' => true,
                'data' => $subjects
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'فشل في جلب المواد',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get chapters for a specific BAC subject
     * GET /api/v1/bac/subjects/{subjectSlug}/chapters
     */
    public function getBacChapters($subjectSlug)
    {
        try {
            // Extract subject ID from slug (format: {id}-{slug})
            $subjectId = (int) explode('-', $subjectSlug)[0];

            $bacSubject = \App\Models\BacSubject::with('chapters')->find($subjectId);

            if (!$bacSubject) {
                return response()->json([
                    'success' => false,
                    'message' => 'المادة غير موجودة'
                ], 404);
            }

            $chapters = $bacSubject->chapters->map(function ($chapter) {
                return [
                    'id' => $chapter->id,
                    'title_ar' => $chapter->title_ar,
                    'order' => $chapter->order,
                ];
            });

            return response()->json([
                'success' => true,
                'data' => $chapters
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'فشل في جلب الفصول',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get BAC exams for a specific content library subject and year
     * GET /api/v1/bac/exams-by-subject
     *
     * Query params:
     * - subject_id: content library subject ID (required)
     * - year_slug: BAC year (e.g., "2024") (required)
     * - stream_id: filter by academic stream (optional)
     */
    public function getExamsBySubject(Request $request)
    {
        try {
            $subjectId = $request->query('subject_id');
            $yearSlug = $request->query('year_slug');
            $streamId = $request->query('stream_id');

            if (!$subjectId || !$yearSlug) {
                return response()->json([
                    'success' => false,
                    'message' => 'معرف المادة والسنة مطلوبان'
                ], 400);
            }

            // Find year by slug (year number)
            $year = \App\Models\BacYear::where('year', $yearSlug)
                ->where('is_active', true)
                ->first();

            if (!$year) {
                return response()->json([
                    'success' => false,
                    'message' => 'السنة غير موجودة'
                ], 404);
            }

            // Build query - filter by content library subject_id and bac_year_id
            $query = \App\Models\BacSubject::where('subject_id', $subjectId)
                ->where('bac_year_id', $year->id)
                ->with(['bacYear', 'bacSession', 'subject', 'academicStream']);

            // Only filter by stream_id if explicitly provided
            // For BAC archives, show all exams for a subject/year regardless of user's stream
            // This allows students to view historical exams from all streams
            if ($streamId) {
                $query->where('academic_stream_id', $streamId);
            }

            $exams = $query->get()->map(function ($bacSubject) {
                return [
                    'id' => $bacSubject->id,
                    'title_ar' => $bacSubject->title_ar,
                    'name_ar' => $bacSubject->subject->name_ar,
                    'slug' => $bacSubject->id . '-' . \Str::slug($bacSubject->subject->name_ar),
                    'coefficient' => $bacSubject->coefficient ?? 1,
                    'color' => $bacSubject->subject->color ?? '#6366F1',
                    'icon' => $bacSubject->subject->icon ?? 'book',
                    'subject' => [
                        'id' => $bacSubject->subject->id,
                        'name_ar' => $bacSubject->subject->name_ar,
                    ],
                    'session' => [
                        'id' => $bacSubject->bacSession->id,
                        'name_ar' => $bacSubject->bacSession->name_ar,
                        'slug' => $bacSubject->bacSession->slug,
                    ],
                    'stream' => [
                        'id' => $bacSubject->academicStream->id,
                        'name_ar' => $bacSubject->academicStream->name_ar,
                    ],
                    'year' => $bacSubject->bacYear->year,
                    'duration_minutes' => $bacSubject->duration_minutes,
                    'views_count' => $bacSubject->views_count ?? 0,
                    'downloads_count' => $bacSubject->downloads_count ?? 0,
                    'has_correction' => $bacSubject->correction_file_path !== null,
                    'file_url' => $bacSubject->getFileUrl(),
                    'correction_url' => $bacSubject->getCorrectionUrl(),
                    'download_url' => $bacSubject->getSignedDownloadUrl(),
                    'correction_download_url' => $bacSubject->getSignedCorrectionUrl(),
                ];
            });

            return response()->json([
                'success' => true,
                'data' => $exams
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'فشل في جلب الامتحانات',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get BAC filters (years, sessions, subjects, streams)
     * GET /api/bac/filters
     */
    public function filters(Request $request)
    {
        try {
            $filters = [
                'years' => $this->bacService->getBacYears(),
                'sessions' => $this->bacService->getBacSessions(),
            ];

            return response()->json([
                'success' => true,
                'data' => $filters
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'فشل في جلب الفلاتر',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Browse BAC archives with filters
     * GET /api/bac/browse
     */
    public function browse(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'year_id' => 'nullable|exists:bac_years,id',
                'session_id' => 'nullable|exists:bac_sessions,id',
                'subject_id' => 'nullable|exists:subjects,id',
                'stream_id' => 'nullable|exists:academic_streams,id',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'بيانات غير صالحة',
                    'errors' => $validator->errors()
                ], 422);
            }

            $bacSubjects = $this->bacService->getBacSubjects($request->only(['year_id', 'session_id', 'subject_id', 'stream_id']));

            return response()->json([
                'success' => true,
                'data' => $bacSubjects->map(function ($subject) {
                    return [
                        'id' => $subject->id,
                        'title_ar' => $subject->title_ar,
                        'year' => $subject->bacYear->year,
                        'session' => $subject->bacSession->name_ar,
                        'subject' => $subject->subject->name_ar,
                        'stream' => $subject->academicStream->name_ar,
                        'duration_minutes' => $subject->duration_minutes,
                        'views_count' => $subject->views_count,
                        'downloads_count' => $subject->downloads_count,
                        'has_correction' => $subject->correction_file_path !== null,
                        'chapters_count' => $subject->chapters->count(),
                    ];
                })
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'فشل في جلب الأرشيف',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get BAC subject details
     * GET /api/bac/{id}
     */
    public function show($id)
    {
        try {
            $bacSubject = $this->bacService->getBacSubjectById($id);

            // Increment views
            $bacSubject->incrementViews();

            return response()->json([
                'success' => true,
                'data' => [
                    'id' => $bacSubject->id,
                    'title_ar' => $bacSubject->title_ar,
                    'year' => $bacSubject->bacYear->year,
                    'session' => $bacSubject->bacSession->name_ar,
                    'subject' => [
                        'id' => $bacSubject->subject->id,
                        'name_ar' => $bacSubject->subject->name_ar,
                    ],
                    'stream' => [
                        'id' => $bacSubject->academicStream->id,
                        'name_ar' => $bacSubject->academicStream->name_ar,
                    ],
                    'duration_minutes' => $bacSubject->duration_minutes,
                    'total_points' => $bacSubject->total_points ?? 20,
                    'difficulty_rating' => $bacSubject->difficulty_rating,
                    'average_score' => $bacSubject->average_score,
                    'views_count' => $bacSubject->views_count,
                    'downloads_count' => $bacSubject->downloads_count,
                    'simulations_count' => $bacSubject->simulations_count,
                    'download_url' => $bacSubject->getSignedDownloadUrl(),
                    'correction_url' => $bacSubject->getSignedCorrectionUrl(),
                    'has_correction' => $bacSubject->correction_file_path !== null,
                    'chapters' => $bacSubject->chapters->map(function ($chapter) {
                        return [
                            'id' => $chapter->id,
                            'title_ar' => $chapter->title_ar,
                            'order' => $chapter->order,
                        ];
                    }),
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'فشل في جلب تفاصيل الموضوع',
                'error' => $e->getMessage()
            ], 404);
        }
    }

    /**
     * Download BAC file (subject or correction)
     * GET /api/bac/{id}/download
     */
    public function download(Request $request, $id)
    {
        try {
            // Validate signed route
            if (!$request->hasValidSignature()) {
                return response()->json([
                    'success' => false,
                    'message' => 'رابط التنزيل غير صالح أو منتهي الصلاحية'
                ], 403);
            }

            $type = $request->query('type', 'subject');
            $bacSubject = $this->bacService->getBacSubjectById($id);

            $filePath = $this->bacService->getDownloadPath($bacSubject, $type);

            if (!$filePath || !Storage::disk('public')->exists($filePath)) {
                return response()->json([
                    'success' => false,
                    'message' => 'الملف غير موجود'
                ], 404);
            }

            // Increment downloads count
            $bacSubject->incrementDownloads();

            return Storage::disk('public')->download($filePath);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'فشل في تنزيل الملف',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Stream BAC file directly (no signature required for public files)
     * GET /api/bac/{id}/stream
     *
     * This endpoint uses chunked output with small buffers to work around
     * PHP built-in server limitations with large file downloads.
     */
    public function streamFile(Request $request, $id)
    {
        try {
            $type = $request->query('type', 'subject');
            $bacSubject = \App\Models\BacSubject::findOrFail($id);

            $filePath = $type === 'correction'
                ? $bacSubject->correction_file_path
                : $bacSubject->file_path;

            if (!$filePath || !Storage::disk('public')->exists($filePath)) {
                return response()->json([
                    'success' => false,
                    'message' => 'الملف غير موجود'
                ], 404);
            }

            $fullPath = Storage::disk('public')->path($filePath);
            $fileSize = filesize($fullPath);

            // Increment downloads count
            $bacSubject->incrementDownloads();

            // Use streaming response with small chunks to avoid PHP dev server issues
            return response()->stream(function () use ($fullPath) {
                // Disable output buffering completely
                while (ob_get_level() > 0) {
                    ob_end_flush();
                }

                // Set implicit flush
                if (function_exists('apache_setenv')) {
                    apache_setenv('no-gzip', '1');
                }

                ini_set('zlib.output_compression', 'Off');

                $handle = fopen($fullPath, 'rb');
                if ($handle === false) {
                    return;
                }

                // Use very small chunks (8KB) to prevent connection issues
                $chunkSize = 8192;

                while (!feof($handle)) {
                    $chunk = fread($handle, $chunkSize);
                    if ($chunk === false) {
                        break;
                    }
                    echo $chunk;

                    // Flush after each chunk
                    if (function_exists('ob_flush')) {
                        @ob_flush();
                    }
                    flush();

                    // Small delay to prevent buffer overflow
                    usleep(1000); // 1ms delay
                }

                fclose($handle);
            }, 200, [
                'Content-Type' => 'application/pdf',
                'Content-Length' => $fileSize,
                'Content-Disposition' => 'inline; filename="document.pdf"',
                'Cache-Control' => 'public, max-age=86400',
                'Accept-Ranges' => 'bytes',
                'Connection' => 'keep-alive',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'فشل في عرض الملف',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Start BAC simulation
     * POST /api/bac/{id}/simulation/start
     */
    public function startSimulation(Request $request, $id)
    {
        try {
            $user = $request->user();

            $result = $this->simulationService->startSimulation($user, $id);

            return response()->json([
                'success' => true,
                'message' => 'تم بدء المحاكاة بنجاح',
                'data' => [
                    'simulation_id' => $result['simulation']->id,
                    'bac_subject' => [
                        'id' => $result['bac_subject']->id,
                        'title_ar' => $result['bac_subject']->title_ar,
                        'duration_minutes' => $result['duration_minutes'],
                    ],
                    'chapters' => $result['chapters']->map(function ($chapter) {
                        return [
                            'id' => $chapter->id,
                            'title_ar' => $chapter->title_ar,
                            'order' => $chapter->order,
                        ];
                    }),
                    'started_at' => $result['simulation']->started_at,
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 400);
        }
    }

    /**
     * Get active simulation
     * GET /api/bac/simulation/active
     */
    public function getActiveSimulation(Request $request)
    {
        try {
            $user = $request->user();

            $result = $this->simulationService->getActiveSimulation($user);

            if (!$result) {
                return response()->json([
                    'success' => true,
                    'data' => null
                ]);
            }

            return response()->json([
                'success' => true,
                'data' => [
                    'simulation_id' => $result['simulation']->id,
                    'bac_subject' => [
                        'id' => $result['bac_subject']->id,
                        'title_ar' => $result['bac_subject']->title_ar,
                    ],
                    'started_at' => $result['simulation']->started_at,
                    'remaining_seconds' => $result['remaining_seconds'],
                    'chapters' => $result['chapters']->map(function ($chapter) {
                        return [
                            'id' => $chapter->id,
                            'title_ar' => $chapter->title_ar,
                            'order' => $chapter->order,
                        ];
                    }),
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'فشل في جلب المحاكاة النشطة',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Submit simulation results
     * POST /api/bac/simulation/{id}/submit
     */
    public function submitSimulation(Request $request, $id)
    {
        try {
            $validator = Validator::make($request->all(), [
                'overall_score' => 'required|numeric|min:0|max:20',
                'chapter_scores' => 'nullable|array',
                'chapter_scores.*' => 'numeric|min:0|max:100',
                'difficulty_felt' => 'nullable|in:easy,medium,hard',
                'user_notes' => 'nullable|string|max:1000',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'بيانات غير صالحة',
                    'errors' => $validator->errors()
                ], 422);
            }

            $user = $request->user();

            $result = $this->simulationService->submitSimulation(
                $user,
                $id,
                $request->only(['overall_score', 'chapter_scores', 'difficulty_felt', 'user_notes'])
            );

            return response()->json([
                'success' => true,
                'message' => 'تم إرسال نتائج المحاكاة بنجاح',
                'data' => [
                    'simulation_id' => $result['simulation']->id,
                    'score' => $result['score'],
                    'percentage' => $result['percentage'] ?? 0,
                    'grade' => $result['grade'] ?? null,
                    'time_spent_seconds' => $result['simulation']->duration_seconds,
                    'performance' => [
                        'total_simulations' => $result['performance']->total_simulations,
                        'average_score' => $result['performance']->average_score,
                        'best_score' => $result['performance']->best_score,
                    ],
                    'weak_chapters' => $result['weak_chapters']->map(function ($item) {
                        return [
                            'chapter' => $item['chapter']->title_ar ?? $item['chapter'],
                            'score' => $item['score']
                        ];
                    }),
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 400);
        }
    }

    /**
     * Abandon simulation
     * POST /api/bac/simulation/{id}/abandon
     */
    public function abandonSimulation(Request $request, $id)
    {
        try {
            $user = $request->user();

            $this->simulationService->abandonSimulation($user, $id);

            return response()->json([
                'success' => true,
                'message' => 'تم إلغاء المحاكاة'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'فشل في إلغاء المحاكاة',
                'error' => $e->getMessage()
            ], 400);
        }
    }

    /**
     * Get user's simulation history
     * GET /api/bac/simulations/history
     */
    public function simulationHistory(Request $request)
    {
        try {
            $user = $request->user();

            $simulations = $this->simulationService->getUserSimulations($user, $request->only(['status', 'subject_id']));

            return response()->json([
                'success' => true,
                'data' => $simulations
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'فشل في جلب سجل المحاكاة',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get user's performance for a subject
     * GET /api/bac/performance/{subjectId}
     */
    public function getPerformance(Request $request, $subjectId)
    {
        try {
            $user = $request->user();

            $performance = $this->simulationService->getUserPerformance($user, $subjectId);

            if (!$performance) {
                return response()->json([
                    'success' => true,
                    'data' => null
                ]);
            }

            return response()->json([
                'success' => true,
                'data' => $performance
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'فشل في جلب الأداء',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get all user's performances
     * GET /api/bac/performance
     */
    public function getAllPerformances(Request $request)
    {
        try {
            $user = $request->user();

            $performances = $this->simulationService->getAllUserPerformances($user);

            return response()->json([
                'success' => true,
                'data' => $performances
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'فشل في جلب الأداء',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get recommended BAC subjects for the user
     * GET /api/v1/bac/recommendations
     *
     * Based on user's performance, recommends subjects to practice.
     * Algorithm prioritizes:
     * - Weak subjects (average score < 60%)
     * - Subjects not attempted recently (2+ weeks)
     * - Lower difficulty for weak areas
     */
    public function getRecommendations(Request $request)
    {
        try {
            $user = $request->user();
            $limit = $request->query('limit', 5);

            $recommendations = $this->bacService->getRecommendedSubjects($user, min($limit, 10));

            return response()->json([
                'success' => true,
                'data' => $recommendations
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'فشل في جلب التوصيات',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}
