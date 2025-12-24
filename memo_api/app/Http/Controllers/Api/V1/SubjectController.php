<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Subject;
use App\Models\AcademicStream;
use App\Models\AcademicYear;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SubjectController extends Controller
{
    /**
     * Get subjects filtered by academic year and stream.
     * Uses authenticated user's academic info if not provided in request.
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function index(Request $request): JsonResponse
    {
        // Get year_id and stream_id from request or authenticated user
        $yearId = $request->input('year_id');
        $streamId = $request->input('stream_id');

        // If not provided in request, try to get from authenticated user's academic profile
        if (!$yearId && !$streamId && $request->user()) {
            $user = $request->user();
            $academicProfile = $user->academicProfile;

            if ($academicProfile) {
                $yearId = $academicProfile->academic_year_id;
                $streamId = $academicProfile->academic_stream_id;
            }
        }

        // At least year_id should be provided
        if (!$yearId && !$streamId) {
            return response()->json([
                'success' => false,
                'message' => 'Please provide year_id or stream_id parameter, or complete your academic profile.',
            ], 400);
        }

        // Cast stream_id to int if provided
        $streamId = $streamId ? (int) $streamId : null;

        $query = Subject::where('is_active', true)
            ->withCount('contents')
            ->with(['academicYear.academicPhase', 'subjectStreams']);

        // Filter by stream using JSON contains for academic_stream_ids array
        if ($streamId) {
            // Use forStream scope which does whereJsonContains + orWhereNull
            $query->forStream($streamId);

            // Also filter by year if provided
            if ($yearId) {
                $query->where('academic_year_id', $yearId);
            }
        } else {
            // Filter by year only
            $query->where('academic_year_id', $yearId);
        }

        // Only show subjects that have content
        $query->has('contents');

        $subjects = $query->orderBy('order')->get();

        return response()->json([
            'success' => true,
            'data' => $subjects->map(function($subject) use ($streamId) {
                return $this->formatSubject($subject, false, $streamId);
            }),
        ]);
    }

    /**
     * Get subjects for a specific stream or year.
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function byAcademic(Request $request): JsonResponse
    {
        $request->validate([
            'stream_id' => 'nullable|exists:academic_streams,id',
            'year_id' => 'nullable|exists:academic_years,id',
        ]);

        $streamId = $request->has('stream_id') ? (int) $request->stream_id : null;

        $query = Subject::where('is_active', true)
            ->withCount('contents')
            ->with('subjectStreams');

        if ($streamId) {
            // Use forStream scope for JSON array filtering
            $query->forStream($streamId);
        }

        if ($request->has('year_id')) {
            $query->where('academic_year_id', $request->year_id);
        }

        // Only show subjects that have content
        $query->has('contents');

        $subjects = $query->orderBy('order')
            ->with(['academicYear.academicPhase'])
            ->get();

        return response()->json([
            'success' => true,
            'data' => $subjects->map(function($subject) use ($streamId) {
                return $this->formatSubject($subject, false, $streamId);
            }),
        ]);
    }

    /**
     * Get a specific subject with details.
     *
     * @param int $id
     * @return JsonResponse
     */
    public function show(int $id): JsonResponse
    {
        $subject = Subject::where('is_active', true)
            ->withCount('contents')
            ->with([
                'academicYear.academicPhase',
                'contentChapters' => function($q) {
                    $q->where('is_active', true)->orderBy('order');
                }
            ])
            ->findOrFail($id);

        $stats = [
            'total_contents' => $subject->contents()->where('is_published', true)->count(),
            'total_chapters' => $subject->contentChapters()->where('is_active', true)->count(),
        ];

        return response()->json([
            'success' => true,
            'data' => [
                'subject' => $this->formatSubject($subject, true),
                'chapters' => $subject->contentChapters->map(function($chapter) {
                    return [
                        'id' => $chapter->id,
                        'title_ar' => $chapter->title_ar,
                        'title_fr' => $chapter->title_fr,
                        'description_ar' => $chapter->description_ar,
                        'description_fr' => $chapter->description_fr,
                        'slug' => $chapter->slug,
                        'order' => $chapter->order,
                        'contents_count' => $chapter->contents()->where('is_published', true)->count(),
                    ];
                }),
                'stats' => $stats,
            ],
        ]);
    }

    /**
     * Format subject data for API response.
     *
     * @param Subject $subject
     * @param bool $detailed
     * @param int|null $streamId The stream to get coefficient for
     * @return array
     */
    private function formatSubject(Subject $subject, bool $detailed = false, ?int $streamId = null): array
    {
        // Get coefficient from pivot table if stream_id is provided
        $coefficient = $subject->coefficient;
        if ($streamId && $subject->relationLoaded('subjectStreams')) {
            $pivot = $subject->subjectStreams->firstWhere('academic_stream_id', $streamId);
            if ($pivot) {
                $coefficient = $pivot->coefficient;
            }
        }

        $data = [
            'id' => $subject->id,
            'name_ar' => $subject->name_ar,
            'name_fr' => $subject->name_fr,
            'description_ar' => $subject->description_ar,
            'description_fr' => $subject->description_fr,
            'slug' => $subject->slug,
            'coefficient' => $coefficient ? (float) $coefficient : null,
            'color' => $subject->color,
            'icon' => $subject->icon,
            'order' => $subject->order,
            'academic_year_id' => $subject->academic_year_id,
            'academic_stream_ids' => $subject->academic_stream_ids ?? [],
            'contents_count' => $subject->contents_count ?? 0,
        ];

        // Add academic year info
        if ($subject->academicYear) {
            $data['academic_year'] = [
                'id' => $subject->academicYear->id,
                'name_ar' => $subject->academicYear->name_ar,
                'name_fr' => $subject->academicYear->name_fr,
                'academic_phase_id' => $subject->academicYear->academic_phase_id,
            ];
        }

        // Add academic streams info (multiple streams)
        $academicStreams = $subject->academicStreams();
        if ($academicStreams->isNotEmpty()) {
            $data['academic_streams'] = $academicStreams->map(function($stream) {
                return [
                    'id' => $stream->id,
                    'name_ar' => $stream->name_ar,
                    'name_fr' => $stream->name_fr,
                ];
            })->toArray();
        }

        return $data;
    }
}
