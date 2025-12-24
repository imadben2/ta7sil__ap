<?php

namespace Database\Seeders;

use App\Models\ContentChapter;
use App\Models\Flashcard;
use App\Models\FlashcardDeck;
use App\Models\Subject;
use App\Models\User;
use Illuminate\Database\Seeder;

class FlashcardSeeder extends Seeder
{
    /**
     * Run the database seeds.
     * Creates flashcard decks with all 4 card types (basic, cloze, image, audio)
     */
    public function run(): void
    {
        $this->command->info('Creating flashcard test data...');

        // Get subjects with chapters
        $subjects = Subject::whereHas('contentChapters')->take(5)->get();

        if ($subjects->isEmpty()) {
            // Fallback to any subjects
            $subjects = Subject::take(5)->get();
        }

        if ($subjects->isEmpty()) {
            $this->command->error('No subjects found. Please run subject seeders first.');
            return;
        }

        // Get admin user for created_by
        $admin = User::where('is_admin', true)->first();
        $adminId = $admin ? $admin->id : null;

        foreach ($subjects as $subject) {
            // Create a deck for each subject
            $this->createDeckWithCards($subject, $adminId);
        }

        // Create some additional themed decks
        $this->createMathDeck($subjects, $adminId);
        $this->createPhysicsDeck($subjects, $adminId);
        $this->createIslamicStudiesDeck($subjects, $adminId);
        $this->createHistoryDeck($subjects, $adminId);
        $this->createLanguageDeck($subjects, $adminId);

        $this->command->info('Flashcard seeding completed!');
        $this->command->info('Created ' . FlashcardDeck::count() . ' decks with ' . Flashcard::count() . ' cards.');
    }

    /**
     * Create a deck with cards of all types
     */
    private function createDeckWithCards(Subject $subject, ?int $adminId): FlashcardDeck
    {
        // Get a chapter for this subject
        $chapter = ContentChapter::where('subject_id', $subject->id)->first();

        $deck = FlashcardDeck::create([
            'subject_id' => $subject->id,
            'chapter_id' => $chapter?->id,
            'academic_stream_id' => null,
            'title_ar' => 'بطاقات ' . $subject->name_ar,
            'title_fr' => 'Cartes ' . ($subject->name_fr ?? $subject->name_ar),
            'description_ar' => 'مجموعة بطاقات تعليمية لمادة ' . $subject->name_ar . ' تحتوي على جميع أنواع البطاقات',
            'description_fr' => 'Collection de flashcards pour ' . ($subject->name_fr ?? $subject->name_ar),
            'color' => $this->getRandomColor(),
            'difficulty_level' => $this->getRandomDifficulty(),
            'estimated_study_minutes' => rand(10, 30),
            'is_published' => true,
            'is_premium' => rand(0, 1) === 1,
            'order' => 0,
            'created_by' => $adminId,
        ]);

        // Create cards of all types
        $this->createBasicCards($deck);
        $this->createClozeCards($deck);
        $this->createImageCards($deck);
        $this->createAudioCards($deck);

        // Update total card count
        $deck->updateCardCount();

        return $deck;
    }

    /**
     * Create basic flashcards
     */
    private function createBasicCards(FlashcardDeck $deck): void
    {
        $basicCards = [
            [
                'front' => 'ما هي عاصمة الجزائر؟',
                'back' => 'الجزائر العاصمة',
                'hint' => 'أكبر مدينة في البلاد',
                'explanation' => 'الجزائر العاصمة هي عاصمة الجزائر وأكبر مدنها، تقع على ساحل البحر الأبيض المتوسط.',
            ],
            [
                'front' => 'ما هو الجذر التربيعي للعدد 144؟',
                'back' => '12',
                'hint' => 'فكر في جدول الضرب',
                'explanation' => '12 × 12 = 144، لذلك √144 = 12',
            ],
            [
                'front' => 'ما هي وحدة قياس القوة في النظام الدولي؟',
                'back' => 'النيوتن (N)',
                'hint' => 'سميت على اسم عالم الفيزياء الشهير',
                'explanation' => 'النيوتن هي وحدة القوة في النظام الدولي، سميت تكريماً للعالم إسحاق نيوتن.',
            ],
            [
                'front' => 'ما هو العنصر الكيميائي الذي رمزه O؟',
                'back' => 'الأكسجين',
                'hint' => 'ضروري للتنفس',
                'explanation' => 'الأكسجين (O) هو العنصر رقم 8 في الجدول الدوري وضروري لحياة معظم الكائنات الحية.',
            ],
            [
                'front' => 'متى اندلعت الثورة الجزائرية؟',
                'back' => '1 نوفمبر 1954',
                'hint' => 'في فصل الخريف',
                'explanation' => 'اندلعت ثورة التحرير الجزائرية ضد الاستعمار الفرنسي في الفاتح من نوفمبر 1954.',
            ],
        ];

        foreach ($basicCards as $index => $card) {
            Flashcard::create([
                'deck_id' => $deck->id,
                'card_type' => Flashcard::TYPE_BASIC,
                'front_text_ar' => $card['front'],
                'back_text_ar' => $card['back'],
                'hint_ar' => $card['hint'],
                'explanation_ar' => $card['explanation'],
                'difficulty_level' => $this->getRandomDifficulty(),
                'order' => $index + 1,
                'is_active' => true,
            ]);
        }
    }

