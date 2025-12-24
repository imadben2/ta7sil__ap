<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Subject;
use App\Models\ContentChapter;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class ChapterController extends Controller
{
    /**
     * Display a listing of chapters for a subject.
     */
    public function index(Subject $subject)
    {
        $chapters = $subject->contentChapters()
            ->where('is_active', true)
            ->orderBy('order')
            ->get();

        return view('admin.chapters.index', compact('subject', 'chapters'));
    }

    /**
     * Store a newly created chapter.
     */
    public function store(Request $request, Subject $subject)
    {
        $validated = $request->validate([
            'title_ar' => 'required|string|max:255',
            'description_ar' => 'nullable|string',
            'order' => 'nullable|integer',
        ]);

        $validated['subject_id'] = $subject->id;
        $validated['slug'] = Str::slug($request->title_ar . '-' . time());
        $validated['is_active'] = true;

        // If no order provided, set it to last
        if (!isset($validated['order'])) {
            $lastOrder = $subject->contentChapters()->max('order') ?? 0;
            $validated['order'] = $lastOrder + 1;
        }

        ContentChapter::create($validated);

        return redirect()->route('admin.subjects.show', $subject)
            ->with('success', 'تم إضافة الفصل بنجاح');
    }

    /**
     * Update the specified chapter.
     */
    public function update(Request $request, Subject $subject, ContentChapter $chapter)
    {
        // Ensure chapter belongs to subject
        if ($chapter->subject_id !== $subject->id) {
            abort(404);
        }

        $validated = $request->validate([
            'title_ar' => 'required|string|max:255',
            'description_ar' => 'nullable|string',
            'order' => 'nullable|integer',
            'is_active' => 'boolean',
        ]);

        $validated['is_active'] = $request->has('is_active');

        $chapter->update($validated);

        return redirect()->route('admin.subjects.show', $subject)
            ->with('success', 'تم تحديث الفصل بنجاح');
    }

    /**
     * Remove the specified chapter.
     */
    public function destroy(Subject $subject, ContentChapter $chapter)
    {
        // Ensure chapter belongs to subject
        if ($chapter->subject_id !== $subject->id) {
            abort(404);
        }

        // Check if chapter has contents
        if ($chapter->contents()->count() > 0) {
            return redirect()->back()
                ->with('error', 'لا يمكن حذف فصل يحتوي على محتويات. قم بحذف أو نقل المحتويات أولاً.');
        }

        $chapter->delete();

        return redirect()->route('admin.subjects.show', $subject)
            ->with('success', 'تم حذف الفصل بنجاح');
    }

    /**
     * Reorder chapters.
     */
    public function reorder(Request $request, Subject $subject)
    {
        $validated = $request->validate([
            'chapters' => 'required|array',
            'chapters.*' => 'required|exists:content_chapters,id',
        ]);

        foreach ($validated['chapters'] as $order => $chapterId) {
            ContentChapter::where('id', $chapterId)
                ->where('subject_id', $subject->id)
                ->update(['order' => $order + 1]);
        }

        return redirect()->back()
            ->with('success', 'تم إعادة ترتيب الفصول بنجاح');
    }
}
