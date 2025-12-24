<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\CourseReview;
use App\Models\Course;
use Illuminate\Http\Request;
use Yajra\DataTables\Facades\DataTables;

class CourseReviewController extends Controller
{
    /**
     * Display reviews list
     */
    public function index(Request $request)
    {
        $courses = Course::orderBy('title_ar')->get();

        // Statistics
        $stats = [
            'total' => CourseReview::count(),
            'pending' => CourseReview::where('is_approved', false)->count(),
            'approved' => CourseReview::where('is_approved', true)->count(),
            'average_rating' => round(CourseReview::where('is_approved', true)->avg('rating') ?? 0, 1),
        ];

        if ($request->ajax()) {
            $query = CourseReview::with(['user', 'course']);

            return DataTables::of($query)
                ->addIndexColumn()
                ->addColumn('user_name', function ($review) {
                    return '<div class="flex items-center gap-2">
                                <div class="w-8 h-8 bg-gradient-to-br from-blue-500 to-purple-500 rounded-lg flex items-center justify-center text-white font-bold text-xs">
                                    ' . mb_substr($review->user->name ?? 'N/A', 0, 1) . '
                                </div>
                                <span class="font-semibold">' . ($review->user->name ?? 'N/A') . '</span>
                            </div>';
                })
                ->addColumn('course_name', function ($review) {
                    return '<span class="font-semibold text-blue-600">' . ($review->course->title_ar ?? 'N/A') . '</span>';
                })
                ->addColumn('rating_stars', function ($review) {
                    $stars = '';
                    for ($i = 1; $i <= 5; $i++) {
                        if ($i <= $review->rating) {
                            $stars .= '<i class="fas fa-star text-yellow-400"></i>';
                        } else {
                            $stars .= '<i class="fas fa-star text-gray-300"></i>';
                        }
                    }
                    return '<div class="flex items-center gap-1">' . $stars . '<span class="text-sm font-bold text-gray-700 mr-2">(' . $review->rating . ')</span></div>';
                })
                ->addColumn('review_text', function ($review) {
                    $text = $review->review_text_ar ?? '';
                    return '<span class="text-sm text-gray-600">' . \Illuminate\Support\Str::limit($text, 60) . '</span>';
                })
                ->addColumn('status', function ($review) {
                    if ($review->is_approved) {
                        return '<span class="px-3 py-1 text-xs font-bold rounded-full bg-green-500 text-white shadow-sm flex items-center gap-1 w-fit">
                                    <i class="fas fa-check-circle"></i>
                                    مقبول
                                </span>';
                    } else {
                        return '<span class="px-3 py-1 text-xs font-bold rounded-full bg-yellow-500 text-white shadow-sm flex items-center gap-1 w-fit">
                                    <i class="fas fa-clock"></i>
                                    معلق
                                </span>';
                    }
                })
                ->addColumn('created_date', function ($review) {
                    return '<span class="text-sm text-gray-600">' . $review->created_at->format('Y-m-d') . '</span>';
                })
                ->addColumn('actions', function ($review) {
                    $actions = '<div class="flex items-center gap-2">';

                    if (!$review->is_approved) {
                        $actions .= '<form action="' . route('admin.course-reviews.approve', $review) . '" method="POST" class="inline">
                                        ' . csrf_field() . '
                                        <button type="submit" class="p-2 bg-green-50 hover:bg-green-100 text-green-600 rounded-lg transition-all" title="قبول">
                                            <i class="fas fa-check"></i>
                                        </button>
                                    </form>';
                        $actions .= '<form action="' . route('admin.course-reviews.reject', $review) . '" method="POST" class="inline">
                                        ' . csrf_field() . '
                                        <button type="submit" class="p-2 bg-orange-50 hover:bg-orange-100 text-orange-600 rounded-lg transition-all" title="رفض">
                                            <i class="fas fa-times"></i>
                                        </button>
                                    </form>';
                    } else {
                        $actions .= '<span class="text-xs text-gray-400 italic">تم المراجعة</span>';
                    }

                    $actions .= '<form action="' . route('admin.course-reviews.destroy', $review) . '" method="POST" class="inline" onsubmit="return confirm(\'هل أنت متأكد من حذف هذا التقييم؟\')">
                                    ' . csrf_field() . '
                                    ' . method_field('DELETE') . '
                                    <button type="submit" class="p-2 bg-red-50 hover:bg-red-100 text-red-600 rounded-lg transition-all" title="حذف">
                                        <i class="fas fa-trash"></i>
                                    </button>
                                </form>';

                    $actions .= '</div>';

                    return $actions;
                })
                ->filter(function ($query) use ($request) {
                    if ($request->has('search') && $request->search['value']) {
                        $search = $request->search['value'];
                        $query->where(function ($q) use ($search) {
                            $q->whereHas('user', function ($subQ) use ($search) {
                                $subQ->where('name', 'like', "%{$search}%");
                            })->orWhereHas('course', function ($subQ) use ($search) {
                                $subQ->where('title_ar', 'like', "%{$search}%");
                            })->orWhere('review_text_ar', 'like', "%{$search}%");
                        });
                    }

                    if ($request->filled('course_id')) {
                        $query->where('course_id', $request->course_id);
                    }

                    if ($request->filled('rating')) {
                        $query->where('rating', $request->rating);
                    }

                    if ($request->filled('status')) {
                        if ($request->status === 'approved') {
                            $query->where('is_approved', true);
                        } elseif ($request->status === 'pending') {
                            $query->where('is_approved', false);
                        }
                    }
                })
                ->rawColumns(['user_name', 'course_name', 'rating_stars', 'review_text', 'status', 'created_date', 'actions'])
                ->make(true);
        }

        return view('admin.course-reviews.index', compact('courses', 'stats'));
    }

