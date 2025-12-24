<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Course;
use App\Models\SubscriptionPackage;
use App\Models\UserSubscription;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class SubscriptionAssignmentController extends Controller
{
    /**
     * Show the assign courses to students page
     */
    public function assignCoursesIndex()
    {
        $students = User::where('role', 'student')
            ->orderBy('name')
            ->get(['id', 'name', 'email']);

        $courses = Course::where('is_published', true)
            ->orderBy('title_ar')
            ->get(['id', 'title_ar', 'price_dzd', 'is_free']);

        return view('admin.subscriptions.assign-courses', compact('students', 'courses'));
    }

    /**
     * Assign courses to students (bulk assignment)
     */
    public function assignCourses(Request $request)
    {
        $request->validate([
            'students' => 'required|array|min:1',
            'students.*' => 'exists:users,id',
            'courses' => 'required|array|min:1',
            'courses.*' => 'exists:courses,id',
            'start_date' => 'required|date',
            'duration_days' => 'required|integer|min:1|max:3650',
            'subscription_method' => 'required|in:ccp,baridi_mob,code,manual',
            'status' => 'required|in:active,expired,cancelled',
        ]);

        $assignedCount = 0;
        $skippedCount = 0;
        $errors = [];

        DB::beginTransaction();

        try {
            $startDate = Carbon::parse($request->start_date);
            $expiresAt = $startDate->copy()->addDays((int) $request->duration_days);

            foreach ($request->students as $studentId) {
                foreach ($request->courses as $courseId) {
                    // Check if subscription already exists
                    $existing = UserSubscription::where('user_id', $studentId)
                        ->where('course_id', $courseId)
                        ->first();

                    if ($existing) {
                        $skippedCount++;
                        continue;
                    }

                    // Create subscription
                    UserSubscription::create([
                        'user_id' => $studentId,
                        'course_id' => $courseId,
                        'package_id' => null,
                        'activated_by' => $request->subscription_method === 'code' ? 'code' : 'receipt',
                        'activated_at' => $startDate,
                        'status' => $request->status,
                        'started_at' => $startDate,
                        'expires_at' => $expiresAt,
                    ]);

                    $assignedCount++;
                }
            }

            DB::commit();

            $message = "تم تعيين $assignedCount اشتراك بنجاح.";
            if ($skippedCount > 0) {
                $message .= " تم تخطي $skippedCount اشتراك موجود مسبقاً.";
            }

            return redirect()
                ->route('admin.subscriptions.assign.courses.index')
                ->with('success', $message);

        } catch (\Exception $e) {
            DB::rollBack();
            return redirect()
                ->back()
                ->withInput()
                ->with('error', 'حدث خطأ أثناء تعيين الاشتراكات: ' . $e->getMessage());
        }
    }

    /**
     * Show the assign packages to students page
     */
    public function assignPackagesIndex()
    {
        $students = User::where('role', 'student')
            ->orderBy('name')
            ->get(['id', 'name', 'email']);

        $packages = SubscriptionPackage::where('is_active', true)
            ->orderBy('name_ar')
            ->get(['id', 'name_ar', 'price_dzd', 'duration_days']);

        return view('admin.subscriptions.assign-packages', compact('students', 'packages'));
    }

    /**
     * Assign packages to students (bulk assignment)
     */
    public function assignPackages(Request $request)
    {
        $request->validate([
            'students' => 'required|array|min:1',
            'students.*' => 'exists:users,id',
            'packages' => 'required|array|min:1',
            'packages.*' => 'exists:subscription_packages,id',
            'start_date' => 'required|date',
            'subscription_method' => 'required|in:ccp,baridi_mob,code,manual',
            'status' => 'required|in:active,expired,cancelled',
        ]);

        $assignedCount = 0;
        $skippedCount = 0;

        DB::beginTransaction();

        try {
            $startDate = Carbon::parse($request->start_date);

            foreach ($request->students as $studentId) {
                foreach ($request->packages as $packageId) {
                    // Check if subscription already exists
                    $existing = UserSubscription::where('user_id', $studentId)
                        ->where('package_id', $packageId)
                        ->first();

                    if ($existing) {
                        $skippedCount++;
                        continue;
                    }

                    // Get package duration
                    $package = SubscriptionPackage::findOrFail($packageId);
                    $expiresAt = $startDate->copy()->addDays((int) $package->duration_days);

                    // Create subscription
                    UserSubscription::create([
                        'user_id' => $studentId,
                        'course_id' => null,
                        'package_id' => $packageId,
                        'activated_by' => $request->subscription_method === 'code' ? 'code' : 'receipt',
                        'activated_at' => $startDate,
                        'status' => $request->status,
                        'started_at' => $startDate,
                        'expires_at' => $expiresAt,
                    ]);

                    $assignedCount++;
                }
            }

            DB::commit();

            $message = "تم تعيين $assignedCount اشتراك بنجاح.";
            if ($skippedCount > 0) {
                $message .= " تم تخطي $skippedCount اشتراك موجود مسبقاً.";
            }

            return redirect()
                ->route('admin.subscriptions.assign.packages.index')
                ->with('success', $message);

        } catch (\Exception $e) {
            DB::rollBack();
            return redirect()
                ->back()
                ->withInput()
                ->with('error', 'حدث خطأ أثناء تعيين الاشتراكات: ' . $e->getMessage());
        }
    }
}
