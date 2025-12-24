<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\AcademicPhase;
use App\Models\AcademicYear;
use App\Models\AcademicStream;
use Illuminate\Http\JsonResponse;

class AcademicController extends Controller
{
    /**
     * Get complete academic structure (phases, years, streams).
     *
     * @return JsonResponse
     */
    public function structure(): JsonResponse
    {
        $phases = AcademicPhase::where('is_active', true)
            ->orderBy('order')
            ->with(['academicYears' => function($query) {
                $query->where('is_active', true)
                    ->orderBy('order')
                    ->with(['academicStreams' => function($q) {
                        $q->where('is_active', true)->orderBy('order');
                    }]);
            }])
            ->get();

        return response()->json([
            'success' => true,
            'data' => [
                'phases' => $phases->map(function($phase) {
                    return [
                        'id' => $phase->id,
                        'name_ar' => $phase->name_ar,
                        'name_fr' => $phase->name_fr,
                        'slug' => $phase->slug,
                        'order' => $phase->order,
                        'years' => $phase->academicYears->map(function($year) {
                            return [
                                'id' => $year->id,
                                'name_ar' => $year->name_ar,
                                'name_fr' => $year->name_fr,
                                'slug' => $year->slug,
                                'order' => $year->order,
                                'streams' => $year->academicStreams->map(function($stream) {
                                    return [
                                        'id' => $stream->id,
                                        'name_ar' => $stream->name_ar,
                                        'name_fr' => $stream->name_fr,
                                        'slug' => $stream->slug,
                                        'order' => $stream->order,
                                    ];
                                }),
                            ];
                        }),
                    ];
                }),
            ],
        ]);
    }

    /**
     * Get all active phases.
     *
     * @return JsonResponse
     */
    public function phases(): JsonResponse
    {
        $phases = AcademicPhase::where('is_active', true)
            ->orderBy('order')
            ->get(['id', 'name_ar', 'slug', 'order']);

        return response()->json([
            'success' => true,
            'data' => $phases,
        ]);
    }

    /**
     * Get years for a specific phase.
     *
     * @param int $phaseId
     * @return JsonResponse
     */
    public function years(int $phaseId): JsonResponse
    {
        $phase = AcademicPhase::where('is_active', true)->findOrFail($phaseId);

        $years = $phase->academicYears()
            ->where('is_active', true)
            ->orderBy('order')
            ->get(['id', 'name_ar', 'level_number', 'order', 'academic_phase_id']);

        return response()->json([
            'success' => true,
            'data' => [
                'phase' => [
                    'id' => $phase->id,
                    'name_ar' => $phase->name_ar,
                ],
                'years' => $years,
            ],
        ]);
    }

    /**
     * Get streams for a specific year.
     *
     * @param int $yearId
     * @return JsonResponse
     */
    public function streams(int $yearId): JsonResponse
    {
        $year = AcademicYear::where('is_active', true)->findOrFail($yearId);

        $streams = $year->academicStreams()
            ->where('is_active', true)
            ->orderBy('order')
            ->get(['id', 'name_ar', 'slug', 'description_ar', 'order']);

        return response()->json([
            'success' => true,
            'data' => [
                'year' => [
                    'id' => $year->id,
                    'name_ar' => $year->name_ar,
                ],
                'streams' => $streams,
            ],
        ]);
    }
}
