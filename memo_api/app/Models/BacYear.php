<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class BacYear extends Model
{
    public $timestamps = false;

    protected $fillable = [
        'year',
        'is_active'
    ];

    protected $casts = [
        'is_active' => 'boolean',
    ];

    /**
     * Get all BAC subjects for this year
     */
    public function bacSubjects()
    {
        return $this->hasMany(BacSubject::class);
    }

    /**
     * Scope to get only active years
     */
    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }
}
