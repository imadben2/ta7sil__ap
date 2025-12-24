<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class AdminUserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Create default admin user
        User::updateOrCreate(
            ['email' => 'admin@memo.dz'],
            [
                'name' => 'مدير النظام',
                'email' => 'admin@memo.dz',
                'password' => Hash::make('admin123'),
                'is_admin' => true,
                'is_active' => true,
                'email_verified_at' => now(),
            ]
        );

        $this->command->info('✅ Admin user created successfully!');
        $this->command->info('📧 Email: admin@memo.dz');
        $this->command->info('🔑 Password: admin123');
        $this->command->warn('⚠️  Please change the password in production!');
    }
}
