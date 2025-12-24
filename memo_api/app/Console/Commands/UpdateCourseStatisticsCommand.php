<?php

namespace App\Console\Commands;

use App\Models\Course;
use Illuminate\Console\Command;

class UpdateCourseStatisticsCommand extends Command
{
    protected $signature = 'courses:update-statistics {--course= : Specific course ID}';
    protected $description = 'Update course statistics (modules, lessons, reviews, ratings)';

    public function handle()
    {
        if ($courseId = $this->option('course')) {
            // Update specific course
            $course = Course::find($courseId);

            if (!$course) {
                $this->error("Course with ID {$courseId} not found.");
                return Command::FAILURE;
            }

            $this->info("Updating statistics for: {$course->title_ar}");
            $course->updateStatistics();
            $this->info("✓ Statistics updated successfully.");
        } else {
            // Update all courses
            $this->info('Updating statistics for all courses...');

            $courses = Course::all();
            $bar = $this->output->createProgressBar(count($courses));
            $bar->start();

            foreach ($courses as $course) {
                $course->updateStatistics();
                $bar->advance();
            }

            $bar->finish();
            $this->newLine();
            $this->info("✓ Updated statistics for " . count($courses) . " courses.");
        }

        return Command::SUCCESS;
    }
}
