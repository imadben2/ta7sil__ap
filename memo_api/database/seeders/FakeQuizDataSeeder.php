<?php

namespace Database\Seeders;

use App\Models\Quiz;
use App\Models\QuizQuestion;
use App\Models\Subject;
use App\Models\User;
use App\Models\ContentChapter;
use Illuminate\Database\Seeder;
use Illuminate\Support\Str;

class FakeQuizDataSeeder extends Seeder
{
    /**
     * Run the database seeds.
     * Creates fake quiz data for year_id=12 and stream_id=1
     */
    public function run(): void
    {
        $admin = User::where('role', 'admin')->first()
                ?? User::where('email', 'admin@memo.com')->first()
                ?? User::first();

        if (!$admin) {
            $this->command->error('No user found. Please create a user first.');
            return;
        }

        // Get subjects for year_id=12 and stream_id=1
        $subjects = Subject::where('academic_year_id', 12)
            ->where('academic_stream_id', 1)
            ->get();

        if ($subjects->isEmpty()) {
            $this->command->error('No subjects found for year_id=12 and stream_id=1.');
            return;
        }

        $this->command->info('Creating fake quiz data for BAC year (year_id=12, stream_id=1)...');
        $this->command->info('Found ' . $subjects->count() . ' subjects.');

        $quizzesCreated = 0;
        $questionsCreated = 0;

        foreach ($subjects as $subject) {
            // Create 2-4 quizzes per subject
            $numQuizzes = rand(2, 4);

            for ($q = 1; $q <= $numQuizzes; $q++) {
                $quiz = $this->createQuizForSubject($subject, $admin, $q);
                $quizzesCreated++;

                // Create 5-10 questions per quiz
                $numQuestions = rand(5, 10);
                for ($i = 1; $i <= $numQuestions; $i++) {
                    $this->createQuestion($quiz, $i, $subject);
                    $questionsCreated++;
                }

                $quiz->updateStatistics();
            }

            $this->command->info("✓ Created quizzes for: {$subject->name_ar}");
        }

        $this->command->newLine();
        $this->command->info('========================================');
        $this->command->info('Fake Quiz Data Seeding Completed!');
        $this->command->info('========================================');
        $this->command->info("Total Quizzes Created: {$quizzesCreated}");
        $this->command->info("Total Questions Created: {$questionsCreated}");
    }

    protected function createQuizForSubject(Subject $subject, User $admin, int $index): Quiz
    {
        $types = ['practice', 'timed', 'exam'];
        $difficulties = ['easy', 'medium', 'hard'];
        $type = $types[array_rand($types)];
        $difficulty = $difficulties[array_rand($difficulties)];

        $titles = [
            'الرياضيات' => ['اختبار في الدوال', 'اختبار في الاحتمالات', 'اختبار في المتتاليات', 'اختبار شامل في الرياضيات'],
            'الفيزياء' => ['اختبار في الميكانيك', 'اختبار في الكهرباء', 'اختبار في البصريات', 'اختبار شامل في الفيزياء'],
            'علوم الطبيعة والحياة' => ['اختبار في الوراثة', 'اختبار في المناعة', 'اختبار في التكاثر', 'اختبار شامل في العلوم'],
            'اللغة العربية' => ['اختبار في النحو', 'اختبار في البلاغة', 'اختبار في الأدب', 'اختبار شامل في اللغة العربية'],
            'اللغة الفرنسية' => ['Test de grammaire', 'Test de vocabulaire', 'Test de compréhension', 'Test complet'],
            'اللغة الإنجليزية' => ['Grammar Test', 'Vocabulary Test', 'Reading Comprehension', 'Full English Test'],
            'الفلسفة' => ['اختبار في المنطق', 'اختبار في الأخلاق', 'اختبار في الميتافيزيقا', 'اختبار شامل في الفلسفة'],
            'التاريخ والجغرافيا' => ['اختبار في التاريخ المعاصر', 'اختبار في الجغرافيا', 'اختبار شامل', 'اختبار في الخرائط'],
            'العلوم الإسلامية' => ['اختبار في العقيدة', 'اختبار في الفقه', 'اختبار في السيرة', 'اختبار شامل'],
        ];

        $subjectTitles = $titles[$subject->name_ar] ?? ['اختبار ' . $index, 'تمرين ' . $index, 'كويز ' . $index, 'اختبار شامل'];
        $title = $subjectTitles[min($index - 1, count($subjectTitles) - 1)];

        $timeLimits = [
            'practice' => null,
            'timed' => [15, 20, 30, 45][array_rand([15, 20, 30, 45])],
            'exam' => [45, 60, 90, 120][array_rand([45, 60, 90, 120])],
        ];

        return Quiz::create([
            'subject_id' => $subject->id,
            'chapter_id' => null,
            'title_ar' => $title,
            'slug' => Str::slug($title . '-' . $subject->id . '-' . $index . '-' . time()),
            'description_ar' => $this->getDescription($subject, $type, $difficulty),
            'quiz_type' => $type,
            'time_limit_minutes' => $timeLimits[$type],
            'passing_score' => [50, 60, 70][array_rand([50, 60, 70])],
            'difficulty_level' => $difficulty,
            'estimated_duration_minutes' => rand(10, 45),
            'shuffle_questions' => rand(0, 1) === 1,
            'shuffle_answers' => rand(0, 1) === 1,
            'show_correct_answers' => $type !== 'exam',
            'allow_review' => $type !== 'exam',
            'tags' => $this->getTags($subject, $difficulty),
            'total_questions' => 0,
            'average_score' => 0,
            'total_attempts' => 0,
            'is_published' => true,
            'is_premium' => rand(0, 10) > 7, // 30% premium
            'created_by' => $admin->id,
        ]);
    }

