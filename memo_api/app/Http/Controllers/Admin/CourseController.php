<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Course;
use App\Models\Subject;
use App\Services\CourseService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class CourseController extends Controller
{
    protected CourseService $courseService;

    public function __construct(CourseService $courseService)
    {
        $this->courseService = $courseService;
    }

    /**
     * Display courses list
     */
    public function index(Request $request)
    {
        $query = Course::with(['subject']);

        // Search
        if ($request->filled('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('title_ar', 'like', "%{$search}%")
                  ->orWhere('instructor_name', 'like', "%{$search}%");
            });
        }

        // Filter by subject
        if ($request->filled('subject_id')) {
            $query->where('subject_id', $request->subject_id);
        }

        // Filter by level
        if ($request->filled('level')) {
            $query->where('level', $request->level);
        }

        // Filter by publication status
        if ($request->filled('is_published')) {
            $query->where('is_published', $request->is_published);
        }

        // Filter by featured
        if ($request->filled('featured')) {
            $query->where('featured', $request->featured);
        }

        // Sorting
        $sortBy = $request->get('sort_by', 'created_at');
        $sortOrder = $request->get('sort_order', 'desc');
        $query->orderBy($sortBy, $sortOrder);

        $courses = $query->paginate(20);
        $subjects = Subject::orderBy('name_ar')->get();

        // Statistics
        $totalCourses = Course::count();
        $publishedCourses = Course::where('is_published', true)->count();
        $draftCourses = Course::where('is_published', false)->count();
        $totalEnrollments = DB::table('user_subscriptions')->whereNotNull('course_id')->count();

        return view('admin.courses.index', compact(
            'courses',
            'subjects',
            'totalCourses',
            'publishedCourses',
            'draftCourses',
            'totalEnrollments'
        ));
    }

    /**
     * Show create course form
     */
    public function create()
    {
        $subjects = Subject::orderBy('name_ar')->get();

        return view('admin.courses.create', compact('subjects'));
    }

    /**
     * Store new course
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'title_ar' => 'required|string|max:255',
            'description_ar' => 'required|string',
            'short_description_ar' => 'required|string|max:200',
            'what_you_will_learn' => 'nullable|string',
            'requirements' => 'nullable|string',
            'target_audience' => 'nullable|string',
            'thumbnail' => 'required|image|max:2048',
            'trailer_video_url' => 'nullable|string',
            'trailer_video_type' => 'nullable|in:youtube,upload',
            'trailer_video' => 'nullable|file|mimes:mp4,mov,avi|max:102400',
            'subject_id' => 'nullable|exists:subjects,id',
            'level' => 'required|in:beginner,intermediate,advanced',
            'tags' => 'nullable|string',
            'price_dzd' => 'required|integer|min:0',
            'is_free' => 'boolean',
            'requires_subscription' => 'boolean',
            'certificate_available' => 'boolean',
            'instructor_name' => 'required|string|max:255',
            'instructor_bio_ar' => 'nullable|string',
            'instructor_photo' => 'nullable|image|max:2048',
            'instructor_email' => 'nullable|email',
            'instructor_phone' => 'nullable|string|max:20',
            'whatsapp_number' => 'nullable|string|max:20',
            'facebook_url' => 'nullable|url',
            'featured' => 'boolean',
            'is_published' => 'boolean',
            'meta_description_ar' => 'nullable|string|max:160',
            'meta_keywords' => 'nullable|string',
        ]);

        // Convert tags string to array
        if (isset($validated['tags'])) {
            $validated['tags'] = array_map('trim', explode(',', $validated['tags']));
        }

        // Convert learning content fields to arrays (split by newlines)
        if (isset($validated['what_you_will_learn'])) {
            $validated['what_you_will_learn'] = array_filter(array_map('trim', explode("\n", $validated['what_you_will_learn'])));
        }
        if (isset($validated['requirements'])) {
            $validated['requirements'] = array_filter(array_map('trim', explode("\n", $validated['requirements'])));
        }
        if (isset($validated['target_audience'])) {
            $validated['target_audience'] = array_filter(array_map('trim', explode("\n", $validated['target_audience'])));
        }

        // Set certificate_available default
        $validated['certificate_available'] = $request->boolean('certificate_available', true);

        // Handle file uploads through service
        if ($request->hasFile('thumbnail')) {
            $validated['thumbnail'] = $request->file('thumbnail');
        }

        if ($request->hasFile('trailer_video')) {
            $validated['trailer_video'] = $request->file('trailer_video');
        }

        if ($request->hasFile('instructor_photo')) {
            $validated['instructor_photo'] = $request->file('instructor_photo');
        }

        try {
            $course = $this->courseService->createCourse($validated);

            return redirect()
                ->route('admin.courses.show', $course)
                ->with('success', 'تم إنشاء الدورة بنجاح');
        } catch (\Exception $e) {
            return back()
                ->withInput()
                ->with('error', 'حدث خطأ أثناء إنشاء الدورة: ' . $e->getMessage());
        }
    }

    /**
     * Show course details
     */
    public function show(Course $course)
    {
        $course->load([
            'subject.streams',
            'subject.academicYear',
            'modules.lessons',
            'modules.quizzes.quiz',
            'subscriptions',
            'reviews.user',
        ]);

        $stats = [
            'total_modules' => $course->modules->count(),
            'total_lessons' => $course->modules->sum(fn($m) => $m->lessons->count()),
            'total_quizzes' => $course->modules->sum(fn($m) => $m->quizzes->count()),
            'active_subscriptions' => $course->subscriptions()
                ->where('is_active', true)
                ->where('expires_at', '>', now())
                ->count(),
            'total_reviews' => $course->reviews->count(),
            'average_rating' => $course->reviews->avg('rating') ?? 0,
        ];

        // Get filtered quizzes based on the course's subject
        // Only show quizzes that match the same academic year, stream, and subject
        $filteredQuizzes = \App\Models\Quiz::where('is_published', true)
            ->where('subject_id', $course->subject_id)
            ->orderBy('title_ar')
            ->get();

        return view('admin.courses.show', compact('course', 'stats', 'filteredQuizzes'));
    }

    /**
     * Show edit course form
     */
    public function edit(Course $course)
    {
        $subjects = Subject::orderBy('name_ar')->get();

        return view('admin.courses.edit', compact('course', 'subjects'));
    }

    /**
     * Update course
     */
    public function update(Request $request, Course $course)
    {
        $validated = $request->validate([
            'title_ar' => 'required|string|max:255',
            'description_ar' => 'required|string',
            'short_description_ar' => 'required|string|max:200',
            'what_you_will_learn' => 'nullable|string',
            'requirements' => 'nullable|string',
            'target_audience' => 'nullable|string',
            'thumbnail' => 'nullable|image|max:2048',
            'trailer_video_url' => 'nullable|string',
            'trailer_video_type' => 'nullable|in:youtube,vimeo,upload,uploaded',
            'trailer_video' => 'nullable|file|mimes:mp4,mov,avi|max:102400',
            'subject_id' => 'required|exists:subjects,id',
            'level' => 'required|in:beginner,intermediate,advanced',
            'duration_days' => 'required|integer|min:1',
            'tags' => 'nullable|string',
            'price_dzd' => 'required|integer|min:0',
            'is_free' => 'boolean',
            'requires_subscription' => 'boolean',
            'certificate_available' => 'boolean',
            'instructor_name' => 'required|string|max:255',
            'instructor_bio_ar' => 'nullable|string',
            'instructor_photo' => 'nullable|image|max:2048',
            'instructor_email' => 'nullable|email',
            'instructor_phone' => 'nullable|string|max:20',
            'whatsapp_number' => 'nullable|string|max:20',
            'facebook_url' => 'nullable|url',
            'is_featured' => 'boolean',
            'is_published' => 'boolean',
            'meta_description_ar' => 'nullable|string|max:160',
            'meta_keywords' => 'nullable|string',
        ]);

        // Convert tags string to array
        if (isset($validated['tags'])) {
            $validated['tags'] = array_map('trim', explode(',', $validated['tags']));
        }

        // Convert learning content fields to arrays (split by newlines)
        if (isset($validated['what_you_will_learn'])) {
            $validated['what_you_will_learn'] = array_filter(array_map('trim', explode("\n", $validated['what_you_will_learn'])));
        }
        if (isset($validated['requirements'])) {
            $validated['requirements'] = array_filter(array_map('trim', explode("\n", $validated['requirements'])));
        }
        if (isset($validated['target_audience'])) {
            $validated['target_audience'] = array_filter(array_map('trim', explode("\n", $validated['target_audience'])));
        }

        // Handle boolean values (checkboxes don't send value when unchecked)
        $validated['is_free'] = $request->boolean('is_free');
        $validated['is_published'] = $request->boolean('is_published');
        $validated['is_featured'] = $request->boolean('is_featured');
        $validated['certificate_available'] = $request->boolean('certificate_available', true);

        // Handle file uploads
        if ($request->hasFile('thumbnail')) {
            $validated['thumbnail'] = $request->file('thumbnail');
        }

        if ($request->hasFile('trailer_video')) {
            $validated['trailer_video'] = $request->file('trailer_video');
        }

        if ($request->hasFile('instructor_photo')) {
            $validated['instructor_photo'] = $request->file('instructor_photo');
        }

        try {
            $course = $this->courseService->updateCourse($course, $validated);

            return redirect()
                ->route('admin.courses.show', $course)
                ->with('success', 'تم تحديث الدورة بنجاح');
        } catch (\Exception $e) {
            return back()
                ->withInput()
                ->with('error', 'حدث خطأ أثناء تحديث الدورة: ' . $e->getMessage());
        }
    }

    /**
     * Delete course
     */
    public function destroy(Course $course)
    {
        try {
            $this->courseService->deleteCourse($course);

            return redirect()
                ->route('admin.courses.index')
                ->with('success', 'تم حذف الدورة بنجاح');
        } catch (\Exception $e) {
            return back()->with('error', 'حدث خطأ أثناء حذف الدورة: ' . $e->getMessage());
        }
    }

    /**
     * Publish course
     */
    public function publish(Course $course)
    {
        try {
            $this->courseService->publishCourse($course);

            return back()->with('success', 'تم نشر الدورة بنجاح');
        } catch (\Exception $e) {
            return back()->with('error', 'حدث خطأ: ' . $e->getMessage());
        }
    }

    /**
     * Unpublish course
     */
    public function unpublish(Course $course)
    {
        try {
            $this->courseService->unpublishCourse($course);

            return back()->with('success', 'تم إلغاء نشر الدورة بنجاح');
        } catch (\Exception $e) {
            return back()->with('error', 'حدث خطأ: ' . $e->getMessage());
        }
    }

    /**
     * Update course statistics
     */
    public function updateStatistics(Course $course)
    {
        try {
            $course->updateStatistics();

            return back()->with('success', 'تم تحديث إحصائيات الدورة بنجاح');
        } catch (\Exception $e) {
            return back()->with('error', 'حدث خطأ: ' . $e->getMessage());
        }
    }

    /**
     * Reorder modules
     */
    public function reorderModules(Request $request, Course $course)
    {
        $validated = $request->validate([
            'module_orders' => 'required|array',
            'module_orders.*' => 'required|integer',
        ]);

        try {
            $this->courseService->reorderModules($course, $validated['module_orders']);

            return response()->json(['success' => true, 'message' => 'تم إعادة ترتيب الوحدات بنجاح']);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }

    /**
     * Delete all enrollments for a course
     */
    public function deleteAllEnrollments(Course $course)
    {
        try {
            $enrollmentCount = DB::table('user_subscriptions')
                ->where('course_id', $course->id)
                ->count();

            // Delete all subscriptions for this course
            DB::table('user_subscriptions')
                ->where('course_id', $course->id)
                ->delete();

            // Update course enrollment count
            $course->update(['enrollment_count' => 0]);

            return redirect()->back()
                ->with('success', "تم حذف جميع الاشتراكات ({$enrollmentCount} اشتراك) بنجاح");
        } catch (\Exception $e) {
            return redirect()->back()
                ->with('error', 'حدث خطأ أثناء حذف الاشتراكات: ' . $e->getMessage());
        }
    }
}
