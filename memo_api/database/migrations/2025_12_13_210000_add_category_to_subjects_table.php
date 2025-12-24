<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('subjects', function (Blueprint $table) {
            $table->enum('category', ['HARD_CORE', 'LANGUAGE', 'MEMORIZATION', 'OTHER'])
                  ->default('OTHER')
                  ->after('coefficient')
                  ->comment('Subject category for scheduling algorithm');
        });

        // Update existing subjects based on their names
        // HARD_CORE: رياضيات, فيزياء, علوم
        DB::table('subjects')
            ->whereIn('slug', ['mathematics', 'physics', 'science', 'natural-sciences', 'maths', 'physique', 'sciences'])
            ->orWhere('name_ar', 'like', '%رياضيات%')
            ->orWhere('name_ar', 'like', '%فيزياء%')
            ->orWhere('name_ar', 'like', '%علوم%')
            ->update(['category' => 'HARD_CORE']);

        // LANGUAGE: العربية, الفرنسية, الإنجليزية
        DB::table('subjects')
            ->where(function ($query) {
                $query->whereIn('slug', ['arabic', 'french', 'english', 'arabe', 'francais', 'anglais'])
                    ->orWhere('name_ar', 'like', '%عربية%')
                    ->orWhere('name_ar', 'like', '%فرنسية%')
                    ->orWhere('name_ar', 'like', '%إنجليزية%')
                    ->orWhere('name_ar', 'like', '%انجليزية%')
                    ->orWhere('name_ar', 'like', '%لغة%');
            })
            ->update(['category' => 'LANGUAGE']);

        // MEMORIZATION: إسلامية, تاريخ, جغرافيا, فلسفة
        DB::table('subjects')
            ->where(function ($query) {
                $query->whereIn('slug', ['islamic', 'history', 'geography', 'philosophy', 'histoire', 'geo', 'philo', 'islamique'])
                    ->orWhere('name_ar', 'like', '%إسلامية%')
                    ->orWhere('name_ar', 'like', '%تاريخ%')
                    ->orWhere('name_ar', 'like', '%جغرافيا%')
                    ->orWhere('name_ar', 'like', '%فلسفة%');
            })
            ->update(['category' => 'MEMORIZATION']);
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('subjects', function (Blueprint $table) {
            $table->dropColumn('category');
        });
    }
};
