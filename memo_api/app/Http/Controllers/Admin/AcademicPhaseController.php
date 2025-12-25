<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AcademicPhase;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class AcademicPhaseController extends Controller
{
    /**
     * Display a listing of the academic phases.
     */
    public function index()
    {
        $phases = AcademicPhase::withCount(['academicYears', 'academicStreams'])
            ->orderBy('order')
            ->get();

        return view('admin.academic-phases.index', compact('phases'));
    }

    /**
     * Show the form for creating a new academic phase.
     */
    public function create()
    {
        return view('admin.academic-phases.create');
    }

    /**
     * Store a newly created academic phase in storage.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name_ar' => 'required|string|max:255|unique:academic_phases,name_ar',
            'order' => 'required|integer|min:0',
            'is_active' => 'nullable|boolean',
        ]);

        $validated['slug'] = Str::slug($validated['name_ar']);
        $validated['is_active'] = $request->boolean('is_active', true);

        AcademicPhase::create($validated);

        return redirect()->route('admin.academic-phases.index')
            ->with('success', 'تم إضافة المرحلة بنجاح');
    }

    /**
     * Display the specified academic phase.
     */
    public function show(AcademicPhase $academicPhase)
    {
        $academicPhase->load(['academicYears' => function($query) {
            $query->withCount(['academicStreams', 'subjects'])->orderBy('order');
        }, 'academicStreams' => function($query) {
            $query->withCount('subjects')->orderBy('order');
        }]);

        return view('admin.academic-phases.show', compact('academicPhase'));
    }

    /**
     * Show the form for editing the specified academic phase.
     */
    public function edit(AcademicPhase $academicPhase)
    {
        return view('admin.academic-phases.edit', compact('academicPhase'));
    }

    /**
     * Update the specified academic phase in storage.
     */
    public function update(Request $request, AcademicPhase $academicPhase)
    {
        $validated = $request->validate([
            'name_ar' => 'required|string|max:255|unique:academic_phases,name_ar,' . $academicPhase->id,
            'order' => 'required|integer|min:0',
            'is_active' => 'nullable|boolean',
        ]);

        $validated['slug'] = Str::slug($validated['name_ar']);
        $validated['is_active'] = $request->has('is_active');

        $academicPhase->update($validated);

        return redirect()->route('admin.academic-phases.index')
            ->with('success', 'تم تحديث المرحلة بنجاح');
    }

    /**
     * Toggle the active status of the academic phase.
     */
    public function toggleStatus(AcademicPhase $academicPhase)
    {
        $academicPhase->update([
            'is_active' => !$academicPhase->is_active,
        ]);

        $status = $academicPhase->is_active ? 'تفعيل' : 'تعطيل';
        return redirect()->route('admin.academic-phases.index')
            ->with('success', "تم {$status} المرحلة بنجاح");
    }

    /**
     * Remove the specified academic phase from storage.
     */
    public function destroy(AcademicPhase $academicPhase)
    {
        // Check if phase has academic years
        if ($academicPhase->academicYears()->count() > 0) {
            return redirect()->route('admin.academic-phases.index')
                ->with('error', 'لا يمكن حذف المرحلة لأنها تحتوي على سنوات دراسية');
        }

        $academicPhase->delete();

        return redirect()->route('admin.academic-phases.index')
            ->with('success', 'تم حذف المرحلة بنجاح');
    }
}