    /**
     * Create cloze (fill-in-the-blank) flashcards
     */
    private function createClozeCards(FlashcardDeck $deck): void
    {
        $clozeCards = [
            [
                'template' => 'المعادلة الكيميائية للماء هي {{c1::H2O}}.',
                'back' => 'المعادلة الكيميائية للماء هي H2O.',
                'hint' => 'تتكون من الهيدروجين والأكسجين',
                'explanation' => 'الماء يتكون من ذرتين هيدروجين وذرة أكسجين واحدة.',
            ],
            [
                'template' => 'قانون أوم: V = {{c1::I}} × {{c2::R}}',
                'back' => 'قانون أوم: V = I × R (الجهد = التيار × المقاومة)',
                'hint' => 'V للجهد، I للتيار، R للمقاومة',
                'explanation' => 'قانون أوم يربط بين الجهد الكهربائي والتيار والمقاومة.',
            ],
            [
                'template' => 'مساحة الدائرة = {{c1::π}} × {{c2::r²}}',
                'back' => 'مساحة الدائرة = π × r² (باي ضرب مربع نصف القطر)',
                'hint' => 'تتضمن الثابت الرياضي الشهير',
                'explanation' => 'مساحة الدائرة تُحسب بضرب π (تقريباً 3.14) في مربع نصف القطر.',
            ],
            [
                'template' => 'تقع الجزائر في قارة {{c1::أفريقيا::القارة السمراء}}.',
                'back' => 'تقع الجزائر في قارة أفريقيا.',
                'hint' => 'ثاني أكبر قارة في العالم',
                'explanation' => 'الجزائر هي أكبر دولة في أفريقيا من حيث المساحة.',
            ],
            [
                'template' => 'الفعل الماضي من "يكتب" هو {{c1::كَتَبَ}}.',
                'back' => 'الفعل الماضي من "يكتب" هو كَتَبَ.',
                'hint' => 'ثلاثي مجرد',
                'explanation' => 'يكتب فعل مضارع، وماضيه كَتَبَ على وزن فَعَلَ.',
            ],
        ];

        $startOrder = Flashcard::where('deck_id', $deck->id)->count() + 1;

        foreach ($clozeCards as $index => $card) {
            Flashcard::create([
                'deck_id' => $deck->id,
                'card_type' => Flashcard::TYPE_CLOZE,
                'cloze_template' => $card['template'],
                'front_text_ar' => preg_replace('/\{\{c\d+::([^}:]+)(?:::[^}]+)?\}\}/', '______', $card['template']),
                'back_text_ar' => $card['back'],
                'hint_ar' => $card['hint'],
                'explanation_ar' => $card['explanation'],
                'difficulty_level' => $this->getRandomDifficulty(),
                'order' => $startOrder + $index,
                'is_active' => true,
            ]);
        }
    }

