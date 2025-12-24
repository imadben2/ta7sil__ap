<?php

namespace App\Services;

use App\Models\Course;
use App\Models\SubscriptionPackage;
use App\Models\SubscriptionCode;
use App\Models\User;
use Illuminate\Support\Collection;
use Carbon\Carbon;

class CodeGenerationService
{
    /**
     * Generate a single code for a course
     */
    public function generateCourseCode(
        Course $course,
        User $creator,
        int $maxUses = 1,
        ?Carbon $expiresAt = null
    ): SubscriptionCode {
        return SubscriptionCode::create([
            'code' => SubscriptionCode::generateUniqueCode(),
            'code_type' => 'single_course',
            'course_id' => $course->id,
            'max_uses' => $maxUses,
            'current_uses' => 0,
            'is_active' => true,
            'expires_at' => $expiresAt,
            'created_by' => $creator->id,
        ]);
    }

    /**
     * Generate multiple codes for a course
     */
    public function generateMultipleCourseCodes(
        Course $course,
        User $creator,
        int $quantity,
        int $maxUsesPerCode = 1,
        ?Carbon $expiresAt = null
    ): Collection {
        $codes = collect();

        for ($i = 0; $i < $quantity; $i++) {
            $codes->push($this->generateCourseCode($course, $creator, $maxUsesPerCode, $expiresAt));
        }

        return $codes;
    }

    /**
     * Generate a single code for a package
     */
    public function generatePackageCode(
        SubscriptionPackage $package,
        User $creator,
        int $maxUses = 1,
        ?Carbon $expiresAt = null
    ): SubscriptionCode {
        return SubscriptionCode::create([
            'code' => SubscriptionCode::generateUniqueCode(),
            'code_type' => 'package',
            'package_id' => $package->id,
            'max_uses' => $maxUses,
            'current_uses' => 0,
            'is_active' => true,
            'expires_at' => $expiresAt,
            'created_by' => $creator->id,
        ]);
    }

    /**
     * Generate multiple codes for a package
     */
    public function generateMultiplePackageCodes(
        SubscriptionPackage $package,
        User $creator,
        int $quantity,
        int $maxUsesPerCode = 1,
        ?Carbon $expiresAt = null
    ): Collection {
        $codes = collect();

        for ($i = 0; $i < $quantity; $i++) {
            $codes->push($this->generatePackageCode($package, $creator, $maxUsesPerCode, $expiresAt));
        }

        return $codes;
    }

    /**
     * Generate a general subscription code (can be used for any course/package)
     */
    public function generateGeneralCode(
        User $creator,
        int $maxUses = 1,
        ?Carbon $expiresAt = null
    ): SubscriptionCode {
        return SubscriptionCode::create([
            'code' => SubscriptionCode::generateUniqueCode(),
            'code_type' => 'general',
            'max_uses' => $maxUses,
            'current_uses' => 0,
            'is_active' => true,
            'expires_at' => $expiresAt,
            'created_by' => $creator->id,
        ]);
    }

    /**
     * Generate custom code (user-specified code)
     */
    public function generateCustomCode(
        string $customCode,
        string $codeType,
        User $creator,
        ?Course $course = null,
        ?SubscriptionPackage $package = null,
        int $maxUses = 1,
        ?Carbon $expiresAt = null
    ): SubscriptionCode {
        // Check if code already exists
        if (SubscriptionCode::where('code', strtoupper($customCode))->exists()) {
            throw new \Exception('الرمز موجود بالفعل، يرجى اختيار رمز آخر');
        }

        $data = [
            'code' => strtoupper($customCode),
            'code_type' => $codeType,
            'max_uses' => $maxUses,
            'current_uses' => 0,
            'is_active' => true,
            'expires_at' => $expiresAt,
            'created_by' => $creator->id,
        ];

        if ($course) {
            $data['course_id'] = $course->id;
        }

        if ($package) {
            $data['package_id'] = $package->id;
        }

        return SubscriptionCode::create($data);
    }

    /**
     * Deactivate a code
     */
    public function deactivateCode(SubscriptionCode $code): void
    {
        $code->update(['is_active' => false]);
    }

    /**
     * Activate a code
     */
    public function activateCode(SubscriptionCode $code): void
    {
        $code->update(['is_active' => true]);
    }

    /**
     * Delete a code
     */
    public function deleteCode(SubscriptionCode $code): bool
    {
        return $code->delete();
    }

    /**
     * Extend code expiration date
     */
    public function extendCodeExpiration(SubscriptionCode $code, Carbon $newExpiresAt): SubscriptionCode
    {
        $code->update(['expires_at' => $newExpiresAt]);

        return $code->fresh();
    }