    protected function getDescription(Subject $subject, string $type, string $difficulty): string
    {
        $typeNames = [
            'practice' => 'تدريبي',
            'timed' => 'موقوت',
            'exam' => 'امتحان',
        ];
        $diffNames = [
            'easy' => 'سهل',
            'medium' => 'متوسط',
            'hard' => 'صعب',
        ];

        return "اختبار {$typeNames[$type]} في مادة {$subject->name_ar} - المستوى: {$diffNames[$difficulty]}. يحتوي على أسئلة متنوعة لتقييم مستواك.";
    }

    protected function getTags(Subject $subject, string $difficulty): array
    {
        $baseTags = ['بكالوريا', '3AS', $subject->name_ar];

        $additionalTags = [
            'easy' => ['سهل', 'مراجعة', 'أساسيات'],
            'medium' => ['متوسط', 'تطبيق', 'فهم'],
            'hard' => ['صعب', 'تحدي', 'متقدم'],
        ];

        return array_merge($baseTags, [$additionalTags[$difficulty][array_rand($additionalTags[$difficulty])]]);
    }

    protected function createQuestion(Quiz $quiz, int $order, Subject $subject): QuizQuestion
    {
        $types = ['mcq_single', 'mcq_multiple', 'true_false', 'fill_blank'];
        $type = $types[array_rand($types)];
        $difficulty = ['easy', 'medium', 'hard'][array_rand(['easy', 'medium', 'hard'])];

        return match($type) {
            'mcq_single' => $this->createMcqSingle($quiz, $order, $subject, $difficulty),
            'mcq_multiple' => $this->createMcqMultiple($quiz, $order, $subject, $difficulty),
            'true_false' => $this->createTrueFalse($quiz, $order, $subject, $difficulty),
            'fill_blank' => $this->createFillBlank($quiz, $order, $subject, $difficulty),
            default => $this->createMcqSingle($quiz, $order, $subject, $difficulty),
        };
    }

    protected function createMcqSingle(Quiz $quiz, int $order, Subject $subject, string $difficulty): QuizQuestion
    {
        $questions = $this->getMcqQuestions($subject->name_ar);
        $q = $questions[array_rand($questions)];

        return QuizQuestion::create([
            'quiz_id' => $quiz->id,
            'question_type' => 'mcq_single',
            'question_text_ar' => $q['question'],
            'options' => array_map(fn($o) => ['text' => $o], $q['options']),
            'correct_answer' => ['answer' => $q['correct']],
            'points' => [3, 4, 5, 6][array_rand([3, 4, 5, 6])],
            'question_order' => $order,
            'explanation_ar' => $q['explanation'] ?? 'الإجابة الصحيحة هي: ' . $q['options'][$q['correct']],
            'difficulty' => $difficulty,
            'tags' => [$subject->name_ar, 'اختيار من متعدد'],
        ]);
    }

