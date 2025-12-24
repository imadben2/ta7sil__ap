<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\CourseModule;
use App\Models\CourseLesson;
use App\Services\CourseService;
use Illuminate\Http\Request;

class CourseLessonController extends Controller
{
    protected CourseService $courseService;

    public function __construct(CourseService $courseService)
    {
        $this->courseService = $courseService;
    }

    /**
     * Store new lesson
     */
    public function store(Request $request, CourseModule $module)
    {
        // Base validation rules
        $rules = [
            'title_ar' => 'required|string|max:255',
            'description_ar' => 'nullable|string',
            'order' => 'nullable|integer|min:0',
            'content_type' => 'required|in:video,document,quiz,text',
            'is_free_preview' => 'boolean',
            'is_published' => 'boolean',
        ];

        // Add conditional validation based on content type
        $contentType = $request->input('content_type', 'video');

        switch ($contentType) {
            case 'video':
                $rules = array_merge($rules, [
                    'video_type' => 'required|in:youtube,upload',
                    'video_url' => 'required_if:video_type,youtube|nullable|string',
                    'video' => 'required_if:video_type,upload|nullable|file|mimes:mp4,mov,avi|max:512000',
                    'video_duration_seconds' => 'required|integer|min:0',
                    'video_thumbnail' => 'nullable|image|max:2048',
                ]);
                break;

            case 'document':
                $rules = array_merge($rules, [
                    'document' => 'required|file|mimes:pdf,doc,docx,ppt,pptx,xls,xlsx|max:20480',
                ]);
                break;

            case 'quiz':
                $rules = array_merge($rules, [
                    'quiz_id' => 'required|exists:quizzes,id',
                ]);
                break;

            case 'text':
                $rules = array_merge($rules, [
                    'content_text_ar' => 'required|string',
                ]);
                break;
        }

        $validated = $request->validate($rules);

        // Handle file uploads based on content type
        if ($request->hasFile('video')) {
            $validated['video'] = $request->file('video');
        }

        if ($request->hasFile('video_thumbnail')) {
            $validated['video_thumbnail'] = $request->file('video_thumbnail');
        }

        if ($request->hasFile('document')) {
            $validated['document'] = $request->file('document');
        }

        try {
            $lesson = $this->courseService->createLesson($module, $validated);

            return redirect()
                ->route('admin.courses.show', $module->course)
                ->with('success', 'تم إنشاء الدرس بنجاح');
        } catch (\Exception $e) {
            return back()
                ->withInput()
                ->with('error', 'حدث خطأ أثناء إنشاء الدرس: ' . $e->getMessage());
        }
    }

    /**
     * Show lesson details for viewing
     */
    public function view(CourseLesson $lesson)
    {
        return view('admin.courses.partials.lesson-view', compact('lesson'));
    }

    /**
     * Show lesson edit form
     */
    public function edit(CourseLesson $lesson)
    {
        return view('admin.courses.partials.lesson-edit', compact('lesson'));
    }

