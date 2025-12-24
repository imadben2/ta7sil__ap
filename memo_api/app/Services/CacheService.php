<?php

namespace App\Services;

use Illuminate\Support\Facades\Cache;

/**
 * Centralized cache service with intelligent caching strategy
 * Based on performance optimization plan (12-performance-cache.md)
 */
class CacheService
{
    // Cache TTL constants (in seconds)
    const TTL_STATIC = 604800;      // 1 week - Academic structure, subjects
    const TTL_DYNAMIC = 900;        // 15 minutes - User profiles, preferences
    const TTL_FREQUENT = 300;       // 5 minutes - Daily sessions, notifications
    const TTL_HEAVY = 3600;         // 1 hour - Heavy calculations, analytics

    /**
     * Get or cache academic structure (phases, years, streams)
     */
    public static function getAcademicStructure()
    {
        return Cache::remember('academic.structure', self::TTL_STATIC, function () {
            return \App\Models\AcademicPhase::with(['years.streams'])->get();
        });
    }

    /**
     * Get or cache all subjects
     */
    public static function getSubjects()
    {
        return Cache::remember('subjects.all', self::TTL_STATIC, function () {
            return \App\Models\Subject::with('contentTypes')->get();
        });
    }

    /**
     * Get or cache subject by ID
     */
    public static function getSubject($subjectId)
    {
        return Cache::remember("subject.{$subjectId}", self::TTL_STATIC, function () use ($subjectId) {
            return \App\Models\Subject::with('contentTypes', 'academicPhase')->find($subjectId);
        });
    }

    /**
     * Get or cache user profile with academic info
     */
    public static function getUserProfile($userId)
    {
        return Cache::remember("user.{$userId}.profile", self::TTL_DYNAMIC, function () use ($userId) {
            return \App\Models\User::with([
                'academicProfile.academicYear.academicPhase',
                'academicProfile.academicStream'
            ])->find($userId);
        });
    }

    /**
     * Get or cache user preferences
     */
    public static function getUserPreferences($userId)
    {
        return Cache::remember("user.{$userId}.preferences", self::TTL_DYNAMIC, function () use ($userId) {
            $user = \App\Models\User::find($userId);
            return $user ? $user->settings : [];
        });
    }

    /**
     * Get or cache user's today sessions
     */
    public static function getUserTodaySessions($userId)
    {
        return Cache::remember("user.{$userId}.sessions.today", self::TTL_FREQUENT, function () use ($userId) {
            return \App\Models\StudySession::with('subject', 'contents')
                ->whereDate('scheduled_date', today())
                ->where('user_id', $userId)
                ->orderBy('start_time')
                ->get();
        });
    }

    /**
     * Get or cache user's unread notifications count
     */
    public static function getUserUnreadNotificationsCount($userId)
    {
        return Cache::remember("user.{$userId}.notifications.unread", self::TTL_FREQUENT, function () use ($userId) {
            // Placeholder - implement when notifications table exists
            return 0;
        });
    }

    /**
     * Get or cache dashboard stats
     */
    public static function getDashboardStats()
    {
        return Cache::remember('dashboard.stats', self::TTL_FREQUENT, function () {
            return [
                'total_users' => \App\Models\User::count(),
                'active_users' => \App\Models\User::where('is_active', true)->count(),
                'total_subjects' => \App\Models\Subject::count(),
                'total_contents' => \App\Models\Content::count(),
                'published_contents' => \App\Models\Content::where('is_published', true)->count(),
            ];
        });
    }

    /**
     * Get or cache subject contents (for listing)
     */
    public static function getSubjectContents($subjectId)
    {
        return Cache::remember("subject.{$subjectId}.contents", self::TTL_DYNAMIC, function () use ($subjectId) {
            return \App\Models\Content::with('contentType', 'chapter', 'tags')
                ->where('subject_id', $subjectId)
                ->where('is_published', true)
                ->orderBy('created_at', 'desc')
                ->get();
        });
    }

    /**
     * Get or cache course with modules and lessons
     */
    public static function getCourse($courseId)
    {
        return Cache::remember("course.{$courseId}.full", self::TTL_DYNAMIC, function () use ($courseId) {
            return \App\Models\Course::with([
                'subject',
                'modules.lessons.attachments',
                'instructor'
            ])->find($courseId);
        });
    }

    /**
     * Invalidate user-related caches
     */
    public static function invalidateUserCache($userId)
    {
        Cache::forget("user.{$userId}.profile");
        Cache::forget("user.{$userId}.preferences");
        Cache::forget("user.{$userId}.sessions.today");
        Cache::forget("user.{$userId}.notifications.unread");
        Cache::forget("user.{$userId}.stats");
    }

    /**
     * Invalidate subject-related caches
     */
    public static function invalidateSubjectCache($subjectId)
    {
        Cache::forget("subject.{$subjectId}");
        Cache::forget("subject.{$subjectId}.contents");
        Cache::forget('subjects.all');
    }

    /**
     * Invalidate content-related caches
     */
    public static function invalidateContentCache($contentId, $subjectId = null)
    {
        Cache::forget("content.{$contentId}");

        if ($subjectId) {
            Cache::forget("subject.{$subjectId}.contents");
        }
    }

    /**
     * Invalidate course-related caches
     */
    public static function invalidateCourseCache($courseId)
    {
        Cache::forget("course.{$courseId}.full");
        Cache::forget("course.{$courseId}.modules");
        Cache::forget("course.{$courseId}.stats");
    }

    /**
     * Invalidate academic structure cache
     */
    public static function invalidateAcademicStructureCache()
    {
        Cache::forget('academic.structure');
    }

    /**
     * Invalidate dashboard stats
     */
    public static function invalidateDashboardStats()
    {
        Cache::forget('dashboard.stats');
    }

    /**
     * Clear all caches (use with caution)
     */
    public static function clearAll()
    {
        Cache::flush();
    }

    /**
     * Get cache statistics (if Redis is used)
     */
    public static function getStats()
    {
        if (Cache::getStore() instanceof \Illuminate\Cache\RedisStore) {
            try {
                $redis = Cache::getRedis();
                return [
                    'driver' => 'redis',
                    'keys_count' => count($redis->keys('*')),
                    'memory_usage' => $redis->info('memory')['used_memory_human'] ?? 'N/A',
                ];
            } catch (\Exception $e) {
                return ['driver' => 'redis', 'error' => $e->getMessage()];
            }
        }

        return [
            'driver' => config('cache.default'),
            'message' => 'Stats only available for Redis driver'
        ];
    }
}
