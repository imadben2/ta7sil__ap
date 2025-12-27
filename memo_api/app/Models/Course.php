<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Support\Facades\URL;

class Course extends Model
{
    use SoftDeletes;

    protected $fillable = [
        'title_ar',
        'slug',
        'description_ar',
        'short_description_ar',
        'what_you_will_learn',
        'requirements',
        'target_audience',
        'thumbnail_url',
        'trailer_video_url',
        'trailer_video_type',
        'allowed_video_type',
        'subject_id',
        'level',
        'tags',
        'price_dzd',
        'is_free',
        'requires_subscription',
        'duration_days',
        'instructor_name',
        'instructor_bio_ar',
        'instructor_photo_url',
        'total_modules',
        'total_lessons',
        'total_quizzes',
        'total_duration_minutes',
        'is_published',
        'published_at',
        'is_featured',
        'certificate_available',
        'view_count',
        'enrollment_count',
        'average_rating',
        'total_reviews',
        'instructor_email',
        'instructor_phone',
        'whatsapp_number',
        'facebook_url',
        'meta_description_ar',
        'meta_keywords',
    ];

    protected $casts = [
        'tags' => 'array',
        'what_you_will_learn' => 'array',
        'requirements' => 'array',
        'target_audience' => 'array',
        'price_dzd' => 'integer',
        'is_free' => 'boolean',
        'requires_subscription' => 'boolean',
        'total_modules' => 'integer',
        'total_lessons' => 'integer',
        'total_quizzes' => 'integer',
        'total_duration_minutes' => 'integer',
        'is_published' => 'boolean',
        'published_at' => 'datetime',
        'is_featured' => 'boolean',
        'certificate_available' => 'boolean',
        'view_count' => 'integer',
        'enrollment_count' => 'integer',
        'average_rating' => 'decimal:2',
        'total_reviews' => 'integer',
        'deleted_at' => 'datetime',
    ];

    protected $appends = ['thumbnail_full_url'];

    /**
     * Get full URL for thumbnail
     */
    public function getThumbnailFullUrlAttribute(): ?string
    {
        if (!$this->thumbnail_url) {
            return null;
        }

        // If already a full URL, return as-is
        if (str_starts_with($this->thumbnail_url, 'http://') || str_starts_with($this->thumbnail_url, 'https://')) {
            return $this->thumbnail_url;
        }

        return asset('storage/' . $this->thumbnail_url);
    }

    // Relationships
    public function subject(): BelongsTo
    {
        return $this->belongsTo(Subject::class);
    }

    public function modules(): HasMany
    {
        return $this->hasMany(CourseModule::class)->orderBy('order');
    }

    public function subscriptionCodes(): HasMany
    {
        return $this->hasMany(SubscriptionCode::class);
    }

    public function subscriptions(): HasMany
    {
        return $this->hasMany(UserSubscription::class);
    }

    public function reviews(): HasMany
    {
        return $this->hasMany(CourseReview::class);
    }

    public function approvedReviews(): HasMany
    {
        return $this->hasMany(CourseReview::class)->where('is_approved', true);
    }

    public function packages(): BelongsToMany
    {
        return $this->belongsToMany(SubscriptionPackage::class, 'package_courses');
    }

    public function paymentReceipts(): HasMany
    {
        return $this->hasMany(PaymentReceipt::class);
    }

    public function orders(): HasMany
    {
        return $this->hasMany(Order::class);
    }

    public function certificates(): HasMany
    {
        return $this->hasMany(Certificate::class);
    }

    // Helper methods
    public function getSignedVideoUrl(string $videoUrl, int $expiresInMinutes = 60): string
    {
        if ($this->trailer_video_type === 'youtube') {
            return $videoUrl;
        }

        return URL::temporarySignedRoute(
            'course.video',
            now()->addMinutes($expiresInMinutes),
            ['course' => $this->id, 'video' => basename($videoUrl)]
        );
    }

    public function incrementViewCount(): void
    {
        $this->increment('view_count');
    }

    public function incrementEnrollmentCount(): void
    {
        $this->increment('enrollment_count');
    }

    public function updateStatistics(): void
    {
        $this->total_modules = $this->modules()->count();
        $this->total_lessons = CourseLesson::whereIn('course_module_id', $this->modules()->pluck('id'))->count();
        $this->total_quizzes = CourseQuiz::whereIn('course_module_id', $this->modules()->pluck('id'))->count();
        $this->average_rating = $this->approvedReviews()->avg('rating') ?? 0;
        $this->total_reviews = $this->approvedReviews()->count();
        $this->save();
    }
}