    /**
     * Create image flashcards
     */
    private function createImageCards(FlashcardDeck $deck): void
    {
        $imageCards = [
            [
                'front' => 'ما هذا الشكل الهندسي؟',
                'front_image' => 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/ec/Regular_triangle.svg/200px-Regular_triangle.svg.png',
                'back' => 'مثلث متساوي الأضلاع',
                'back_image' => null,
                'hint' => 'له ثلاثة أضلاع متساوية',
                'explanation' => 'المثلث المتساوي الأضلاع له ثلاثة أضلاع متساوية الطول وثلاث زوايا متساوية (60 درجة لكل زاوية).',
            ],
            [
                'front' => 'ما اسم هذا العلم؟',
                'front_image' => 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/77/Flag_of_Algeria.svg/200px-Flag_of_Algeria.svg.png',
                'back' => 'علم الجزائر',
                'back_image' => null,
                'hint' => 'أخضر وأبيض',
                'explanation' => 'علم الجزائر يتكون من شريطين أخضر وأبيض مع هلال ونجمة حمراء في الوسط.',
            ],
            [
                'front' => 'ما اسم هذا الكوكب؟',
                'front_image' => 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0c/Mars_-_August_30_2021_-_Flickr_-_Kevin_M._Gill.png/200px-Mars_-_August_30_2021_-_Flickr_-_Kevin_M._Gill.png',
                'back' => 'كوكب المريخ',
                'back_image' => null,
                'hint' => 'الكوكب الأحمر',
                'explanation' => 'المريخ هو الكوكب الرابع في المجموعة الشمسية ويسمى الكوكب الأحمر بسبب لونه.',
            ],
            [
                'front' => 'ما هذا الشكل الهندسي ثلاثي الأبعاد؟',
                'front_image' => 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/33/Hexahedron.svg/200px-Hexahedron.svg.png',
                'back' => 'المكعب (Cube)',
                'back_image' => null,
                'hint' => 'له 6 أوجه متساوية',
                'explanation' => 'المكعب هو شكل ثلاثي الأبعاد له 6 أوجه مربعة متساوية و12 حافة و8 رؤوس.',
            ],
        ];

        $startOrder = Flashcard::where('deck_id', $deck->id)->count() + 1;

        foreach ($imageCards as $index => $card) {
            Flashcard::create([
                'deck_id' => $deck->id,
                'card_type' => Flashcard::TYPE_IMAGE,
                'front_text_ar' => $card['front'],
                'front_image_url' => $card['front_image'],
                'back_text_ar' => $card['back'],
                'back_image_url' => $card['back_image'],
                'hint_ar' => $card['hint'],
                'explanation_ar' => $card['explanation'],
                'difficulty_level' => $this->getRandomDifficulty(),
                'order' => $startOrder + $index,
                'is_active' => true,
            ]);
        }
    }

    /**
     * Create audio flashcards
     */
    private function createAudioCards(FlashcardDeck $deck): void
    {
        // Using sample audio URLs (these are placeholders - in production use real audio files)
        $audioCards = [
            [
                'front' => 'استمع للكلمة ثم اكتب ترجمتها بالعربية',
                'front_audio' => 'https://ssl.gstatic.com/dictionary/static/sounds/20200429/hello--_gb_1.mp3',
                'back' => 'مرحبا (Hello)',
                'back_audio' => null,
                'hint' => 'تحية باللغة الإنجليزية',
                'explanation' => 'Hello هي التحية الأكثر شيوعاً في اللغة الإنجليزية.',
            ],
            [
                'front' => 'استمع للجملة واكتب معناها',
                'front_audio' => 'https://ssl.gstatic.com/dictionary/static/sounds/20200429/goodbye--_gb_1.mp3',
                'back' => 'مع السلامة (Goodbye)',
                'back_audio' => null,
                'hint' => 'عبارة الوداع',
                'explanation' => 'Goodbye تستخدم للوداع في اللغة الإنجليزية.',
            ],
            [
                'front' => 'ما هذا الصوت الموسيقي؟',
                'front_audio' => 'https://upload.wikimedia.org/wikipedia/commons/4/4b/C_major_scale.mid',
                'back' => 'سلم دو الكبير (C Major Scale)',
                'back_audio' => null,
                'hint' => 'سلم موسيقي أساسي',
                'explanation' => 'سلم دو الكبير هو أحد أهم السلالم الموسيقية ولا يحتوي على علامات تحويل.',
            ],
        ];

        $startOrder = Flashcard::where('deck_id', $deck->id)->count() + 1;

        foreach ($audioCards as $index => $card) {
            Flashcard::create([
                'deck_id' => $deck->id,
                'card_type' => Flashcard::TYPE_AUDIO,
                'front_text_ar' => $card['front'],
                'front_audio_url' => $card['front_audio'],
                'back_text_ar' => $card['back'],
                'back_audio_url' => $card['back_audio'],
                'hint_ar' => $card['hint'],
                'explanation_ar' => $card['explanation'],
                'difficulty_level' => $this->getRandomDifficulty(),
                'order' => $startOrder + $index,
                'is_active' => true,
            ]);
        }
    }