    protected function createMcqMultiple(Quiz $quiz, int $order, Subject $subject, string $difficulty): QuizQuestion
    {
        $questions = $this->getMcqMultipleQuestions($subject->name_ar);
        $q = $questions[array_rand($questions)];

        return QuizQuestion::create([
            'quiz_id' => $quiz->id,
            'question_type' => 'mcq_multiple',
            'question_text_ar' => $q['question'],
            'options' => array_map(fn($o) => ['text' => $o], $q['options']),
            'correct_answer' => ['answers' => $q['correct']],
            'points' => [5, 6, 7, 8][array_rand([5, 6, 7, 8])],
            'question_order' => $order,
            'explanation_ar' => $q['explanation'] ?? 'الإجابات الصحيحة متعددة.',
            'difficulty' => $difficulty,
            'tags' => [$subject->name_ar, 'اختيار متعدد'],
        ]);
    }

    protected function createTrueFalse(Quiz $quiz, int $order, Subject $subject, string $difficulty): QuizQuestion
    {
        $questions = $this->getTrueFalseQuestions($subject->name_ar);
        $q = $questions[array_rand($questions)];

        return QuizQuestion::create([
            'quiz_id' => $quiz->id,
            'question_type' => 'true_false',
            'question_text_ar' => $q['question'],
            'correct_answer' => ['answer' => $q['correct']],
            'points' => [2, 3, 4][array_rand([2, 3, 4])],
            'question_order' => $order,
            'explanation_ar' => $q['explanation'] ?? ($q['correct'] ? 'العبارة صحيحة.' : 'العبارة خاطئة.'),
            'difficulty' => $difficulty,
            'tags' => [$subject->name_ar, 'صح أو خطأ'],
        ]);
    }

    protected function createFillBlank(Quiz $quiz, int $order, Subject $subject, string $difficulty): QuizQuestion
    {
        $questions = $this->getFillBlankQuestions($subject->name_ar);
        $q = $questions[array_rand($questions)];

        return QuizQuestion::create([
            'quiz_id' => $quiz->id,
            'question_type' => 'fill_blank',
            'question_text_ar' => $q['question'],
            'correct_answer' => ['answer' => $q['correct']],
            'points' => [4, 5, 6][array_rand([4, 5, 6])],
            'question_order' => $order,
            'explanation_ar' => $q['explanation'] ?? 'الإجابة الصحيحة هي: ' . $q['correct'],
            'difficulty' => $difficulty,
            'tags' => [$subject->name_ar, 'أكمل الفراغ'],
        ]);
    }

