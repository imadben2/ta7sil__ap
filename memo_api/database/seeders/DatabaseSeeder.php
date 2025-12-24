<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        $this->command->info('🌱 Starting database seeding...');
        $this->command->newLine();

        // 1. Academic Structure (Foundation)
        $this->command->info('📚 Seeding academic structure...');
        $this->call(AcademicStructureSeeder::class);
        $this->command->newLine();

        // 2. Content Types
        $this->command->info('📝 Seeding content types...');
        $this->call(ContentTypesSeeder::class);
        $this->command->newLine();

        // 3. BAC Sessions and Years
        $this->command->info('🎓 Seeding BAC sessions and years...');
        $this->call(BacSessionsSeeder::class);
        $this->command->newLine();

        // 4. Achievements System
        $this->command->info('🏆 Seeding achievements...');
        $this->call(AchievementsSeeder::class);
        $this->command->newLine();

        // 5. Promos (Promotional slider)
        $this->command->info('📣 Seeding promotional slides...');
        $this->call(PromosSeeder::class);
        $this->command->newLine();

        $this->command->info('✅ Database seeding completed successfully!');
        $this->command->info('🎉 The MEMO API database is now ready for use.');
    }
}