    /**
     * Increase code max uses
     */
    public function increaseCodeMaxUses(SubscriptionCode $code, int $additionalUses): SubscriptionCode
    {
        $code->increment('max_uses', $additionalUses);

        // Reactivate if was deactivated due to reaching max uses
        if ($code->current_uses < $code->max_uses) {
            $code->update(['is_active' => true]);
        }

        return $code->fresh();
    }

    /**
     * Get code statistics
     */
    public function getCodeStatistics(SubscriptionCode $code): array
    {
        return [
            'code' => $code->code,
            'type' => $code->code_type,
            'max_uses' => $code->max_uses,
            'current_uses' => $code->current_uses,
            'remaining_uses' => $code->getRemainingUses(),
            'is_active' => $code->is_active,
            'is_valid' => $code->isValid(),
            'expires_at' => $code->expires_at?->format('Y-m-d H:i:s'),
            'is_expired' => $code->expires_at && $code->expires_at->isPast(),
            'created_at' => $code->created_at->format('Y-m-d H:i:s'),
            'created_by' => $code->creator?->name,
        ];
    }

    /**
     * Get codes by course
     */
    public function getCourseCode(Course $course)
    {
        return SubscriptionCode::where('course_id', $course->id)
            ->with('creator')
            ->orderBy('created_at', 'desc')
            ->get();
    }

    /**
     * Get codes by package
     */
    public function getPackageCodes(SubscriptionPackage $package)
    {
        return SubscriptionCode::where('package_id', $package->id)
            ->with('creator')
            ->orderBy('created_at', 'desc')
            ->get();
    }

    /**
     * Get active codes
     */
    public function getActiveCodes()
    {
        return SubscriptionCode::where('is_active', true)
            ->where(function ($query) {
                $query->whereNull('expires_at')
                    ->orWhere('expires_at', '>', now());
            })
            ->with(['course', 'package', 'creator'])
            ->orderBy('created_at', 'desc')
            ->get();
    }

    /**
     * Get expired codes
     */
    public function getExpiredCodes()
    {
        return SubscriptionCode::where('expires_at', '<=', now())
            ->with(['course', 'package', 'creator'])
            ->orderBy('expires_at', 'desc')
            ->get();
    }

    /**
     * Get fully used codes
     */
    public function getFullyUsedCodes()
    {
        return SubscriptionCode::whereRaw('current_uses >= max_uses')
            ->with(['course', 'package', 'creator'])
            ->orderBy('created_at', 'desc')
            ->get();
    }

    /**
     * Bulk deactivate expired codes
     */
    public function deactivateExpiredCodes(): int
    {
        return SubscriptionCode::where('is_active', true)
            ->where('expires_at', '<=', now())
            ->update(['is_active' => false]);
    }

    /**
     * Export codes to CSV format
     */
    public function exportCodesToCSV(Collection $codes): string
    {
        $csv = "Code,Type,Course/Package,Max Uses,Current Uses,Status,Expires At,Created At\n";

        foreach ($codes as $code) {
            $courseOrPackage = $code->course?->title_ar ?? $code->package?->name_ar ?? 'عام';
            $status = $code->isValid() ? 'صالح' : 'غير صالح';
            $expiresAt = $code->expires_at?->format('Y-m-d H:i') ?? 'لا ينتهي';

            $csv .= sprintf(
                "%s,%s,%s,%d,%d,%s,%s,%s\n",
                $code->code,
                $code->code_type,
                $courseOrPackage,
                $code->max_uses,
                $code->current_uses,
                $status,
                $expiresAt,
                $code->created_at->format('Y-m-d H:i')
            );
        }

        return $csv;
    }

    /**
     * Validate and get code info
     */
    public function validateCode(string $code): array
    {
        $subscriptionCode = SubscriptionCode::where('code', strtoupper($code))->first();

        if (!$subscriptionCode) {
            return [
                'valid' => false,
                'message' => 'رمز الاشتراك غير موجود',
            ];
        }

        if (!$subscriptionCode->isValid()) {
            $reason = !$subscriptionCode->is_active ? 'الرمز غير نشط' :
                     ($subscriptionCode->expires_at && $subscriptionCode->expires_at->isPast() ? 'الرمز منتهي الصلاحية' :
                     'تم استخدام الرمز بالكامل');

            return [
                'valid' => false,
                'message' => $reason,
                'code' => $subscriptionCode,
            ];
        }

        $description = match ($subscriptionCode->code_type) {
            'single_course' => 'دورة: ' . $subscriptionCode->course->title_ar,
            'package' => 'باقة: ' . $subscriptionCode->package->name_ar,
            'general' => 'رمز عام',
            default => 'غير معروف',
        };

        return [
            'valid' => true,
            'message' => 'الرمز صالح',
            'code' => $subscriptionCode,
            'description' => $description,
            'remaining_uses' => $subscriptionCode->getRemainingUses(),
        ];
    }
}
