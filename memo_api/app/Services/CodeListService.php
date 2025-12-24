<?php

namespace App\Services;

use App\Models\SubscriptionCodeList;
use App\Models\SubscriptionCode;
use App\Models\Course;
use App\Models\SubscriptionPackage;
use App\Models\User;
use Illuminate\Support\Collection;
use Carbon\Carbon;

class CodeListService
{
    protected CodeGenerationService $codeService;

    public function __construct(CodeGenerationService $codeService)
    {
        $this->codeService = $codeService;
    }

    /**
     * Create a new code list with bulk codes
     *
     * @param string $listName
     * @param string $codeType (single_course, package, general)
     * @param User $creator
     * @param int $quantity
     * @param int $maxUsesPerCode
     * @param Carbon|null $expiresAt
     * @param Course|null $course
     * @param SubscriptionPackage|null $package
     * @return SubscriptionCodeList
     */
    public function createCodeList(
        string $listName,
        string $codeType,
        User $creator,
        int $quantity,
        int $maxUsesPerCode,
        ?Carbon $expiresAt = null,
        ?Course $course = null,
        ?SubscriptionPackage $package = null
    ): SubscriptionCodeList {
        // Create the list record first
        $list = SubscriptionCodeList::create([
            'name' => $listName,
            'code_type' => $codeType,
            'course_id' => $course?->id,
            'package_id' => $package?->id,
            'total_codes' => $quantity,
            'max_uses_per_code' => $maxUsesPerCode,
            'expires_at' => $expiresAt,
            'created_by' => $creator->id,
        ]);

        // Generate codes and associate with list
        $codes = $this->generateCodesForList($list, $course, $package, $creator);

        return $list->fresh(['codes']);
    }

    /**
     * Generate codes for a list
     *
     * @param SubscriptionCodeList $list
     * @param Course|null $course
     * @param SubscriptionPackage|null $package
     * @param User $creator
     * @return Collection
     */
    protected function generateCodesForList(
        SubscriptionCodeList $list,
        ?Course $course,
        ?SubscriptionPackage $package,
        User $creator
    ): Collection {
        $codes = collect();

        for ($i = 0; $i < $list->total_codes; $i++) {
            $code = match ($list->code_type) {
                'single_course' => $this->codeService->generateCourseCode(
                    $course,
                    $creator,
                    $list->max_uses_per_code,
                    $list->expires_at
                ),
                'package' => $this->codeService->generatePackageCode(
                    $package,
                    $creator,
                    $list->max_uses_per_code,
                    $list->expires_at
                ),
                'general' => $this->codeService->generateGeneralCode(
                    $creator,
                    $list->max_uses_per_code,
                    $list->expires_at
                ),
                default => throw new \InvalidArgumentException("Invalid code type: {$list->code_type}")
            };

            // Associate code with list
            $code->update(['list_id' => $list->id]);
            $codes->push($code);
        }

        return $codes;
    }

    /**
     * Get list statistics
     *
     * @param SubscriptionCodeList $list
     * @return array
     */
    public function getListStatistics(SubscriptionCodeList $list): array
    {
        return [
            'id' => $list->id,
            'name' => $list->name,
            'code_type' => $list->code_type,
            'total_codes' => $list->total_codes,
            'used_codes' => $list->used_codes_count,
            'valid_codes' => $list->valid_codes_count,
            'fully_used_codes' => $list->fully_used_codes_count,
            'expired_codes' => $list->expired_codes_count,
            'course' => $list->course?->title_ar,
            'package' => $list->package?->name_ar,
            'max_uses_per_code' => $list->max_uses_per_code,
            'expires_at' => $list->expires_at?->format('Y-m-d H:i:s'),
            'created_at' => $list->created_at->format('Y-m-d H:i:s'),
            'creator' => $list->creator->name,
        ];
    }

    /**
     * Delete a code list (codes will have list_id set to NULL)
     *
     * @param SubscriptionCodeList $list
     * @return bool
     */
    public function deleteList(SubscriptionCodeList $list): bool
    {
        // Note: codes will have list_id set to NULL due to onDelete('set null')
        return $list->delete();
    }

    /**
     * Get all lists with pagination
     *
     * @param int $perPage
     * @return \Illuminate\Contracts\Pagination\LengthAwarePaginator
     */
    public function getAllLists($perPage = 20)
    {
        return SubscriptionCodeList::with(['course', 'package', 'creator'])
            ->withCount(['codes'])
            ->orderBy('created_at', 'desc')
            ->paginate($perPage);
    }

    /**
     * Get a specific list by ID with relationships
     *
     * @param int $listId
     * @return SubscriptionCodeList|null
     */
    public function getListById(int $listId): ?SubscriptionCodeList
    {
        return SubscriptionCodeList::with(['course', 'package', 'creator', 'codes'])
            ->find($listId);
    }
}
