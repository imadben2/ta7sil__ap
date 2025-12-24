<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class SubjectContentType extends Model
{
    use HasFactory;

    protected $fillable = [
        'name_ar',
        'slug',
        'icon',
    ];

    /**
     * Get the contents for this type.
     */
    public function contents(): HasMany
    {
        return $this->hasMany(Content::class, 'content_type_id');
    }
}
