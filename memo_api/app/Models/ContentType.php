<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class ContentType extends Model
{
    public $timestamps = false;

    protected $fillable = [
        'name_ar',
        'slug',
        'icon',
    ];

    /**
     * Get the contents for this content type.
     */
    public function contents(): HasMany
    {
        return $this->hasMany(Content::class);
    }
}
