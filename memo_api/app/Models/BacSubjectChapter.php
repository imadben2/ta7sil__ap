<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class BacSubjectChapter extends Model
{
    protected $fillable = [
        'bac_subject_id',
        'title_ar',
        'order'
    ];

    protected $casts = [
        'order' => 'integer',
    ];

    /**
     * Get the BAC subject
     */
    public function bacSubject()
    {
        return $this->belongsTo(BacSubject::class);
    }
}