    /**
     * Update lesson
     */
    public function update(Request $request, CourseLesson $lesson)
    {
        // Base validation rules
        $rules = [
            'title_ar' => 'required|string|max:255',
            'description_ar' => 'nullable|string',
            'order' => 'nullable|integer|min:0',
            'content_type' => 'required|in:video,document,quiz,text',
            'is_free_preview' => 'boolean',
            'is_published' => 'boolean',
        ];

        // Add conditional validation based on content type
        $contentType = $request->input('content_type', $lesson->content_type ?? 'video');

        switch ($contentType) {
            case 'video':
                $rules = array_merge($rules, [
                    'video_type' => 'required|in:youtube,upload',
                    'video_url' => 'required_if:video_type,youtube|nullable|string',
                    'video' => 'nullable|file|mimes:mp4,mov,avi|max:512000',
                    'video_duration_seconds' => 'required|integer|min:0',
                    'video_thumbnail' => 'nullable|image|max:2048',
                ]);
                break;

            case 'document':
                $rules = array_merge($rules, [
                    'document' => 'nullable|file|mimes:pdf,doc,docx,ppt,pptx,xls,xlsx|max:20480',
                ]);
                break;

            case 'quiz':
                $rules = array_merge($rules, [
                    'quiz_id' => 'required|exists:quizzes,id',
                ]);
                break;

            case 'text':
                $rules = array_merge($rules, [
                    'content_text_ar' => 'required|string',
                ]);
                break;
        }

        $validated = $request->validate($rules);

        // Handle file uploads based on content type
        if ($request->hasFile('video')) {
            $validated['video'] = $request->file('video');
        }

        if ($request->hasFile('video_thumbnail')) {
            $validated['video_thumbnail'] = $request->file('video_thumbnail');
        }

        if ($request->hasFile('document')) {
            $validated['document'] = $request->file('document');
        }

        try {
            $lesson = $this->courseService->updateLesson($lesson, $validated);

            // Handle new attachment if provided
            if ($request->hasFile('new_attachment')) {
                $this->courseService->addAttachment($lesson, $request->file('new_attachment'));
            }

            // If it's an AJAX request (from modal), return JSON
            if ($request->ajax() || $request->wantsJson()) {
                return response()->json([
                    'success' => true,
                    'message' => 'تم تحديث الدرس بنجاح'
                ]);
            }

            return redirect()
                ->route('admin.courses.show', $lesson->module->course)
                ->with('success', 'تم تحديث الدرس بنجاح');
        } catch (\Exception $e) {
            if ($request->ajax() || $request->wantsJson()) {
                return response()->json([
                    'success' => false,
                    'message' => 'حدث خطأ أثناء تحديث الدرس: ' . $e->getMessage()
                ], 500);
            }

            return back()
                ->withInput()
                ->with('error', 'حدث خطأ أثناء تحديث الدرس: ' . $e->getMessage());
        }
    }

    /**
     * Delete lesson
     */
    public function destroy(CourseLesson $lesson)
    {
        $course = $lesson->module->course;

        try {
            $this->courseService->deleteLesson($lesson);

            return redirect()
                ->route('admin.courses.show', $course)
                ->with('success', 'تم حذف الدرس بنجاح');
        } catch (\Exception $e) {
            return back()->with('error', 'حدث خطأ أثناء حذف الدرس: ' . $e->getMessage());
        }
    }

    /**
     * Add attachment to lesson
     */
    public function addAttachment(Request $request, CourseLesson $lesson)
    {
        $validated = $request->validate([
            'attachment' => 'required|file|max:10240',
        ]);

        try {
            $attachment = $this->courseService->addAttachment($lesson, $request->file('attachment'));

            return back()->with('success', 'تم إضافة المرفق بنجاح');
        } catch (\Exception $e) {
            return back()->with('error', 'حدث خطأ أثناء إضافة المرفق: ' . $e->getMessage());
        }
    }

    /**
     * Delete attachment
     */
    public function deleteAttachment($attachmentId)
    {
        try {
            $attachment = \App\Models\CourseLessonAttachment::findOrFail($attachmentId);
            $this->courseService->deleteAttachment($attachment);

            // If it's an AJAX request, return JSON
            if (request()->ajax() || request()->wantsJson()) {
                return response()->json([
                    'success' => true,
                    'message' => 'تم حذف المرفق بنجاح'
                ]);
            }

            return back()->with('success', 'تم حذف المرفق بنجاح');
        } catch (\Exception $e) {
            if (request()->ajax() || request()->wantsJson()) {
                return response()->json([
                    'success' => false,
                    'message' => 'حدث خطأ أثناء حذف المرفق: ' . $e->getMessage()
                ], 500);
            }

            return back()->with('error', 'حدث خطأ أثناء حذف المرفق: ' . $e->getMessage());
        }
    }
}
