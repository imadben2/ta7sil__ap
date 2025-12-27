<?php

namespace App\Services;

use App\Models\User;
use App\Models\Course;
use App\Models\SubscriptionPackage;
use App\Models\SubscriptionCode;
use App\Models\UserSubscription;
use App\Models\PaymentReceipt;
use App\Notifications\SubscriptionActivatedNotification;
use App\Notifications\PaymentReceiptStatusNotification;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Notification;
use Illuminate\Http\UploadedFile;
use Carbon\Carbon;

class SubscriptionService
{
    /**
     * Subscribe user to a course using a code
     */
    public function subscribeWithCode(User $user, string $code): UserSubscription
    {
        DB::beginTransaction();

        try {
            // Find and validate code
            $subscriptionCode = SubscriptionCode::where('code', $code)->first();

            if (!$subscriptionCode) {
                throw new \Exception('رمز الاشتراك غير موجود');
            }

            if (!$subscriptionCode->isValid()) {
                throw new \Exception('رمز الاشتراك غير صالح أو منتهي الصلاحية');
            }

            // Handle different code types
            if ($subscriptionCode->code_type === 'single_course') {
                $subscription = $this->createCourseSubscription($user, $subscriptionCode->course, [
                    'subscription_method' => 'code',
                    'subscription_code_id' => $subscriptionCode->id,
                ]);

                $subscriptionCode->incrementUses();
            } elseif ($subscriptionCode->code_type === 'package') {
                $package = $subscriptionCode->package;
                $subscription = $this->createPackageSubscription($user, $package, [
                    'subscription_method' => 'code',
                    'subscription_code_id' => $subscriptionCode->id,
                ]);

                $subscriptionCode->incrementUses();
            } else {
                throw new \Exception('نوع رمز الاشتراك غير مدعوم');
            }

            DB::commit();

            // Send notification
            $user->notify(new SubscriptionActivatedNotification($subscription));

            return $subscription;
        } catch (\Exception $e) {
            DB::rollBack();
            throw $e;
        }
    }

    /**
     * Submit payment receipt for course purchase
     */
    public function submitPaymentReceipt(
        User $user,
        ?Course $course,
        ?SubscriptionPackage $package,
        UploadedFile $receiptImage,
        array $data
    ): PaymentReceipt {
        DB::beginTransaction();

        try {
            // Upload receipt image
            $receiptPath = $receiptImage->store('payment_receipts', 'public');

            $receipt = PaymentReceipt::create([
                'user_id' => $user->id,
                'course_id' => $course?->id,
                'package_id' => $package?->id,
                'receipt_image_url' => $receiptPath,
                'amount_dzd' => $data['amount_dzd'],
                'payment_method' => $data['payment_method'] ?? null,
                'transaction_reference' => $data['transaction_reference'] ?? null,
                'user_notes' => $data['user_notes'] ?? null,
                'status' => 'pending',
                'submitted_at' => now(),
            ]);

            DB::commit();

            return $receipt;
        } catch (\Exception $e) {
            DB::rollBack();
            throw $e;
        }
    }

    /**
     * Approve payment receipt and create subscription
     */
    public function approvePaymentReceipt(PaymentReceipt $receipt, User $admin, ?string $notes = null): UserSubscription
    {
        DB::beginTransaction();

        try {
            // Approve receipt
            $receipt->approve($admin, $notes);

            // Create subscription
            if ($receipt->course_id) {
                $subscription = $this->createCourseSubscription($receipt->user, $receipt->course, [
                    'subscription_method' => 'receipt',
                    'payment_receipt_id' => $receipt->id,
                ]);
            } elseif ($receipt->package_id) {
                $subscription = $this->createPackageSubscription($receipt->user, $receipt->package, [
                    'subscription_method' => 'receipt',
                    'payment_receipt_id' => $receipt->id,
                ]);
            } else {
                throw new \Exception('لم يتم تحديد دورة أو باقة للإيصال');
            }

            DB::commit();

            // Send notifications
            $receipt->user->notify(new PaymentReceiptStatusNotification($receipt, 'approved'));
            $receipt->user->notify(new SubscriptionActivatedNotification($subscription));

            return $subscription;
        } catch (\Exception $e) {
            DB::rollBack();
            throw $e;
        }
    }