    /**
     * Create a math-themed deck
     */
    private function createMathDeck($subjects, ?int $adminId): void
    {
        $mathSubject = $subjects->first(fn($s) => str_contains($s->name_ar, 'رياضيات'));
        if (!$mathSubject) {
            $mathSubject = Subject::where('name_ar', 'like', '%رياضيات%')->first();
        }
        if (!$mathSubject) {
            $mathSubject = $subjects->first();
        }

        $deck = FlashcardDeck::create([
            'subject_id' => $mathSubject->id,
            'chapter_id' => null,
            'title_ar' => 'الهندسة والأشكال',
            'title_fr' => 'Géométrie et Formes',
            'description_ar' => 'بطاقات تعليمية عن الأشكال الهندسية وخصائصها',
            'color' => '#3B82F6',
            'difficulty_level' => 'medium',
            'estimated_study_minutes' => 15,
            'is_published' => true,
            'is_premium' => false,
            'order' => 1,
            'created_by' => $adminId,
        ]);

        // Basic geometry cards
        $cards = [
            ['front' => 'كم عدد أضلاع المربع؟', 'back' => '4 أضلاع متساوية'],
            ['front' => 'ما هي مساحة المستطيل؟', 'back' => 'الطول × العرض'],
            ['front' => 'ما هو محيط الدائرة؟', 'back' => '2 × π × r (القطر × π)'],
            ['front' => 'كم زاوية في المثلث؟', 'back' => '3 زوايا مجموعها 180 درجة'],
            ['front' => 'ما هو حجم المكعب؟', 'back' => 'الضلع³ (s³)'],
        ];

        foreach ($cards as $index => $card) {
            Flashcard::create([
                'deck_id' => $deck->id,
                'card_type' => Flashcard::TYPE_BASIC,
                'front_text_ar' => $card['front'],
                'back_text_ar' => $card['back'],
                'difficulty_level' => 'easy',
                'order' => $index + 1,
                'is_active' => true,
            ]);
        }

        // Cloze math cards
        $clozeCards = [
            ['template' => 'مساحة المثلث = {{c1::نصف}} × القاعدة × الارتفاع', 'back' => 'مساحة المثلث = نصف × القاعدة × الارتفاع'],
            ['template' => 'نظرية فيثاغورس: أ² + ب² = {{c1::ج²}}', 'back' => 'نظرية فيثاغورس: أ² + ب² = ج²'],
        ];

        $startOrder = count($cards) + 1;
        foreach ($clozeCards as $index => $card) {
            Flashcard::create([
                'deck_id' => $deck->id,
                'card_type' => Flashcard::TYPE_CLOZE,
                'cloze_template' => $card['template'],
                'front_text_ar' => preg_replace('/\{\{c\d+::([^}]+)\}\}/', '______', $card['template']),
                'back_text_ar' => $card['back'],
                'difficulty_level' => 'medium',
                'order' => $startOrder + $index,
                'is_active' => true,
            ]);
        }

        $deck->updateCardCount();
    }

