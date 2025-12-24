<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AppSetting;
use Illuminate\Http\JsonResponse;

class AppVersionController extends Controller
{
    /**
     * Check app version requirements
     *
     * @return JsonResponse
     */
    public function check(): JsonResponse
    {
        return response()->json([
            'success' => true,
            'data' => [
                'min_version' => AppSetting::getMinAppVersion(),
                'store_url' => [
                    'android' => 'https://play.google.com/store/apps/details?id=com.memo.app',
                    'ios' => 'https://apps.apple.com/app/memo/id123456789'
                ]
            ]
        ]);
    }
}