    protected function getMcqQuestions(string $subject): array
    {
        $questions = [
            'الرياضيات' => [
                ['question' => 'ما هي مشتقة الدالة f(x) = x²؟', 'options' => ['2x', 'x', '2', 'x²'], 'correct' => 0, 'explanation' => 'مشتقة x² هي 2x حسب قاعدة الأس.'],
                ['question' => 'ما هو نهاية (sin x)/x عندما x→0؟', 'options' => ['1', '0', '∞', 'غير موجودة'], 'correct' => 0, 'explanation' => 'هذه نهاية شهيرة تساوي 1.'],
                ['question' => 'ما هو تكامل ∫cos(x)dx؟', 'options' => ['sin(x)+C', '-sin(x)+C', 'cos(x)+C', '-cos(x)+C'], 'correct' => 0],
                ['question' => 'إذا كان det(A) = 0، فإن المصفوفة A:', 'options' => ['غير قابلة للقلب', 'قابلة للقلب', 'متماثلة', 'وحدوية'], 'correct' => 0],
                ['question' => 'ما هو الحد العام للمتتالية الحسابية؟', 'options' => ['Un = U1 + (n-1)r', 'Un = U1 × r^n', 'Un = n!', 'Un = 2n'], 'correct' => 0],
            ],
            'الفيزياء' => [
                ['question' => 'ما هي وحدة قياس القوة في النظام الدولي؟', 'options' => ['نيوتن', 'جول', 'واط', 'باسكال'], 'correct' => 0, 'explanation' => 'النيوتن هو وحدة القوة.'],
                ['question' => 'ما هو قانون نيوتن الثاني؟', 'options' => ['F = ma', 'F = mv', 'F = mg', 'F = mgh'], 'correct' => 0],
                ['question' => 'ما هي سرعة الضوء في الفراغ؟', 'options' => ['3×10⁸ m/s', '3×10⁶ m/s', '3×10¹⁰ m/s', '3×10⁴ m/s'], 'correct' => 0],
                ['question' => 'ما هو قانون أوم؟', 'options' => ['U = R×I', 'P = U×I', 'E = mc²', 'F = qE'], 'correct' => 0],
                ['question' => 'ما هي وحدة الطاقة؟', 'options' => ['جول', 'نيوتن', 'واط', 'أمبير'], 'correct' => 0],
            ],
            'علوم الطبيعة والحياة' => [
                ['question' => 'أين يتم التركيب الضوئي في النبات؟', 'options' => ['البلاستيدات الخضراء', 'الميتوكوندريا', 'النواة', 'الريبوسومات'], 'correct' => 0],
                ['question' => 'ما هو الحمض النووي المسؤول عن نقل المعلومات الوراثية؟', 'options' => ['DNA', 'RNA', 'ATP', 'ADP'], 'correct' => 0],
                ['question' => 'كم عدد الكروموسومات في الخلية البشرية؟', 'options' => ['46', '23', '48', '44'], 'correct' => 0],
                ['question' => 'ما هو العضو المسؤول عن تنقية الدم؟', 'options' => ['الكلية', 'القلب', 'الرئة', 'الكبد'], 'correct' => 0],
                ['question' => 'ما هي المرحلة الأولى من الانقسام المنصف؟', 'options' => ['الطور التمهيدي I', 'الطور الاستوائي I', 'الطور الانفصالي I', 'الطور النهائي I'], 'correct' => 0],
            ],
            'اللغة العربية' => [
                ['question' => 'ما إعراب كلمة "محمد" في جملة: جاء محمدٌ؟', 'options' => ['فاعل مرفوع', 'مفعول به منصوب', 'مبتدأ مرفوع', 'خبر مرفوع'], 'correct' => 0],
                ['question' => 'ما هو جمع كلمة "كتاب"؟', 'options' => ['كتب', 'كتابات', 'كتبة', 'كاتبون'], 'correct' => 0],
                ['question' => 'ما نوع الاستعارة في "البحر يبتسم"؟', 'options' => ['مكنية', 'تصريحية', 'تمثيلية', 'عنادية'], 'correct' => 0],
                ['question' => 'ما هو البحر الشعري لـ "مستفعلن مستفعلن مستفعلن"؟', 'options' => ['الرجز', 'الكامل', 'الوافر', 'البسيط'], 'correct' => 0],
                ['question' => 'ما علامة نصب جمع المؤنث السالم؟', 'options' => ['الكسرة', 'الفتحة', 'الياء', 'الألف'], 'correct' => 0],
            ],
            'اللغة الفرنسية' => [
                ['question' => 'Quel est le pluriel de "cheval"?', 'options' => ['chevaux', 'chevals', 'chevales', 'chevauxs'], 'correct' => 0],
                ['question' => 'Quelle est la forme passive de "Le chat mange la souris"?', 'options' => ['La souris est mangée par le chat', 'La souris mange le chat', 'Le chat est mangé', 'La souris a mangé'], 'correct' => 0],
                ['question' => 'Quel temps utilise-t-on pour une action passée achevée?', 'options' => ['Passé composé', 'Imparfait', 'Présent', 'Futur'], 'correct' => 0],
                ['question' => 'Le contraire de "grand" est:', 'options' => ['petit', 'gros', 'large', 'haut'], 'correct' => 0],
                ['question' => 'Complétez: "Il ___ à Paris depuis 5 ans"', 'options' => ['habite', 'habitait', 'a habité', 'habitera'], 'correct' => 0],
            ],
            'اللغة الإنجليزية' => [
                ['question' => 'What is the past tense of "go"?', 'options' => ['went', 'goed', 'gone', 'going'], 'correct' => 0],
                ['question' => 'Which sentence is correct?', 'options' => ['She has been working', 'She have been working', 'She has be working', 'She have be working'], 'correct' => 0],
                ['question' => 'The opposite of "ancient" is:', 'options' => ['modern', 'old', 'antique', 'historical'], 'correct' => 0],
                ['question' => 'Choose the correct sentence:', 'options' => ['If I were you, I would study', 'If I was you, I will study', 'If I am you, I would study', 'If I be you, I will study'], 'correct' => 0],
                ['question' => '"Despite" is followed by:', 'options' => ['a noun/gerund', 'a verb', 'an adjective', 'a clause with subject'], 'correct' => 0],
            ],
            'الفلسفة' => [
                ['question' => 'من هو مؤسس الفلسفة الوضعية؟', 'options' => ['أوغست كونت', 'ديكارت', 'كانط', 'هيغل'], 'correct' => 0],
                ['question' => 'ما هو مبدأ السببية؟', 'options' => ['لكل علة معلول', 'كل شيء نسبي', 'الإنسان حر', 'المعرفة فطرية'], 'correct' => 0],
                ['question' => 'من قال "أنا أفكر إذن أنا موجود"؟', 'options' => ['ديكارت', 'أرسطو', 'أفلاطون', 'سقراط'], 'correct' => 0],
                ['question' => 'ما هو موضوع الأخلاق؟', 'options' => ['السلوك الإنساني', 'الطبيعة', 'المنطق', 'الجمال'], 'correct' => 0],
                ['question' => 'من أسس المدرسة التجريبية؟', 'options' => ['جون لوك', 'ديكارت', 'كانط', 'هيغل'], 'correct' => 0],
            ],
            'التاريخ والجغرافيا' => [
                ['question' => 'متى اندلعت الحرب العالمية الأولى؟', 'options' => ['1914', '1918', '1939', '1945'], 'correct' => 0],
                ['question' => 'ما هي عاصمة الجزائر؟', 'options' => ['الجزائر', 'وهران', 'قسنطينة', 'عنابة'], 'correct' => 0],
                ['question' => 'متى استقلت الجزائر؟', 'options' => ['1962', '1954', '1958', '1960'], 'correct' => 0],
                ['question' => 'ما هو أطول نهر في العالم؟', 'options' => ['النيل', 'الأمازون', 'المسيسيبي', 'اليانغتسي'], 'correct' => 0],
                ['question' => 'ما هي أكبر قارة من حيث المساحة؟', 'options' => ['آسيا', 'أفريقيا', 'أوروبا', 'أمريكا الشمالية'], 'correct' => 0],
            ],
            'العلوم الإسلامية' => [
                ['question' => 'كم عدد أركان الإسلام؟', 'options' => ['5', '4', '6', '3'], 'correct' => 0],
                ['question' => 'ما هو الركن الأول من أركان الإسلام؟', 'options' => ['الشهادتان', 'الصلاة', 'الصوم', 'الزكاة'], 'correct' => 0],
                ['question' => 'كم عدد السور في القرآن الكريم؟', 'options' => ['114', '100', '120', '110'], 'correct' => 0],
                ['question' => 'في أي سنة هجرية فتحت مكة؟', 'options' => ['8 هـ', '6 هـ', '10 هـ', '5 هـ'], 'correct' => 0],
                ['question' => 'ما هي الصلاة الوسطى؟', 'options' => ['العصر', 'الظهر', 'المغرب', 'العشاء'], 'correct' => 0],
            ],
        ];

        return $questions[$subject] ?? $questions['الرياضيات'];
    }