    /**
     * Create a physics-themed deck
     */
    private function createPhysicsDeck($subjects, ?int $adminId): void
    {
        $physicsSubject = $subjects->first(fn($s) => str_contains($s->name_ar, 'فيزياء'));
        if (!$physicsSubject) {
            $physicsSubject = Subject::where('name_ar', 'like', '%فيزياء%')->first();
        }
        if (!$physicsSubject) {
            $physicsSubject = $subjects->first();
        }

        $deck = FlashcardDeck::create([
            'subject_id' => $physicsSubject->id,
            'title_ar' => 'قوانين نيوتن للحركة',
            'title_fr' => 'Lois de Newton',
            'description_ar' => 'بطاقات عن قوانين نيوتن الثلاثة للحركة',
            'color' => '#8B5CF6',
            'difficulty_level' => 'hard',
            'estimated_study_minutes' => 20,
            'is_published' => true,
            'is_premium' => true,
            'order' => 2,
            'created_by' => $adminId,
        ]);

        $cards = [
            ['front' => 'ما هو قانون نيوتن الأول؟', 'back' => 'الجسم الساكن يبقى ساكناً والجسم المتحرك يستمر في حركته بخط مستقيم بسرعة ثابتة ما لم تؤثر عليه قوة خارجية (قانون القصور الذاتي)'],
            ['front' => 'ما هو قانون نيوتن الثاني؟', 'back' => 'القوة = الكتلة × التسارع (F = ma)'],
            ['front' => 'ما هو قانون نيوتن الثالث؟', 'back' => 'لكل فعل رد فعل مساوٍ له في المقدار ومعاكس له في الاتجاه'],
            ['front' => 'ما هي وحدة قياس القوة؟', 'back' => 'النيوتن (N)'],
            ['front' => 'ما هي وحدة قياس الكتلة؟', 'back' => 'الكيلوغرام (kg)'],
            ['front' => 'ما هي وحدة قياس التسارع؟', 'back' => 'متر لكل ثانية مربعة (m/s²)'],
        ];

        foreach ($cards as $index => $card) {
            Flashcard::create([
                'deck_id' => $deck->id,
                'card_type' => Flashcard::TYPE_BASIC,
                'front_text_ar' => $card['front'],
                'back_text_ar' => $card['back'],
                'difficulty_level' => 'hard',
                'order' => $index + 1,
                'is_active' => true,
            ]);
        }

        // Add cloze cards
        $clozeCards = [
            ['template' => 'قانون نيوتن الثاني: F = {{c1::m}} × {{c2::a}}', 'back' => 'قانون نيوتن الثاني: F = m × a'],
            ['template' => 'وزن الجسم = الكتلة × {{c1::تسارع الجاذبية::g}}', 'back' => 'وزن الجسم = الكتلة × تسارع الجاذبية'],
        ];

        $startOrder = count($cards) + 1;
        foreach ($clozeCards as $index => $card) {
            Flashcard::create([
                'deck_id' => $deck->id,
                'card_type' => Flashcard::TYPE_CLOZE,
                'cloze_template' => $card['template'],
                'front_text_ar' => preg_replace('/\{\{c\d+::([^}:]+)(?:::[^}]+)?\}\}/', '______', $card['template']),
                'back_text_ar' => $card['back'],
                'difficulty_level' => 'hard',
                'order' => $startOrder + $index,
                'is_active' => true,
            ]);
        }

        $deck->updateCardCount();
    }

    /**
     * Create Islamic studies deck
     */
    private function createIslamicStudiesDeck($subjects, ?int $adminId): void
    {
        $islamicSubject = $subjects->first(fn($s) => str_contains($s->name_ar, 'إسلامية') || str_contains($s->name_ar, 'تربية'));
        if (!$islamicSubject) {
            $islamicSubject = Subject::where('name_ar', 'like', '%إسلام%')->first();
        }
        if (!$islamicSubject) {
            $islamicSubject = $subjects->first();
        }

        $deck = FlashcardDeck::create([
            'subject_id' => $islamicSubject->id,
            'title_ar' => 'أركان الإسلام والإيمان',
            'title_fr' => 'Piliers de l\'Islam',
            'description_ar' => 'بطاقات عن أركان الإسلام الخمسة وأركان الإيمان الستة',
            'color' => '#10B981',
            'difficulty_level' => 'easy',
            'estimated_study_minutes' => 10,
            'is_published' => true,
            'is_premium' => false,
            'order' => 3,
            'created_by' => $adminId,
        ]);

        $cards = [
            ['front' => 'كم عدد أركان الإسلام؟', 'back' => '5 أركان'],
            ['front' => 'ما هو الركن الأول من أركان الإسلام؟', 'back' => 'الشهادتان: شهادة أن لا إله إلا الله وأن محمداً رسول الله'],
            ['front' => 'ما هو الركن الثاني من أركان الإسلام؟', 'back' => 'إقام الصلاة'],
            ['front' => 'ما هو الركن الثالث من أركان الإسلام؟', 'back' => 'إيتاء الزكاة'],
            ['front' => 'ما هو الركن الرابع من أركان الإسلام؟', 'back' => 'صوم رمضان'],
            ['front' => 'ما هو الركن الخامس من أركان الإسلام؟', 'back' => 'حج البيت لمن استطاع إليه سبيلا'],
            ['front' => 'كم عدد أركان الإيمان؟', 'back' => '6 أركان'],
            ['front' => 'اذكر أركان الإيمان الستة', 'back' => 'الإيمان بالله، وملائكته، وكتبه، ورسله، واليوم الآخر، والقدر خيره وشره'],
        ];

        foreach ($cards as $index => $card) {
            Flashcard::create([
                'deck_id' => $deck->id,
                'card_type' => Flashcard::TYPE_BASIC,
                'front_text_ar' => $card['front'],
                'back_text_ar' => $card['back'],
                'difficulty_level' => 'easy',
                'order' => $index + 1,
                'is_active' => true,
            ]);
        }

        // Cloze cards
        $clozeCards = [
            ['template' => 'أركان الإسلام: الشهادتان، الصلاة، {{c1::الزكاة}}، الصوم، {{c2::الحج}}', 'back' => 'أركان الإسلام: الشهادتان، الصلاة، الزكاة، الصوم، الحج'],
        ];

        $startOrder = count($cards) + 1;
        foreach ($clozeCards as $index => $card) {
            Flashcard::create([
                'deck_id' => $deck->id,
                'card_type' => Flashcard::TYPE_CLOZE,
                'cloze_template' => $card['template'],
                'front_text_ar' => preg_replace('/\{\{c\d+::([^}]+)\}\}/', '______', $card['template']),
                'back_text_ar' => $card['back'],
                'difficulty_level' => 'easy',
                'order' => $startOrder + $index,
                'is_active' => true,
            ]);
        }

        $deck->updateCardCount();
    }

