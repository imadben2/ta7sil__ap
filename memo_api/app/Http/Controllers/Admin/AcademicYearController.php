<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AcademicYear;
use App\Models\AcademicPhase;
use Illuminate\Http\Request;

class AcademicYearController extends Controller
{
    /**
     * Display a listing of the academic years.
     */
    public function index(Request $request)
    {
        $query = AcademicYear::with('academicPhase')
            ->withCount(['academicStreams', 'subjects']);

        // Filter by phase
        if ($request->has('phase_id')) {
            $query->where('academic_phase_id', $request->phase_id);
        }

        $years = $query->orderBy('order')->get();
        $phases = AcademicPhase::orderBy('order')->get();

        return view('admin.academic-years.index', compact('years', 'phases'));
    }

    /**
     * Show the form for creating a new academic year.
     */
    public function create()
    {
        $phases = AcademicPhase::orderBy('order')->get();
        return view('admin.academic-years.create', compact('phases'));
    }

    /**
     * Store a newly created academic year in storage.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'academic_phase_id' => 'required|exists:academic_phases,id',
            'name_ar' => 'required|string|max:255',
            'level_number' => 'required|integer|min:1',
            'order' => 'required|integer|min:0',
            'is_active' => 'boolean',
        ]);

        AcademicYear::create($validated);

        return redirect()->route('admin.academic-years.index')
            ->with('success', 'تم إضافة السنة الدراسية بنجاح');
    }

    /**
     * Display the specified academic year.
     */
    public function show(AcademicYear $academicYear)
    {
        $academicYear->load([
            'academicPhase',
            'academicStreams' => function($query) {
                $query->withCount('subjects')->orderBy('order');
            },
            'subjects' => function($query) {
                $query->with('academicStream')->orderBy('order');
            }
        ]);

        return view('admin.academic-years.show', compact('academicYear'));
    }

    /**
     * Show the form for editing the specified academic year.
     */
    public function edit(AcademicYear $academicYear)
    {
        $phases = AcademicPhase::orderBy('order')->get();
        return view('admin.academic-years.edit', compact('academicYear', 'phases'));
    }

    /**
     * Update the specified academic year in storage.
     */
    public function update(Request $request, AcademicYear $academicYear)
    {
        $validated = $request->validate([
            'academic_phase_id' => 'required|exists:academic_phases,id',
            'name_ar' => 'required|string|max:255',
            'level_number' => 'required|integer|min:1',
            'order' => 'required|integer|min:0',
            'is_active' => 'boolean',
        ]);

        $academicYear->update($validated);

        return redirect()->route('admin.academic-years.index')
            ->with('success', 'تم تحديث السنة الدراسية بنجاح');
    }

    /**
     * Remove the specified academic year from storage.
     */
    public function destroy(AcademicYear $academicYear)
    {
        // Check if year has streams or subjects
        if ($academicYear->academicStreams()->count() > 0 || $academicYear->subjects()->count() > 0) {
            return redirect()->route('admin.academic-years.index')
                ->with('error', 'لا يمكن حذف السنة الدراسية لأنها تحتوي على شعب أو مواد');
        }

        $academicYear->delete();

        return redirect()->route('admin.academic-years.index')
            ->with('success', 'تم حذف السنة الدراسية بنجاح');
    }
}
