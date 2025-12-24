<?php

namespace App\Console\Commands;

use App\Services\SubscriptionService;
use Illuminate\Console\Command;

class ExpireSubscriptionsCommand extends Command
{
    protected $signature = 'subscriptions:expire';
    protected $description = 'Expire subscriptions that have passed their expiration date';

    protected SubscriptionService $subscriptionService;

    public function __construct(SubscriptionService $subscriptionService)
    {
        parent::__construct();
        $this->subscriptionService = $subscriptionService;
    }

    public function handle()
    {
        $this->info('Checking for expired subscriptions...');

        $expiredCount = $this->subscriptionService->expireSubscriptions();

        if ($expiredCount > 0) {
            $this->info("✓ {$expiredCount} subscription(s) have been expired.");
        } else {
            $this->info('No subscriptions to expire.');
        }

        return Command::SUCCESS;
    }
}
