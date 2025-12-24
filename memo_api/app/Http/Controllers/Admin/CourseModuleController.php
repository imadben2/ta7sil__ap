<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Course;
use App\Models\CourseModule;
use App\Services\CourseService;
use Illuminate\Http\Request;

class CourseModuleController extends Controller
{
    protected CourseService $courseService;

    public function __construct(CourseService $courseService)
    {
        $this->courseService = $courseService;
    }

    /**
     * Store new module
     */
    public function store(Request $request, Course $course)
    {
        $validated = $request->validate([
            'title_ar' => 'required|string|max:255',
            'description_ar' => 'nullable|string',
            'order' => 'nullable|integer|min:0',
            'is_published' => 'boolean',
        ]);

        try {
            $module = $this->courseService->createModule($course, $validated);

            return redirect()
                ->route('admin.courses.show', $course)
                ->with('success', 'تم إنشاء الوحدة بنجاح');
        } catch (\Exception $e) {
            return back()
                ->withInput()
                ->with('error', 'حدث خطأ أثناء إنشاء الوحدة: ' . $e->getMessage());
        }
    }

    /**
     * Update module
     */
    public function update(Request $request, CourseModule $module)
    {
        $validated = $request->validate([
            'title_ar' => 'required|string|max:255',
            'description_ar' => 'nullable|string',
            'order' => 'nullable|integer|min:0',
            'is_published' => 'boolean',
        ]);

        try {
            $module = $this->courseService->updateModule($module, $validated);

            return redirect()
                ->route('admin.courses.show', $module->course)
                ->with('success', 'تم تحديث الوحدة بنجاح');
        } catch (\Exception $e) {
            return back()
                ->withInput()
                ->with('error', 'حدث خطأ أثناء تحديث الوحدة: ' . $e->getMessage());
        }
    }

    /**
     * Delete module
     */
    public function destroy(CourseModule $module)
    {
        $course = $module->course;

        try {
            $this->courseService->deleteModule($module);

            return redirect()
                ->route('admin.courses.show', $course)
                ->with('success', 'تم حذف الوحدة بنجاح');
        } catch (\Exception $e) {
            return back()->with('error', 'حدث خطأ أثناء حذف الوحدة: ' . $e->getMessage());
        }
    }

    /**
     * Reorder lessons in module
     */
    public function reorderLessons(Request $request, CourseModule $module)
    {
        $validated = $request->validate([
            'lesson_orders' => 'required|array',
            'lesson_orders.*' => 'required|integer',
        ]);

        try {
            $this->courseService->reorderLessons($module, $validated['lesson_orders']);

            return response()->json(['success' => true, 'message' => 'تم إعادة ترتيب الدروس بنجاح']);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }
}