    /**
     * Reject payment receipt
     */
    public function rejectPaymentReceipt(PaymentReceipt $receipt, User $admin, string $reason, ?string $notes = null): void
    {
        $receipt->reject($admin, $reason, $notes);

        // Send notification
        $receipt->user->notify(new PaymentReceiptStatusNotification($receipt, 'rejected'));
    }

    /**
     * Create course subscription
     */
    private function createCourseSubscription(User $user, Course $course, array $additionalData = []): UserSubscription
    {
        // Check if user already has active subscription
        $existingSubscription = UserSubscription::where('user_id', $user->id)
            ->where('course_id', $course->id)
            ->where('status', 'active')
            ->first();

        if ($existingSubscription && $existingSubscription->isActive()) {
            throw new \Exception('لديك اشتراك نشط بالفعل في هذه الدورة');
        }

        // Calculate expires_at from course duration_days (default to 365 days if not set)
        $durationDays = $course->duration_days ?? 365;
        $expiresAt = now()->addDays($durationDays);

        $subscription = UserSubscription::create([
            'user_id' => $user->id,
            'course_id' => $course->id,
            'status' => 'active',
            'activated_at' => now(),
            'started_at' => now(),
            'expires_at' => $expiresAt,
            ...$additionalData,
        ]);

        // Increment course enrollment count
        $course->incrementEnrollmentCount();

        // Send notification
        $user->notify(new SubscriptionActivatedNotification($subscription));

        return $subscription;
    }

    /**
     * Create package subscription (subscribes to all courses in package)
     */
    private function createPackageSubscription(User $user, SubscriptionPackage $package, array $additionalData = []): UserSubscription
    {
        $expiresAt = now()->addDays($package->duration_days);

        // Create subscriptions for all courses in package
        $courses = $package->courses;

        foreach ($courses as $course) {
            $existingSubscription = UserSubscription::where('user_id', $user->id)
                ->where('course_id', $course->id)
                ->where('status', 'active')
                ->first();

            if ($existingSubscription && $existingSubscription->isActive()) {
                continue; // Skip if already subscribed
            }

            UserSubscription::create([
                'user_id' => $user->id,
                'course_id' => $course->id,
                'package_id' => $package->id,
                'status' => 'active',
                'activated_at' => now(),
                'started_at' => now(),
                'expires_at' => $expiresAt,
                ...$additionalData,
            ]);

            // Increment course enrollment count
            $course->incrementEnrollmentCount();
        }

        // Return first subscription as representative
        return UserSubscription::where('user_id', $user->id)
            ->where('package_id', $package->id)
            ->first();
    }

    /**
     * Check if user has access to a course
     */
    public function hasAccessToCourse(User $user, Course $course): bool
    {
        // Free courses are accessible to everyone
        if ($course->is_free) {
            return true;
        }

        // Check for active subscription
        return UserSubscription::where('user_id', $user->id)
            ->where('course_id', $course->id)
            ->where('status', 'active')
            ->where(function ($query) {
                $query->whereNull('expires_at')
                    ->orWhere('expires_at', '>', now());
            })
            ->exists();
    }

    /**
     * Get user's active subscriptions
     */
    public function getUserSubscriptions(User $user)
    {
        return UserSubscription::where('user_id', $user->id)
            ->where('status', 'active')
            ->with(['course', 'package'])
            ->get();
    }

    /**
     * Suspend a subscription
     */
    public function suspendSubscription(UserSubscription $subscription): void
    {
        $subscription->suspend();
    }

    /**
     * Reactivate a suspended subscription
     */
    public function reactivateSubscription(UserSubscription $subscription): void
    {
        $subscription->activate();
    }