    /**
     * Create history deck
     */
    private function createHistoryDeck($subjects, ?int $adminId): void
    {
        $historySubject = $subjects->first(fn($s) => str_contains($s->name_ar, 'تاريخ'));
        if (!$historySubject) {
            $historySubject = Subject::where('name_ar', 'like', '%تاريخ%')->first();
        }
        if (!$historySubject) {
            $historySubject = $subjects->first();
        }

        $deck = FlashcardDeck::create([
            'subject_id' => $historySubject->id,
            'title_ar' => 'تاريخ الجزائر الحديث',
            'title_fr' => 'Histoire de l\'Algérie moderne',
            'description_ar' => 'بطاقات عن تاريخ الجزائر الحديث وحرب التحرير',
            'color' => '#F59E0B',
            'difficulty_level' => 'medium',
            'estimated_study_minutes' => 20,
            'is_published' => true,
            'is_premium' => false,
            'order' => 4,
            'created_by' => $adminId,
        ]);

        $cards = [
            ['front' => 'متى بدأت الثورة الجزائرية؟', 'back' => '1 نوفمبر 1954'],
            ['front' => 'متى استقلت الجزائر؟', 'back' => '5 يوليو 1962'],
            ['front' => 'ما اسم الحركة الوطنية التي أسسها مصالي الحاج؟', 'back' => 'نجم شمال أفريقيا (1926)'],
            ['front' => 'ما هي مجازر 8 ماي 1945؟', 'back' => 'مجازر ارتكبتها فرنسا ضد الجزائريين في سطيف وقالمة وخراطة'],
            ['front' => 'ما هي جبهة التحرير الوطني (FLN)؟', 'back' => 'الحزب الذي قاد الثورة الجزائرية ضد الاستعمار الفرنسي'],
            ['front' => 'من هو أول رئيس للجزائر المستقلة؟', 'back' => 'أحمد بن بلة'],
        ];

        foreach ($cards as $index => $card) {
            Flashcard::create([
                'deck_id' => $deck->id,
                'card_type' => Flashcard::TYPE_BASIC,
                'front_text_ar' => $card['front'],
                'back_text_ar' => $card['back'],
                'difficulty_level' => 'medium',
                'order' => $index + 1,
                'is_active' => true,
            ]);
        }

        // Image card for history
        Flashcard::create([
            'deck_id' => $deck->id,
            'card_type' => Flashcard::TYPE_IMAGE,
            'front_text_ar' => 'ما اسم هذا المعلم التاريخي؟',
            'front_image_url' => 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6d/Memorial_du_Martyr-Alger.jpg/220px-Memorial_du_Martyr-Alger.jpg',
            'back_text_ar' => 'مقام الشهيد (الجزائر العاصمة)',
            'explanation_ar' => 'مقام الشهيد هو نصب تذكاري بني عام 1982 لتخليد ذكرى شهداء ثورة التحرير',
            'difficulty_level' => 'medium',
            'order' => count($cards) + 1,
            'is_active' => true,
        ]);

        $deck->updateCardCount();
    }

