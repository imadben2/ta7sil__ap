<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class BacSubjectBookmark extends Model
{
    protected $fillable = [
        'user_id',
        'bac_subject_id',
        'page_number',
        'notes',
    ];

    protected $casts = [
        'page_number' => 'integer',
    ];

    /**
     * Get the user that owns the bookmark.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the BAC subject that is bookmarked.
     */
    public function bacSubject(): BelongsTo
    {
        return $this->belongsTo(BacSubject::class);
    }
}