    /**
     * Extend subscription expiration date
     */
    public function extendSubscription(UserSubscription $subscription, int $days): void
    {
        // If subscription doesn't have expiration, set it from now
        if (!$subscription->expires_at) {
            $subscription->expires_at = now()->addDays($days);
        } else {
            // If expired, extend from current date
            if ($subscription->expires_at < now()) {
                $subscription->expires_at = now()->addDays($days);
            } else {
                // If still active, extend from current expiration date
                $subscription->expires_at = Carbon::parse($subscription->expires_at)->addDays($days);
            }
        }

        // If subscription was expired, reactivate it
        if ($subscription->status === 'expired') {
            $subscription->status = 'active';
        }

        $subscription->save();
    }

    /**
     * Expire subscriptions that have passed their expiration date
     */
    public function expireSubscriptions(): int
    {
        $expiredCount = UserSubscription::where('status', 'active')
            ->whereNotNull('expires_at')
            ->where('expires_at', '<=', now())
            ->update(['status' => 'expired']);

        return $expiredCount;
    }

    /**
     * Create a subscription package
     */
    public function createPackage(array $data): SubscriptionPackage
    {
        DB::beginTransaction();

        try {
            $package = SubscriptionPackage::create([
                'name_ar' => $data['name_ar'],
                'description_ar' => $data['description_ar'],
                'price_dzd' => $data['price_dzd'],
                'duration_days' => $data['duration_days'],
                'is_active' => $data['is_active'] ?? true,
                'is_featured' => $data['is_featured'] ?? false,
                'image_url' => $data['image_url'] ?? null,
                'badge_text' => $data['badge_text'] ?? null,
                'background_color' => $data['background_color'] ?? null,
                'sort_order' => $data['sort_order'] ?? 0,
            ]);

            // Attach courses to package
            if (isset($data['course_ids']) && is_array($data['course_ids'])) {
                $package->courses()->attach($data['course_ids']);
            }

            DB::commit();

            return $package;
        } catch (\Exception $e) {
            DB::rollBack();
            throw $e;
        }
    }

    /**
     * Update a subscription package
     */
    public function updatePackage(SubscriptionPackage $package, array $data): SubscriptionPackage
    {
        DB::beginTransaction();

        try {
            $updateData = [
                'name_ar' => $data['name_ar'] ?? $package->name_ar,
                'description_ar' => $data['description_ar'] ?? $package->description_ar,
                'price_dzd' => $data['price_dzd'] ?? $package->price_dzd,
                'duration_days' => $data['duration_days'] ?? $package->duration_days,
                'is_active' => $data['is_active'] ?? $package->is_active,
                'is_featured' => $data['is_featured'] ?? $package->is_featured,
                'sort_order' => $data['sort_order'] ?? $package->sort_order,
            ];

            // Handle image_url (can be null for removal)
            if (array_key_exists('image_url', $data)) {
                $updateData['image_url'] = $data['image_url'];
            }

            // Handle badge_text
            if (array_key_exists('badge_text', $data)) {
                $updateData['badge_text'] = $data['badge_text'];
            }

            // Handle background_color
            if (array_key_exists('background_color', $data)) {
                $updateData['background_color'] = $data['background_color'];
            }

            $package->update($updateData);

            // Update courses if provided
            if (isset($data['course_ids']) && is_array($data['course_ids'])) {
                $package->courses()->sync($data['course_ids']);
            }

            DB::commit();

            return $package->fresh();
        } catch (\Exception $e) {
            DB::rollBack();
            throw $e;
        }
    }

    /**
     * Delete a subscription package
     */
    public function deletePackage(SubscriptionPackage $package): bool
    {
        DB::beginTransaction();

        try {
            // Detach all courses
            $package->courses()->detach();

            // Delete package
            $deleted = $package->delete();

            DB::commit();

            return $deleted;
        } catch (\Exception $e) {
            DB::rollBack();
            throw $e;
        }
    }
}