    /**
     * Create language deck (Arabic/French/English)
     */
    private function createLanguageDeck($subjects, ?int $adminId): void
    {
        $langSubject = $subjects->first(fn($s) => str_contains($s->name_ar, 'لغة') || str_contains($s->name_ar, 'فرنسية') || str_contains($s->name_ar, 'إنجليزية'));
        if (!$langSubject) {
            $langSubject = Subject::where('name_ar', 'like', '%لغة%')->first();
        }
        if (!$langSubject) {
            $langSubject = $subjects->first();
        }

        $deck = FlashcardDeck::create([
            'subject_id' => $langSubject->id,
            'title_ar' => 'مفردات فرنسية أساسية',
            'title_fr' => 'Vocabulaire français de base',
            'description_ar' => 'بطاقات لتعلم المفردات الفرنسية الأساسية مع النطق',
            'color' => '#EC4899',
            'difficulty_level' => 'easy',
            'estimated_study_minutes' => 15,
            'is_published' => true,
            'is_premium' => false,
            'order' => 5,
            'created_by' => $adminId,
        ]);

        $cards = [
            ['front' => 'Bonjour', 'back' => 'صباح الخير / مرحبا', 'hint' => 'تحية صباحية'],
            ['front' => 'Merci', 'back' => 'شكراً', 'hint' => 'للتعبير عن الامتنان'],
            ['front' => 'S\'il vous plaît', 'back' => 'من فضلك', 'hint' => 'عبارة مجاملة'],
            ['front' => 'Au revoir', 'back' => 'إلى اللقاء', 'hint' => 'للوداع'],
            ['front' => 'Oui / Non', 'back' => 'نعم / لا', 'hint' => 'كلمات أساسية'],
            ['front' => 'Comment allez-vous?', 'back' => 'كيف حالك؟', 'hint' => 'سؤال عن الحال'],
            ['front' => 'Je m\'appelle...', 'back' => 'اسمي...', 'hint' => 'للتعريف بالنفس'],
            ['front' => 'Excusez-moi', 'back' => 'عفواً / اعذرني', 'hint' => 'للاعتذار أو جذب الانتباه'],
        ];

        foreach ($cards as $index => $card) {
            Flashcard::create([
                'deck_id' => $deck->id,
                'card_type' => Flashcard::TYPE_BASIC,
                'front_text_ar' => $card['front'],
                'front_text_fr' => $card['front'],
                'back_text_ar' => $card['back'],
                'hint_ar' => $card['hint'] ?? null,
                'difficulty_level' => 'easy',
                'order' => $index + 1,
                'is_active' => true,
            ]);
        }

        // Audio cards for pronunciation
        $audioCards = [
            [
                'front' => 'استمع وترجم: "Hello"',
                'front_audio' => 'https://ssl.gstatic.com/dictionary/static/sounds/20200429/hello--_gb_1.mp3',
                'back' => 'مرحبا',
            ],
            [
                'front' => 'استمع وترجم: "Thank you"',
                'front_audio' => 'https://ssl.gstatic.com/dictionary/static/sounds/20200429/thank_you--_gb_1.mp3',
                'back' => 'شكراً لك',
            ],
        ];

        $startOrder = count($cards) + 1;
        foreach ($audioCards as $index => $card) {
            Flashcard::create([
                'deck_id' => $deck->id,
                'card_type' => Flashcard::TYPE_AUDIO,
                'front_text_ar' => $card['front'],
                'front_audio_url' => $card['front_audio'],
                'back_text_ar' => $card['back'],
                'difficulty_level' => 'easy',
                'order' => $startOrder + $index,
                'is_active' => true,
            ]);
        }

        $deck->updateCardCount();
    }

    /**
     * Get random color for deck
     */
    private function getRandomColor(): string
    {
        $colors = [
            '#EC4899', // pink
            '#8B5CF6', // purple
            '#3B82F6', // blue
            '#10B981', // green
            '#F59E0B', // amber
            '#EF4444', // red
            '#6366F1', // indigo
            '#14B8A6', // teal
        ];

        return $colors[array_rand($colors)];
    }

    /**
     * Get random difficulty level
     */
    private function getRandomDifficulty(): string
    {
        $levels = ['easy', 'medium', 'hard'];
        return $levels[array_rand($levels)];
    }
}
