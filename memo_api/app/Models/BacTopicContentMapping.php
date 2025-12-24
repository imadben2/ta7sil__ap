<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class BacTopicContentMapping extends Model
{
    use HasFactory;

    protected $table = 'bac_topic_content_mapping';

    public $timestamps = false;

    const CREATED_AT = 'created_at';
    const UPDATED_AT = null;

    protected $fillable = [
        'bac_study_day_topic_id',
        'subject_planner_content_id',
        'relevance_score',
    ];

    protected $casts = [
        'relevance_score' => 'integer',
        'created_at' => 'datetime',
    ];

    /**
     * Get the BAC study day topic.
     */
    public function bacTopic(): BelongsTo
    {
        return $this->belongsTo(BacStudyDayTopic::class, 'bac_study_day_topic_id');
    }

    /**
     * Get the subject planner content.
     */
    public function subjectPlannerContent(): BelongsTo
    {
        return $this->belongsTo(SubjectPlannerContent::class);
    }

    /**
     * Scope a query to filter by high relevance (80+).
     */
    public function scopeHighRelevance($query)
    {
        return $query->where('relevance_score', '>=', 80);
    }

    /**
     * Scope a query to order by relevance score.
     */
    public function scopeByRelevance($query, $direction = 'desc')
    {
        return $query->orderBy('relevance_score', $direction);
    }
}