    protected function getMcqMultipleQuestions(string $subject): array
    {
        $questions = [
            'الرياضيات' => [
                ['question' => 'اختر الدوال المستمرة:', 'options' => ['كثيرات الحدود', 'الدوال الجذرية', 'الدوال المثلثية', 'دالة الجزء الصحيح', 'الدوال الأسية'], 'correct' => [0, 2, 4]],
                ['question' => 'اختر الأعداد الأولية:', 'options' => ['2', '4', '7', '9', '11'], 'correct' => [0, 2, 4]],
            ],
            'الفيزياء' => [
                ['question' => 'اختر الكميات المتجهة:', 'options' => ['السرعة', 'الكتلة', 'القوة', 'الطاقة', 'التسارع'], 'correct' => [0, 2, 4]],
                ['question' => 'اختر مصادر الطاقة المتجددة:', 'options' => ['الشمسية', 'النفط', 'الرياح', 'الفحم', 'المائية'], 'correct' => [0, 2, 4]],
            ],
            'علوم الطبيعة والحياة' => [
                ['question' => 'اختر العضيات الموجودة في الخلية الحيوانية:', 'options' => ['الميتوكوندريا', 'البلاستيدات الخضراء', 'النواة', 'الجدار الخلوي', 'الريبوسومات'], 'correct' => [0, 2, 4]],
                ['question' => 'اختر أنواع الأحماض النووية:', 'options' => ['DNA', 'ATP', 'RNA', 'ADP', 'mRNA'], 'correct' => [0, 2, 4]],
            ],
        ];

        return $questions[$subject] ?? [
            ['question' => 'اختر الإجابات الصحيحة:', 'options' => ['إجابة 1', 'إجابة 2', 'إجابة 3', 'إجابة 4', 'إجابة 5'], 'correct' => [0, 2]],
        ];
    }

