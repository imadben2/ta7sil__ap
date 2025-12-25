<?php

namespace App\Http\Controllers;

use App\Models\AcademicPhase;
use App\Models\AcademicYear;
use App\Models\AcademicStream;
use App\Models\Subject;
use Illuminate\Http\Request;

class AcademicController extends Controller
{
    /**
     * Get all academic phases with years and streams.
     *
     * GET /api/academic/phases
     */
    public function getPhases()
    {
        $phases = AcademicPhase::where('is_active', true)
            ->with(['academicYears', 'academicStreams'])
            ->orderBy('order')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $phases,
        ]);
    }

    /**
     * Get all academic years with streams.
     *
     * GET /api/academic/years
     */
    public function getYears(Request $request)
    {
        $query = AcademicYear::with(['academicPhase', 'academicStreams', 'subjects']);

        // Filter by phase if provided
        if ($request->has('phase_id')) {
            $query->where('academic_phase_id', $request->phase_id);
        }

        $years = $query->orderBy('order')->get();

        return response()->json([
            'success' => true,
            'data' => $years,
        ]);
    }

    /**
     * Get all academic streams.
     *
     * GET /api/academic/streams
     */
    public function getStreams(Request $request)
    {
        $query = AcademicStream::with(['academicYear', 'subjects']);

        // Filter by year if provided
        if ($request->has('year_id')) {
            $query->where('academic_year_id', $request->year_id);
        }

        // Only active streams
        if ($request->boolean('active_only', false)) {
            $query->where('is_active', true);
        }

        $streams = $query->orderBy('order')->get();

        return response()->json([
            'success' => true,
            'data' => $streams,
        ]);
    }

    /**
     * Get all subjects with optional filtering.
     *
     * GET /api/academic/subjects
     */
    public function getSubjects(Request $request)
    {
        $streamId = null;

        $query = Subject::with(['academicYear', 'subjectStreams'])
            ->withCount('contents');

        // If user is authenticated and no filters provided, use their academic profile
        if (auth()->check() && !$request->has('stream_id') && !$request->has('year_id')) {
            $user = auth()->user()->load('academicProfile');

            if ($user->academicProfile) {
                // Filter by user's stream if they have one (using JSON array)
                if ($user->academicProfile->academic_stream_id) {
                    $streamId = (int) $user->academicProfile->academic_stream_id;
                    $query->forStream($streamId);
                }
                // Otherwise filter by user's year
                elseif ($user->academicProfile->academic_year_id) {
                    $query->where('academic_year_id', $user->academicProfile->academic_year_id);
                }
            } else {
                // User has no academic profile
                return response()->json([
                    'success' => false,
                    'message' => 'Please provide year_id or stream_id parameter, or complete your academic profile.',
                ], 400);
            }
        } else {
            // Filter by stream (manual override) - uses forStream scope for JSON array
            if ($request->has('stream_id')) {
                $streamId = (int) $request->stream_id;
                $query->forStream($streamId);
            }

            // Filter by year (manual override)
            if ($request->has('year_id')) {
                $query->where('academic_year_id', $request->year_id);
            }
        }

        // Only active subjects
        if ($request->boolean('active_only', true)) {
            $query->where('is_active', true);
        }

        // Only show subjects that have content (default: true)
        if ($request->boolean('with_content_only', true)) {
            $query->has('contents');
        }

        $subjects = $query->orderBy('order')->get();

        // Transform subjects to include stream-specific coefficient
        $subjectsData = $subjects->map(function ($subject) use ($streamId) {
            $data = $subject->toArray();

            // Get coefficient for the specific stream from pivot table
            if ($streamId) {
                $pivot = $subject->subjectStreams
                    ->firstWhere('academic_stream_id', $streamId);
                if ($pivot) {
                    $data['coefficient'] = $pivot->coefficient;
                }
            }

            // Remove subjectStreams from response (internal use only)
            unset($data['subject_streams']);

            return $data;
        });

        return response()->json([
            'success' => true,
            'data' => $subjectsData,
        ]);
    }

    /**
     * Get a single subject with details.
     *
     * GET /api/academic/subjects/{id}
     */
    public function getSubject($id, Request $request)
    {
        $subject = Subject::with([
            'academicYear',
        ])->findOrFail($id);

        // Get stream ID from request or user's academic profile
        $streamId = null;
        if ($request->has('stream_id')) {
            $streamId = (int) $request->stream_id;
        } elseif (auth()->check()) {
            $user = auth()->user();
            $user->loadMissing('academicProfile');
            $streamId = $user->academicProfile?->academic_stream_id;
        }

        // Load chapters filtered by stream
        $chaptersQuery = $subject->contentChapters()->where('is_active', true);
        if ($streamId) {
            $chaptersQuery->forStream($streamId);
        }
        $subject->setRelation('contentChapters', $chaptersQuery->orderBy('order')->get());

        // Get academic streams for this subject (manual since it's not a proper relationship)
        $academicStreams = $subject->academicStreams();

        return response()->json([
            'success' => true,
            'data' => array_merge($subject->toArray(), [
                'academic_streams' => $academicStreams,
            ]),
        ]);
    }

    /**
     * Get BAC streams (3rd year secondary only).
     *
     * GET /api/academic/bac-streams
     */
    public function getBacStreams()
    {
        $bacYear = AcademicYear::where('level_number', 3)
            ->whereHas('academicPhase', function ($query) {
                $query->where('slug', 'secondary');
            })
            ->first();

        if (!$bacYear) {
            return response()->json([
                'success' => false,
                'message' => 'BAC year not found',
            ], 404);
        }

        $streams = AcademicStream::with('subjects')
            ->where('academic_year_id', $bacYear->id)
            ->where('is_active', true)
            ->orderBy('order')
            ->get();

        return response()->json([
            'success' => true,
            'data' => [
                'bac_year' => $bacYear,
                'streams' => $streams,
            ],
        ]);
    }
}
