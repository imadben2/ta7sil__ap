<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class BacSession extends Model
{
    public $timestamps = false;

    protected $fillable = [
        'name_ar',
        'slug',
        'session_type',
        'exam_date'
    ];

    protected $casts = [
        'exam_date' => 'date',
    ];

    /**
     * Get all BAC subjects for this session
     */
    public function bacSubjects()
    {
        return $this->hasMany(BacSubject::class);
    }

    /**
     * Scope for main sessions (June)
     */
    public function scopeMain($query)
    {
        return $query->where('session_type', 'main');
    }

    /**
     * Scope for makeup sessions (September)
     */
    public function scopeMakeup($query)
    {
        return $query->where('session_type', 'makeup');
    }

    /**
     * Scope for foreign sessions
     */
    public function scopeForeign($query)
    {
        return $query->where('session_type', 'foreign');
    }
}
