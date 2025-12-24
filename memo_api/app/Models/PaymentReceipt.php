<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Support\Facades\Storage;

class PaymentReceipt extends Model
{
    protected $fillable = [
        'user_id',
        'course_id',
        'package_id',
        'receipt_image_url',
        'amount_dzd',
        'payment_method',
        'transaction_reference',
        'user_notes',
        'status',
        'submitted_at',
        'reviewed_at',
        'reviewed_by',
        'admin_notes',
        'rejection_reason',
    ];

    protected $casts = [
        'user_id' => 'integer',
        'course_id' => 'integer',
        'package_id' => 'integer',
        'amount_dzd' => 'integer',
        'submitted_at' => 'datetime',
        'reviewed_at' => 'datetime',
        'reviewed_by' => 'integer',
    ];

    protected $appends = ['receipt_image_full_url'];

    /**
     * Get the full URL for the receipt image
     */
    public function getReceiptImageFullUrlAttribute(): ?string
    {
        if (!$this->receipt_image_url) {
            return null;
        }

        return Storage::disk('public')->url($this->receipt_image_url);
    }

    // Relationships
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function course(): BelongsTo
    {
        return $this->belongsTo(Course::class);
    }

    public function package(): BelongsTo
    {
        return $this->belongsTo(SubscriptionPackage::class);
    }

    public function reviewer(): BelongsTo
    {
        return $this->belongsTo(User::class, 'reviewed_by');
    }

    public function subscription(): HasOne
    {
        return $this->hasOne(UserSubscription::class, 'receipt_id');
    }

    // Helper methods
    public function isPending(): bool
    {
        return $this->status === 'pending';
    }

    public function isApproved(): bool
    {
        return $this->status === 'approved';
    }

    public function isRejected(): bool
    {
        return $this->status === 'rejected';
    }

    public function approve(User $admin, ?string $notes = null): void
    {
        $this->status = 'approved';
        $this->reviewed_at = now();
        $this->reviewed_by = $admin->id;
        $this->admin_notes = $notes;
        $this->save();
    }

    public function reject(User $admin, string $reason, ?string $notes = null): void
    {
        $this->status = 'rejected';
        $this->reviewed_at = now();
        $this->reviewed_by = $admin->id;
        $this->rejection_reason = $reason;
        $this->admin_notes = $notes;
        $this->save();
    }

    public function getStatusBadgeClass(): string
    {
        return match ($this->status) {
            'pending' => 'bg-yellow-100 text-yellow-800',
            'approved' => 'bg-green-100 text-green-800',
            'rejected' => 'bg-red-100 text-red-800',
            default => 'bg-gray-100 text-gray-800',
        };
    }

    public function getStatusText(): string
    {
        return match ($this->status) {
            'pending' => 'قيد المراجعة',
            'approved' => 'مقبول',
            'rejected' => 'مرفوض',
            default => 'غير معروف',
        };
    }
}
