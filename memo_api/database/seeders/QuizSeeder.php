<?php

namespace Database\Seeders;

use App\Models\Quiz;
use App\Models\QuizAttempt;
use App\Models\QuizQuestion;
use App\Models\Subject;
use App\Models\User;
use App\Models\UserQuizPerformance;
use Illuminate\Database\Seeder;

class QuizSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Get admin user
        $admin = User::where('role', 'admin')->first();
        if (!$admin) {
            $admin = User::where('email', 'admin@memo.com')->first();
        }
        if (!$admin) {
            $this->command->error('Admin user not found. Please create an admin user first.');
            return;
        }

        // Get subjects
        $subjects = Subject::take(3)->get();
        if ($subjects->isEmpty()) {
            $this->command->error('No subjects found. Please create subjects first.');
            return;
        }

        $this->command->info('Creating quiz data...');

        // Quiz 1: Comprehensive Quiz with All Question Types
        $quiz1 = Quiz::create([
            'subject_id' => $subjects->first()->id,
            'title_ar' => 'اختبار شامل - جميع أنواع الأسئلة',
            'slug' => 'comprehensive-quiz-all-types',
            'description_ar' => 'اختبار تدريبي يحتوي على جميع أنواع الأسئلة الثمانية',
            'quiz_type' => 'practice',
            'passing_score' => 60,
            'difficulty_level' => 'medium',
            'estimated_duration_minutes' => 20,
            'shuffle_questions' => true,
            'shuffle_answers' => true,
            'show_correct_answers' => true,
            'allow_review' => true,
            'tags' => ['شامل', 'تدريبي', 'متنوع'],
            'is_published' => true,
            'is_premium' => false,
            'created_by' => $admin->id,
        ]);

        // Question 1: Single Choice
        QuizQuestion::create([
            'quiz_id' => $quiz1->id,
            'question_type' => 'mcq_single',
            'question_text_ar' => 'ما هي عاصمة مصر؟',
            'options' => [
                ['text' => 'الإسكندرية'],
                ['text' => 'القاهرة'],
                ['text' => 'الجيزة'],
                ['text' => 'طنطا'],
            ],
            'correct_answer' => ['answer' => 1],
            'points' => 5,
            'question_order' => 1,
            'explanation_ar' => 'القاهرة هي عاصمة جمهورية مصر العربية.',
            'difficulty' => 'easy',
            'tags' => ['جغرافيا', 'عواصم'],
        ]);

        // Question 2: Multiple Choice
        QuizQuestion::create([
            'quiz_id' => $quiz1->id,
            'question_type' => 'mcq_multiple',
            'question_text_ar' => 'اختر الأرقام الزوجية من القائمة التالية:',
            'options' => [
                ['text' => '2'],
                ['text' => '3'],
                ['text' => '4'],
                ['text' => '5'],
                ['text' => '6'],
            ],
            'correct_answer' => ['answers' => [0, 2, 4]],
            'points' => 6,
            'question_order' => 2,
            'explanation_ar' => 'الأرقام الزوجية هي التي تقبل القسمة على 2: (2، 4، 6)',
            'difficulty' => 'easy',
            'tags' => ['رياضيات', 'أرقام'],
        ]);

        // Question 3: True/False
        QuizQuestion::create([
            'quiz_id' => $quiz1->id,
            'question_type' => 'true_false',
            'question_text_ar' => 'الشمس تشرق من الغرب',
            'correct_answer' => ['answer' => false],
            'points' => 3,
            'question_order' => 3,
            'explanation_ar' => 'الشمس تشرق من الشرق وتغرب في الغرب.',
            'difficulty' => 'easy',
            'tags' => ['علوم', 'جغرافيا'],
        ]);

        // Question 4: Matching
        QuizQuestion::create([
            'quiz_id' => $quiz1->id,
            'question_type' => 'matching',
            'question_text_ar' => 'طابق بين الدول وعواصمها:',
            'options' => [
                'left' => ['مصر', 'السعودية', 'الإمارات'],
                'right' => ['القاهرة', 'الرياض', 'أبوظبي'],
            ],
            'correct_answer' => ['pairs' => ['0' => 0, '1' => 1, '2' => 2]],
            'points' => 6,
            'question_order' => 4,
            'explanation_ar' => 'عاصمة مصر القاهرة، والسعودية الرياض، والإمارات أبوظبي.',
            'difficulty' => 'medium',
            'tags' => ['جغرافيا', 'عواصم'],
        ]);

        // Question 5: Ordering
        QuizQuestion::create([
            'quiz_id' => $quiz1->id,
            'question_type' => 'sequence',
            'question_text_ar' => 'رتب الأعداد التالية من الأصغر إلى الأكبر:',
            'options' => ['5', '1', '9', '3'],
            'correct_answer' => ['order' => [1, 3, 0, 2]], // 1, 3, 5, 9
            'points' => 5,
            'question_order' => 5,
            'explanation_ar' => 'الترتيب الصحيح من الأصغر للأكبر: 1، 3، 5، 9',
            'difficulty' => 'easy',
            'tags' => ['رياضيات', 'ترتيب'],
        ]);

        // Question 6: Fill in the Blank
        QuizQuestion::create([
            'quiz_id' => $quiz1->id,
            'question_type' => 'fill_blank',
            'question_text_ar' => 'عاصمة فرنسا هي _____',
            'correct_answer' => ['answer' => 'باريس'],
            'points' => 4,
            'question_order' => 6,
            'explanation_ar' => 'باريس هي عاصمة فرنسا وأكبر مدنها.',
            'difficulty' => 'easy',
            'tags' => ['جغرافيا', 'عواصم'],
        ]);

        // Question 7: Short Answer
        QuizQuestion::create([
            'quiz_id' => $quiz1->id,
            'question_type' => 'short_answer',
            'question_text_ar' => 'اشرح بإيجاز قانون الجاذبية الأرضية.',
            'correct_answer' => [
                'model_answer' => 'قانون الجاذبية الأرضية ينص على أن كل جسم في الكون يجذب جسماً آخر بقوة تتناسب طردياً مع حاصل ضرب كتلتيهما وعكسياً مع مربع المسافة بينهما.',
                'keywords' => ['جاذبية', 'كتلة', 'مسافة', 'قوة'],
            ],
            'points' => 10,
            'question_order' => 7,
            'explanation_ar' => 'قانون الجاذبية اكتشفه إسحاق نيوتن ويعتبر من أهم القوانين الفيزيائية.',
            'difficulty' => 'hard',
            'tags' => ['فيزياء', 'جاذبية'],
        ]);

        // Question 8: Numeric
        QuizQuestion::create([
            'quiz_id' => $quiz1->id,
            'question_type' => 'short_answer',
            'question_text_ar' => 'ما هو ناتج 15 × 8؟',
            'correct_answer' => ['answer' => 120, 'tolerance' => 0],
            'points' => 5,
            'question_order' => 8,
            'explanation_ar' => '15 × 8 = 120',
            'difficulty' => 'easy',
            'tags' => ['رياضيات', 'ضرب'],
        ]);

        $quiz1->updateStatistics();
        $this->command->info('✓ Quiz 1: Comprehensive Quiz created with 8 questions (all types)');

        // Quiz 2: Mathematics Quiz (Timed)
        $quiz2 = Quiz::create([
            'subject_id' => $subjects->first()->id,
            'title_ar' => 'اختبار الرياضيات - موقوت',
            'slug' => 'mathematics-timed-quiz',
            'description_ar' => 'اختبار موقوت في الرياضيات الأساسية',
            'quiz_type' => 'timed',
            'time_limit_minutes' => 10,
            'passing_score' => 70,
            'difficulty_level' => 'easy',
            'estimated_duration_minutes' => 10,
            'shuffle_questions' => true,
            'shuffle_answers' => true,
            'show_correct_answers' => true,
            'allow_review' => true,
            'tags' => ['رياضيات', 'حساب', 'موقوت'],
            'is_published' => true,
            'is_premium' => false,
            'created_by' => $admin->id,
        ]);

        // Math Question 1
        QuizQuestion::create([
            'quiz_id' => $quiz2->id,
            'question_type' => 'mcq_single',
            'question_text_ar' => 'ما هو ناتج 25 + 17؟',
            'options' => [
                ['text' => '40'],
                ['text' => '42'],
                ['text' => '43'],
                ['text' => '45'],
            ],
            'correct_answer' => ['answer' => 1],
            'points' => 5,
            'question_order' => 1,
            'difficulty' => 'easy',
            'tags' => ['جمع'],
        ]);

        // Math Question 2
        QuizQuestion::create([
            'quiz_id' => $quiz2->id,
            'question_type' => 'short_answer',
            'question_text_ar' => 'احسب: 100 - 37 = ؟',
            'correct_answer' => ['answer' => 63, 'tolerance' => 0],
            'points' => 5,
            'question_order' => 2,
            'difficulty' => 'easy',
            'tags' => ['طرح'],
        ]);

        // Math Question 3
        QuizQuestion::create([
            'quiz_id' => $quiz2->id,
            'question_type' => 'true_false',
            'question_text_ar' => '5 × 5 = 25',
            'correct_answer' => ['answer' => true],
            'points' => 3,
            'question_order' => 3,
            'difficulty' => 'easy',
            'tags' => ['ضرب'],
        ]);

        // Math Question 4
        QuizQuestion::create([
            'quiz_id' => $quiz2->id,
            'question_type' => 'mcq_multiple',
            'question_text_ar' => 'اختر الأعداد الأولية من القائمة:',
            'options' => [
                ['text' => '2'],
                ['text' => '4'],
                ['text' => '5'],
                ['text' => '6'],
                ['text' => '7'],
            ],
            'correct_answer' => ['answers' => [0, 2, 4]], // 2, 5, 7
            'points' => 7,
            'question_order' => 4,
            'explanation_ar' => 'الأعداد الأولية هي: 2، 5، 7',
            'difficulty' => 'medium',
            'tags' => ['أعداد أولية'],
        ]);

        // Math Question 5
        QuizQuestion::create([
            'quiz_id' => $quiz2->id,
            'question_type' => 'fill_blank',
            'question_text_ar' => 'مربع العدد 9 يساوي _____',
            'correct_answer' => ['answer' => '81'],
            'points' => 5,
            'question_order' => 5,
            'difficulty' => 'easy',
            'tags' => ['مربعات'],
        ]);

        $quiz2->updateStatistics();
        $this->command->info('✓ Quiz 2: Mathematics Quiz created with 5 questions');

        // Quiz 3: Science Quiz (Exam Mode)
        $quiz3 = Quiz::create([
            'subject_id' => $subjects->count() > 1 ? $subjects[1]->id : $subjects->first()->id,
            'title_ar' => 'اختبار العلوم النهائي',
            'slug' => 'science-final-exam',
            'description_ar' => 'اختبار نهائي في العلوم العامة - لا يمكن المراجعة',
            'quiz_type' => 'exam',
            'time_limit_minutes' => 30,
            'passing_score' => 75,
            'difficulty_level' => 'hard',
            'estimated_duration_minutes' => 30,
            'shuffle_questions' => true,
            'shuffle_answers' => true,
            'show_correct_answers' => false,
            'allow_review' => false,
            'tags' => ['علوم', 'اختبار نهائي', 'صعب'],
            'is_published' => true,
            'is_premium' => true,
            'created_by' => $admin->id,
        ]);

        // Science Question 1
        QuizQuestion::create([
            'quiz_id' => $quiz3->id,
            'question_type' => 'mcq_single',
            'question_text_ar' => 'ما هو العنصر الأكثر وفرة في الكون؟',
            'options' => [
                ['text' => 'الأكسجين'],
                ['text' => 'الهيدروجين'],
                ['text' => 'الكربون'],
                ['text' => 'النيتروجين'],
            ],
            'correct_answer' => ['answer' => 1],
            'points' => 5,
            'question_order' => 1,
            'explanation_ar' => 'الهيدروجين هو العنصر الأكثر وفرة في الكون.',
            'difficulty' => 'medium',
            'tags' => ['كيمياء', 'عناصر'],
        ]);

        // Science Question 2
        QuizQuestion::create([
            'quiz_id' => $quiz3->id,
            'question_type' => 'matching',
            'question_text_ar' => 'طابق بين الحالات الفيزيائية وخصائصها:',
            'options' => [
                'left' => ['الصلبة', 'السائلة', 'الغازية'],
                'right' => ['شكل محدد', 'تأخذ شكل الإناء', 'لا شكل محدد'],
            ],
            'correct_answer' => ['pairs' => ['0' => 0, '1' => 1, '2' => 2]],
            'points' => 6,
            'question_order' => 2,
            'difficulty' => 'medium',
            'tags' => ['فيزياء', 'حالات المادة'],
        ]);

        // Science Question 3
        QuizQuestion::create([
            'quiz_id' => $quiz3->id,
            'question_type' => 'sequence',
            'question_text_ar' => 'رتب طبقات الغلاف الجوي من الأقرب للأرض إلى الأبعد:',
            'options' => ['الستراتوسفير', 'التروبوسفير', 'الميزوسفير', 'الثيرموسفير'],
            'correct_answer' => ['order' => [1, 0, 2, 3]], // التروبوسفير، الستراتوسفير، الميزوسفير، الثيرموسفير
            'points' => 8,
            'question_order' => 3,
            'difficulty' => 'hard',
            'tags' => ['جغرافيا', 'غلاف جوي'],
        ]);

        // Science Question 4
        QuizQuestion::create([
            'quiz_id' => $quiz3->id,
            'question_type' => 'mcq_multiple',
            'question_text_ar' => 'اختر مصادر الطاقة المتجددة:',
            'options' => [
                ['text' => 'الطاقة الشمسية'],
                ['text' => 'النفط'],
                ['text' => 'طاقة الرياح'],
                ['text' => 'الفحم'],
                ['text' => 'الطاقة المائية'],
            ],
            'correct_answer' => ['answers' => [0, 2, 4]],
            'points' => 7,
            'question_order' => 4,
            'explanation_ar' => 'مصادر الطاقة المتجددة هي: الشمسية، الرياح، المائية',
            'difficulty' => 'medium',
            'tags' => ['طاقة', 'بيئة'],
        ]);

        // Science Question 5
        QuizQuestion::create([
            'quiz_id' => $quiz3->id,
            'question_type' => 'true_false',
            'question_text_ar' => 'الماء يتكون من ذرتي هيدروجين وذرة أكسجين',
            'correct_answer' => ['answer' => true],
            'points' => 4,
            'question_order' => 5,
            'explanation_ar' => 'صيغة الماء الكيميائية هي H₂O',
            'difficulty' => 'easy',
            'tags' => ['كيمياء', 'جزيئات'],
        ]);

        // Science Question 6
        QuizQuestion::create([
            'quiz_id' => $quiz3->id,
            'question_type' => 'short_answer',
            'question_text_ar' => 'كم عدد الكروموسومات في الخلية البشرية؟',
            'correct_answer' => ['answer' => 46, 'tolerance' => 0],
            'points' => 5,
            'question_order' => 6,
            'explanation_ar' => 'يحتوي جسم الإنسان على 46 كروموسوم (23 زوجاً)',
            'difficulty' => 'medium',
            'tags' => ['أحياء', 'وراثة'],
        ]);

        $quiz3->updateStatistics();
        $this->command->info('✓ Quiz 3: Science Exam created with 6 questions');

        // Quiz 4: Quick Quiz (Easy)
        $quiz4 = Quiz::create([
            'subject_id' => $subjects->first()->id,
            'title_ar' => 'كويز سريع - أسئلة سهلة',
            'slug' => 'quick-easy-quiz',
            'description_ar' => 'اختبار سريع للمراجعة - 5 دقائق',
            'quiz_type' => 'practice',
            'passing_score' => 50,
            'difficulty_level' => 'easy',
            'estimated_duration_minutes' => 5,
            'shuffle_questions' => false,
            'shuffle_answers' => false,
            'show_correct_answers' => true,
            'allow_review' => true,
            'tags' => ['سريع', 'سهل', 'مراجعة'],
            'is_published' => true,
            'is_premium' => false,
            'created_by' => $admin->id,
        ]);

        // Quick Question 1
        QuizQuestion::create([
            'quiz_id' => $quiz4->id,
            'question_type' => 'true_false',
            'question_text_ar' => 'السماء زرقاء',
            'correct_answer' => ['answer' => true],
            'points' => 2,
            'question_order' => 1,
            'difficulty' => 'easy',
        ]);

        // Quick Question 2
        QuizQuestion::create([
            'quiz_id' => $quiz4->id,
            'question_type' => 'mcq_single',
            'question_text_ar' => 'كم عدد أيام الأسبوع؟',
            'options' => [
                ['text' => '5'],
                ['text' => '6'],
                ['text' => '7'],
                ['text' => '8'],
            ],
            'correct_answer' => ['answer' => 2],
            'points' => 2,
            'question_order' => 2,
            'difficulty' => 'easy',
        ]);

        // Quick Question 3
        QuizQuestion::create([
            'quiz_id' => $quiz4->id,
            'question_type' => 'fill_blank',
            'question_text_ar' => 'أكمل: 1، 2، 3، _____',
            'correct_answer' => ['answer' => '4'],
            'points' => 3,
            'question_order' => 3,
            'difficulty' => 'easy',
        ]);

        $quiz4->updateStatistics();
        $this->command->info('✓ Quiz 4: Quick Quiz created with 3 questions');

        // Summary
        $this->command->newLine();
        $this->command->info('========================================');
        $this->command->info('Quiz Data Seeding Completed Successfully!');
        $this->command->info('========================================');
        $this->command->info('Total Quizzes Created: 4');
        $this->command->info('Total Questions Created: 22');
        $this->command->newLine();
        $this->command->table(
            ['Quiz', 'Type', 'Questions', 'Status'],
            [
                ['اختبار شامل - جميع أنواع الأسئلة', 'Practice', '8 (All Types)', 'Published'],
                ['اختبار الرياضيات - موقوت', 'Timed', '5', 'Published'],
                ['اختبار العلوم النهائي', 'Exam', '6', 'Published (Premium)'],
                ['كويز سريع - أسئلة سهلة', 'Practice', '3', 'Published'],
            ]
        );
        $this->command->newLine();
        $this->command->info('Question Types Distribution:');
        $this->command->info('- Single Choice: 5 questions');
        $this->command->info('- Multiple Choice: 3 questions');
        $this->command->info('- True/False: 4 questions');
        $this->command->info('- Matching: 2 questions');
        $this->command->info('- Ordering: 2 questions');
        $this->command->info('- Fill in the Blank: 3 questions');
        $this->command->info('- Short Answer: 1 question');
        $this->command->info('- Numeric: 3 questions');

        // Create sample quiz attempts for testing
        $this->createSampleAttempts($admin, [$quiz1, $quiz2, $quiz3, $quiz4], $subjects);
    }

    /**
     * Create sample quiz attempts for testing
     */
    protected function createSampleAttempts(User $admin, array $quizzes, $subjects): void
    {
        $this->command->newLine();
        $this->command->info('Creating sample quiz attempts...');

        // Get or create sample users
        $users = User::where('role', '!=', 'admin')->take(5)->get();

        if ($users->isEmpty()) {
            // Create sample users if none exist
            for ($i = 1; $i <= 3; $i++) {
                $users[] = User::create([
                    'name' => "طالب اختباري {$i}",
                    'email' => "student{$i}@test.com",
                    'password' => bcrypt('password'),
                    'role' => 'student',
                    'email_verified_at' => now(),
                ]);
            }
            $users = collect($users);
            $this->command->info('✓ Created 3 sample student users');
        }

        $attemptCount = 0;

        foreach ($users as $user) {
            foreach ($quizzes as $quiz) {
                // Create 1-3 attempts per user per quiz
                $numAttempts = rand(1, 3);

                for ($i = 0; $i < $numAttempts; $i++) {
                    $attempt = $this->createAttempt($user, $quiz);
                    if ($attempt) {
                        $attemptCount++;
                    }
                }
            }
        }

        $this->command->info("✓ Created {$attemptCount} sample quiz attempts");

        // Create user quiz performance records
        $this->createPerformanceRecords($users, $quizzes, $subjects);
    }

    /**
     * Create a single quiz attempt with randomized data
     */
    protected function createAttempt(User $user, Quiz $quiz): ?QuizAttempt
    {
        $questions = $quiz->questions()->get();
        if ($questions->isEmpty()) {
            return null;
        }

        // Randomize attempt status (80% completed, 10% in_progress, 10% abandoned)
        $statusRoll = rand(1, 100);
        if ($statusRoll <= 80) {
            $status = QuizAttempt::STATUS_COMPLETED;
        } elseif ($statusRoll <= 90) {
            $status = QuizAttempt::STATUS_IN_PROGRESS;
        } else {
            $status = QuizAttempt::STATUS_ABANDONED;
        }

        // Generate random seed
        $seed = rand(1, 999999999);

        // Calculate random start time (within last 30 days)
        $startedAt = now()->subDays(rand(0, 30))->subHours(rand(0, 23))->subMinutes(rand(0, 59));

        // Create answers with random correctness
        $answers = [];
        $correctCount = 0;
        $incorrectCount = 0;
        $skippedCount = 0;
        $totalPoints = 0;

        foreach ($questions as $question) {
            // Skip some questions randomly (10% chance)
            if (rand(1, 100) <= 10) {
                $skippedCount++;
                continue;
            }

            // Simulate answer based on difficulty
            $correctChance = match ($question->difficulty ?? 'medium') {
                'easy' => 85,
                'medium' => 65,
                'hard' => 45,
                default => 65,
            };

            $isCorrect = rand(1, 100) <= $correctChance;

            if ($isCorrect) {
                $correctCount++;
                $totalPoints += $question->points;
                $answers[(string) $question->id] = [
                    'answer' => $question->correct_answer['answer'] ?? $question->correct_answer['answers'] ?? true,
                    'time_spent' => rand(10, 120),
                    'answered_at' => $startedAt->copy()->addMinutes(rand(1, 15))->toDateTimeString(),
                ];
            } else {
                $incorrectCount++;
                // Generate wrong answer
                $wrongAnswer = $this->generateWrongAnswer($question);
                $answers[(string) $question->id] = [
                    'answer' => $wrongAnswer,
                    'time_spent' => rand(10, 180),
                    'answered_at' => $startedAt->copy()->addMinutes(rand(1, 15))->toDateTimeString(),
                ];
            }
        }

        $totalQuestions = $questions->count();
        $maxScore = $questions->sum('points');
        $scorePercentage = $maxScore > 0 ? ($totalPoints / $maxScore) * 100 : 0;
        $passed = $scorePercentage >= $quiz->passing_score;

        // Calculate time spent
        $timeSpent = $status === QuizAttempt::STATUS_COMPLETED
            ? rand(60, ($quiz->time_limit_minutes ?? 30) * 60)
            : rand(30, 300);

        $completedAt = $status === QuizAttempt::STATUS_COMPLETED
            ? $startedAt->copy()->addSeconds($timeSpent)
            : null;

        return QuizAttempt::create([
            'quiz_id' => $quiz->id,
            'user_id' => $user->id,
            'started_at' => $startedAt,
            'completed_at' => $completedAt,
            'time_spent_seconds' => $status === QuizAttempt::STATUS_COMPLETED ? $timeSpent : null,
            'status' => $status,
            'total_questions' => $totalQuestions,
            'correct_answers' => $status === QuizAttempt::STATUS_COMPLETED ? $correctCount : null,
            'incorrect_answers' => $status === QuizAttempt::STATUS_COMPLETED ? $incorrectCount : null,
            'skipped_answers' => $status === QuizAttempt::STATUS_COMPLETED ? $skippedCount : null,
            'score_percentage' => $status === QuizAttempt::STATUS_COMPLETED ? round($scorePercentage, 2) : null,
            'total_points' => $status === QuizAttempt::STATUS_COMPLETED ? $totalPoints : null,
            'max_score' => $maxScore,
            'passed' => $status === QuizAttempt::STATUS_COMPLETED ? $passed : null,
            'answers' => $answers,
            'seed' => $seed,
        ]);
    }

    /**
     * Generate a wrong answer for a question
     */
    protected function generateWrongAnswer(QuizQuestion $question): mixed
    {
        return match ($question->question_type) {
            'mcq_single' => $this->getWrongSingleChoice($question),
            'mcq_multiple' => $this->getWrongMultipleChoice($question),
            'true_false' => !($question->correct_answer['answer'] ?? true),
            'matching' => $this->getWrongMatching($question),
            'sequence' => $this->getWrongSequence($question),
            'fill_blank' => 'إجابة خاطئة',
            'short_answer' => 'إجابة غير صحيحة',
            default => 'wrong',
        };
    }

    protected function getWrongSingleChoice(QuizQuestion $question): int
    {
        $correctIndex = $question->correct_answer['answer'] ?? 0;
        $options = $question->options ?? [];
        $wrongIndices = array_filter(array_keys($options), fn($i) => $i !== $correctIndex);
        return !empty($wrongIndices) ? $wrongIndices[array_rand($wrongIndices)] : 0;
    }

    protected function getWrongMultipleChoice(QuizQuestion $question): array
    {
        $correctAnswers = $question->correct_answer['answers'] ?? [];
        $options = $question->options ?? [];
        $allIndices = array_keys($options);

        // Pick random wrong combination
        $wrongAnswers = array_filter($allIndices, fn($i) => !in_array($i, $correctAnswers));
        return !empty($wrongAnswers) ? [array_rand(array_flip($wrongAnswers))] : [0];
    }

    protected function getWrongMatching(QuizQuestion $question): array
    {
        $correctPairs = $question->correct_answer['pairs'] ?? [];
        // Shuffle the pairs incorrectly
        $values = array_values($correctPairs);
        shuffle($values);
        return array_combine(array_keys($correctPairs), $values);
    }

    protected function getWrongSequence(QuizQuestion $question): array
    {
        $correctOrder = $question->correct_answer['order'] ?? [];
        // Reverse or shuffle
        return array_reverse($correctOrder);
    }

    /**
     * Create user quiz performance records
     */
    protected function createPerformanceRecords($users, array $quizzes, $subjects): void
    {
        $this->command->info('Creating user quiz performance records...');

        $performanceCount = 0;

        foreach ($users as $user) {
            foreach ($quizzes as $quiz) {
                // Get completed attempts for this user and quiz
                $attempts = QuizAttempt::where('user_id', $user->id)
                    ->where('quiz_id', $quiz->id)
                    ->where('status', QuizAttempt::STATUS_COMPLETED)
                    ->get();

                if ($attempts->isEmpty()) {
                    continue;
                }

                $totalAttempts = $attempts->count();
                $bestScore = $attempts->max('score_percentage');
                $avgScore = $attempts->avg('score_percentage');
                $totalTime = $attempts->sum('time_spent_seconds');

                // Generate weak concepts
                $weakConcepts = $this->generateWeakConcepts($quiz);

                UserQuizPerformance::updateOrCreate(
                    [
                        'user_id' => $user->id,
                        'quiz_id' => $quiz->id,
                        'subject_id' => $quiz->subject_id,
                    ],
                    [
                        'total_attempts' => $totalAttempts,
                        'best_score' => round($bestScore, 2),
                        'average_score' => round($avgScore, 2),
                        'total_time_spent_minutes' => round($totalTime / 60, 2),
                        'last_attempt_at' => $attempts->max('completed_at'),
                        'weak_concepts' => $weakConcepts,
                    ]
                );

                $performanceCount++;
            }
        }

        $this->command->info("✓ Created {$performanceCount} user quiz performance records");
    }

    /**
     * Generate random weak concepts based on quiz tags
     */
    protected function generateWeakConcepts(Quiz $quiz): array
    {
        $allTags = [];
        foreach ($quiz->questions as $question) {
            $tags = $question->tags ?? [];
            $allTags = array_merge($allTags, $tags);
        }

        $uniqueTags = array_unique($allTags);
        $weakConcepts = [];

        // Randomly select 1-3 tags as weak concepts
        $numWeak = min(count($uniqueTags), rand(1, 3));
        $selectedTags = array_rand(array_flip($uniqueTags), max(1, $numWeak));

        if (!is_array($selectedTags)) {
            $selectedTags = [$selectedTags];
        }

        foreach ($selectedTags as $tag) {
            $weakConcepts[$tag] = [
                'error_rate' => round(rand(50, 80) / 100, 2),
                'last_updated' => now()->toDateTimeString(),
            ];
        }

        return $weakConcepts;
    }
}