    protected function getTrueFalseQuestions(string $subject): array
    {
        $questions = [
            'الرياضيات' => [
                ['question' => 'مشتقة دالة ثابتة تساوي صفر', 'correct' => true, 'explanation' => 'نعم، مشتقة أي ثابت تساوي صفر.'],
                ['question' => 'كل عدد زوجي يقبل القسمة على 4', 'correct' => false, 'explanation' => 'خطأ، مثلا 2 زوجي لكن لا يقبل القسمة على 4.'],
                ['question' => 'تكامل دالة موجبة دائماً موجب', 'correct' => false, 'explanation' => 'خطأ، يعتمد على حدود التكامل.'],
            ],
            'الفيزياء' => [
                ['question' => 'الطاقة لا تفنى ولا تستحدث', 'correct' => true, 'explanation' => 'صحيح، هذا هو قانون حفظ الطاقة.'],
                ['question' => 'سرعة الصوت أكبر من سرعة الضوء', 'correct' => false, 'explanation' => 'خطأ، سرعة الضوء أكبر بكثير.'],
                ['question' => 'الضغط يتناسب عكسياً مع الحجم عند ثبات درجة الحرارة', 'correct' => true, 'explanation' => 'صحيح، هذا هو قانون بويل.'],
            ],
            'علوم الطبيعة والحياة' => [
                ['question' => 'الخلية النباتية تحتوي على جدار خلوي', 'correct' => true, 'explanation' => 'صحيح.'],
                ['question' => 'الميتوكوندريا هي محطة توليد الطاقة في الخلية', 'correct' => true, 'explanation' => 'صحيح، تنتج ATP.'],
                ['question' => 'DNA موجود فقط في النواة', 'correct' => false, 'explanation' => 'خطأ، يوجد أيضاً في الميتوكوندريا والبلاستيدات.'],
            ],
            'اللغة العربية' => [
                ['question' => 'الفاعل دائماً مرفوع', 'correct' => true, 'explanation' => 'صحيح.'],
                ['question' => 'المفعول به دائماً منصوب', 'correct' => true, 'explanation' => 'صحيح.'],
                ['question' => 'الحال دائماً جملة', 'correct' => false, 'explanation' => 'خطأ، يمكن أن يكون مفرداً أو شبه جملة.'],
            ],
        ];

        return $questions[$subject] ?? [
            ['question' => 'هذه عبارة صحيحة', 'correct' => true],
            ['question' => 'هذه عبارة خاطئة', 'correct' => false],
        ];
    }

    protected function getFillBlankQuestions(string $subject): array
    {
        $questions = [
            'الرياضيات' => [
                ['question' => 'مشتقة sin(x) هي _____', 'correct' => 'cos(x)', 'explanation' => 'مشتقة الجيب هي جيب التمام.'],
                ['question' => 'تكامل 1/x هو _____', 'correct' => 'ln|x|+C', 'explanation' => 'تكامل 1/x يساوي اللوغاريتم الطبيعي.'],
                ['question' => 'مساحة الدائرة = _____ × r²', 'correct' => 'π', 'explanation' => 'مساحة الدائرة = πr².'],
            ],
            'الفيزياء' => [
                ['question' => 'وحدة قياس الشدة الكهربائية هي _____', 'correct' => 'أمبير', 'explanation' => 'الأمبير هو وحدة الشدة.'],
                ['question' => 'F = m × _____', 'correct' => 'a', 'explanation' => 'F = ma هو قانون نيوتن الثاني.'],
                ['question' => 'سرعة الضوء في الفراغ تقارب _____ × 10⁸ m/s', 'correct' => '3', 'explanation' => 'c ≈ 3×10⁸ m/s.'],
            ],
            'علوم الطبيعة والحياة' => [
                ['question' => 'الصيغة الكيميائية للماء هي _____', 'correct' => 'H2O', 'explanation' => 'الماء يتكون من ذرتي هيدروجين وذرة أكسجين.'],
                ['question' => 'عدد الكروموسومات في الخلية البشرية هو _____', 'correct' => '46', 'explanation' => '23 زوجاً من الكروموسومات.'],
                ['question' => 'الحمض النووي الريبي منقوص الأكسجين يرمز له بـ _____', 'correct' => 'DNA', 'explanation' => 'DNA = Deoxyribonucleic Acid.'],
            ],
        ];

        return $questions[$subject] ?? [
            ['question' => 'أكمل الفراغ: _____', 'correct' => 'الإجابة'],
        ];
    }
}
