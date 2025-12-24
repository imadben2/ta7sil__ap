<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class DeviceSessionResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'device' => [
                'name' => $this->device_name,
                'type' => $this->device_type,
                'os' => $this->device_os,
                'os_version' => $this->os_version,
                'app_version' => $this->app_version,
                'icon' => $this->getDeviceIcon(),
            ],
            'session' => [
                'ip_address' => $this->ip_address,
                'location' => $this->location,
                'coordinates' => [
                    'latitude' => $this->latitude,
                    'longitude' => $this->longitude,
                ],
                'is_current' => $this->is_current,
                'is_active' => $this->isActive(),
                'last_active_at' => $this->last_active_at?->format('Y-m-d H:i:s'),
                'last_active_human' => $this->getLastActiveForHumans(),
                'expires_at' => $this->expires_at?->format('Y-m-d H:i:s'),
            ],
            'created_at' => $this->created_at->format('Y-m-d H:i:s'),
        ];
    }
}