    /**
     * Show review details
     */
    public function show(CourseReview $review)
    {
        $review->load(['user', 'course']);

        return view('admin.course-reviews.show', compact('review'));
    }

    /**
     * Approve review
     */
    public function approve(CourseReview $review)
    {
        try {
            $review->approve();

            return back()->with('success', 'تم قبول التقييم بنجاح');
        } catch (\Exception $e) {
            return back()->with('error', 'حدث خطأ: ' . $e->getMessage());
        }
    }

    /**
     * Reject review
     */
    public function reject(CourseReview $review)
    {
        try {
            $review->reject();

            return back()->with('success', 'تم رفض التقييم بنجاح');
        } catch (\Exception $e) {
            return back()->with('error', 'حدث خطأ: ' . $e->getMessage());
        }
    }

    /**
     * Delete review
     */
    public function destroy(CourseReview $review)
    {
        try {
            $course = $review->course;
            $review->delete();
            $course->updateStatistics();

            return redirect()
                ->route('admin.course-reviews.index')
                ->with('success', 'تم حذف التقييم بنجاح');
        } catch (\Exception $e) {
            return back()->with('error', 'حدث خطأ: ' . $e->getMessage());
        }
    }

    /**
     * Bulk approve reviews
     */
    public function bulkApprove(Request $request)
    {
        $validated = $request->validate([
            'review_ids' => 'required|array',
            'review_ids.*' => 'exists:course_reviews,id',
        ]);

        try {
            $count = 0;

            foreach ($validated['review_ids'] as $reviewId) {
                $review = CourseReview::find($reviewId);

                if ($review && !$review->is_approved) {
                    $review->approve();
                    $count++;
                }
            }

            return back()->with('success', "تم قبول {$count} تقييم بنجاح");
        } catch (\Exception $e) {
            return back()->with('error', 'حدث خطأ: ' . $e->getMessage());
        }
    }

    /**
     * Bulk reject reviews
     */
    public function bulkReject(Request $request)
    {
        $validated = $request->validate([
            'review_ids' => 'required|array',
            'review_ids.*' => 'exists:course_reviews,id',
        ]);

        try {
            $count = 0;

            foreach ($validated['review_ids'] as $reviewId) {
                $review = CourseReview::find($reviewId);

                if ($review && $review->is_approved) {
                    $review->reject();
                    $count++;
                }
            }

            return back()->with('success', "تم رفض {$count} تقييم بنجاح");
        } catch (\Exception $e) {
            return back()->with('error', 'حدث خطأ: ' . $e->getMessage());
        }
    }
}
