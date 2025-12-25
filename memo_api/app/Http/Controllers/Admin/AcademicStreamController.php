<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AcademicStream;
use App\Models\AcademicYear;
use App\Models\AcademicPhase;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class AcademicStreamController extends Controller
{
    /**
     * Display a listing of the academic streams.
     */
    public function index(Request $request)
    {
        $query = AcademicStream::with(['academicYear.academicPhase'])
            ->withCount('subjects');

        // Filter by year
        if ($request->has('year_id')) {
            $query->where('academic_year_id', $request->year_id);
        }

        $academicStreams = $query->orderBy('order')->get();
        $academicYears = AcademicYear::with('academicPhase')->orderBy('order')->get();
        $academicPhases = AcademicPhase::orderBy('order')->get();

        // Calculate statistics
        $totalStreams = AcademicStream::count();
        $activeStreams = AcademicStream::where('is_active', true)->count();
        $inactiveStreams = AcademicStream::where('is_active', false)->count();
        $totalSubjects = \App\Models\Subject::whereHas('streams')->count();

        return view('admin.academic-streams.index', compact(
            'academicStreams',
            'academicYears',
            'academicPhases',
            'totalStreams',
            'activeStreams',
            'inactiveStreams',
            'totalSubjects'
        ));
    }

    /**
     * Show the form for creating a new academic stream.
     */
    public function create()
    {
        $academicPhases = AcademicPhase::with(['academicYears' => function($query) {
            $query->orderBy('order');
        }])->orderBy('order')->get();

        return view('admin.academic-streams.create', compact('academicPhases'));
    }

    /**
     * Store a newly created academic stream in storage.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'academic_year_id' => 'required|exists:academic_years,id',
            'name_ar' => 'required|string|max:255',
            'description_ar' => 'nullable|string',
            'order' => 'required|integer|min:0',
            'is_active' => 'nullable|boolean',
        ]);

        $validated['slug'] = Str::slug($validated['name_ar']);
        $validated['is_active'] = $request->boolean('is_active', true);

        AcademicStream::create($validated);

        return redirect()->route('admin.academic-streams.index')
            ->with('success', 'تم إضافة الشعبة بنجاح');
    }

    /**
     * Display the specified academic stream.
     */
    public function show(AcademicStream $academicStream)
    {
        $academicStream->load([
            'academicYear.academicPhase',
            'subjects' => function($query) {
                $query->withCount('contents')->orderBy('order');
            }
        ]);

        return view('admin.academic-streams.show', compact('academicStream'));
    }

    /**
     * Show the form for editing the specified academic stream.
     */
    public function edit(AcademicStream $academicStream)
    {
        $academicPhases = AcademicPhase::with(['academicYears' => function($query) {
            $query->orderBy('order');
        }])->orderBy('order')->get();

        return view('admin.academic-streams.edit', compact('academicStream', 'academicPhases'));
    }

    /**
     * Update the specified academic stream in storage.
     */
    public function update(Request $request, AcademicStream $academicStream)
    {
        $validated = $request->validate([
            'academic_year_id' => 'required|exists:academic_years,id',
            'name_ar' => 'required|string|max:255',
            'description_ar' => 'nullable|string',
            'order' => 'required|integer|min:0',
            'is_active' => 'nullable|boolean',
        ]);

        $validated['slug'] = Str::slug($validated['name_ar']);
        $validated['is_active'] = $request->has('is_active');

        $academicStream->update($validated);

        return redirect()->route('admin.academic-streams.index')
            ->with('success', 'تم تحديث الشعبة بنجاح');
    }

    /**
     * Remove the specified academic stream from storage.
     */
    public function destroy(AcademicStream $academicStream)
    {
        // Check if stream has subjects
        if ($academicStream->subjects()->count() > 0) {
            return redirect()->route('admin.academic-streams.index')
                ->with('error', 'لا يمكن حذف الشعبة لأنها تحتوي على مواد');
        }

        $academicStream->delete();

        return redirect()->route('admin.academic-streams.index')
            ->with('success', 'تم حذف الشعبة بنجاح');
    }
}
