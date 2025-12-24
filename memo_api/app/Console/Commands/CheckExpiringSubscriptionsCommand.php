<?php

namespace App\Console\Commands;

use App\Models\UserSubscription;
use App\Notifications\SubscriptionExpiringNotification;
use Illuminate\Console\Command;
use Carbon\Carbon;

class CheckExpiringSubscriptionsCommand extends Command
{
    protected $signature = 'subscriptions:check-expiring {--days=7 : Days before expiration to notify}';
    protected $description = 'Check for subscriptions expiring soon and send notifications';

    public function handle()
    {
        $days = $this->option('days');
        $this->info("Checking for subscriptions expiring in the next {$days} days...");

        $expiringDate = now()->addDays($days);

        // Get subscriptions expiring in the next X days
        $subscriptions = UserSubscription::where('status', 'active')
            ->whereNotNull('expires_at')
            ->whereBetween('expires_at', [now(), $expiringDate])
            ->with(['user', 'course', 'package'])
            ->get();

        if ($subscriptions->isEmpty()) {
            $this->info('✓ No subscriptions expiring soon.');
            return Command::SUCCESS;
        }

        $notifiedCount = 0;

        foreach ($subscriptions as $subscription) {
            $daysRemaining = now()->diffInDays($subscription->expires_at, false);

            // Only notify at 7 days, 3 days, and 1 day milestones
            if (in_array($daysRemaining, [7, 3, 1])) {
                $subscription->user->notify(
                    new SubscriptionExpiringNotification($subscription, $daysRemaining)
                );
                $notifiedCount++;
            }
        }

        $this->info("✓ {$notifiedCount} expiration notification(s) sent.");
        $this->info("Total subscriptions expiring in {$days} days: " . $subscriptions->count());

        return Command::SUCCESS;
    }
}
