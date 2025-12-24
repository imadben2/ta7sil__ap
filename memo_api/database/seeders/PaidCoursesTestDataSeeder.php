<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Course;
use App\Models\CourseModule;
use App\Models\CourseLesson;
use App\Models\CourseReview;
use App\Models\SubscriptionPackage;
use App\Models\SubscriptionCode;
use App\Models\PaymentReceipt;
use App\Models\UserSubscription;
use App\Models\User;
use App\Models\Subject;
use App\Models\AcademicPhase;
use App\Models\AcademicYear;
use App\Models\AcademicStream;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class PaidCoursesTestDataSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $this->command->info('🔄 Creating test data for paid courses system...');

        // Clean up existing test data
        $this->command->warn('⚠️  Cleaning up existing test data...');

        // Force delete courses with test titles or slugs that start with 'dor-'
        Course::where(function ($query) {
            $query->where('slug', 'like', 'dor-%')
                  ->orWhereIn('title_ar', [
                      'دورة الرياضيات المتقدمة',
                      'دورة الفيزياء الشاملة',
                      'دورة الكيمياء العضوية',
                      'دورة اللغة العربية',
                      'دورة اللغة الإنجليزية',
                      'دورة علوم الطبيعة',
                      'دورة التاريخ والجغرافيا',
                      'دورة الفلسفة المعمقة',
                      'دورة الإعلام الآلي',
                      'دورة المحاسبة المالية',
                      'دورة القانون الجزائري',
                      'دورة الاقتصاد والتسيير',
                      'دورة الأحياء الجزيئية',
                      'دورة الهندسة المدنية',
                      'دورة الأدب العربي',
                  ]);
        })->forceDelete();

        // Delete test subscription packages
        SubscriptionPackage::whereIn('name_ar', [
            'الباقة الأساسية',
            'الباقة المتوسطة',
            'الباقة الذهبية',
            'باقة البكالوريا',
            'الباقة الشاملة',
            'باقة التجريبية',
        ])->delete();

        // Create test users (students) - skip if already exists
        $students = [];
        for ($i = 1; $i <= 20; $i++) {
            $email = 'student' . $i . '@test.com';
            $student = User::where('email', $email)->first();

            if (!$student) {
                $student = User::create([
                    'name' => 'طالب رقم ' . $i,
                    'email' => $email,
                    'password' => Hash::make('password'),
                    'role' => 'student',
                    'is_active' => true,
                ]);
            }

            $students[] = $student;
        }

        $this->command->info('👥 Students ready: ' . count($students));

        // Get academic hierarchy
        $phase = AcademicPhase::first();
        $year = AcademicYear::first();
        $stream = AcademicStream::first();
        $subjects = Subject::limit(10)->get();

        // Create 15 Courses
        $courses = [];
        $courseData = [
            ['title' => 'دورة الرياضيات المتقدمة', 'price' => 15000, 'level' => 'advanced', 'color' => 'blue'],
            ['title' => 'دورة الفيزياء الشاملة', 'price' => 12000, 'level' => 'intermediate', 'color' => 'purple'],
            ['title' => 'دورة الكيمياء العضوية', 'price' => 10000, 'level' => 'intermediate', 'color' => 'green'],
            ['title' => 'دورة اللغة العربية', 'price' => 8000, 'level' => 'beginner', 'color' => 'red'],
            ['title' => 'دورة اللغة الإنجليزية', 'price' => 9000, 'level' => 'beginner', 'color' => 'yellow'],
            ['title' => 'دورة علوم الطبيعة', 'price' => 11000, 'level' => 'intermediate', 'color' => 'cyan'],
            ['title' => 'دورة التاريخ والجغرافيا', 'price' => 7000, 'level' => 'beginner', 'color' => 'orange'],
            ['title' => 'دورة الفلسفة المعمقة', 'price' => 13000, 'level' => 'advanced', 'color' => 'indigo'],
            ['title' => 'دورة الإعلام الآلي', 'price' => 0, 'level' => 'beginner', 'color' => 'pink', 'free' => true],
            ['title' => 'دورة المحاسبة المالية', 'price' => 14000, 'level' => 'advanced', 'color' => 'teal'],
            ['title' => 'دورة القانون الجزائري', 'price' => 12500, 'level' => 'intermediate', 'color' => 'lime'],
            ['title' => 'دورة الاقتصاد والتسيير', 'price' => 0, 'level' => 'intermediate', 'color' => 'amber', 'free' => true],
            ['title' => 'دورة الأحياء الجزيئية', 'price' => 16000, 'level' => 'advanced', 'color' => 'emerald'],
            ['title' => 'دورة الهندسة المدنية', 'price' => 18000, 'level' => 'advanced', 'color' => 'slate'],
            ['title' => 'دورة الأدب العربي', 'price' => 9500, 'level' => 'intermediate', 'color' => 'rose'],
        ];

        foreach ($courseData as $index => $data) {
            $subject = $subjects->random();

            // Get admin user for created_by (only do this once)
            if (!isset($admin)) {
                $admin = User::where('role', 'admin')->orWhere('role', 'teacher')->first();
                if (!$admin) {
                    // Create a default admin if none exists
                    $admin = User::firstOrCreate(
                        ['email' => 'admin@test.com'],
                        [
                            'name' => 'مدير النظام',
                            'password' => Hash::make('password'),
                            'role' => 'admin',
                            'is_active' => true,
                        ]
                    );
                }
                $this->command->info('👨‍💼 Admin user: ' . $admin->email);
            }

            $course = Course::create([
                'title_ar' => $data['title'],
                'slug' => Str::slug($data['title']),
                'description_ar' => 'هذه دورة تعليمية شاملة ومتكاملة تغطي جميع جوانب المادة بشكل عميق ومفصل. تتضمن الدورة شرح نظري وتطبيقات عملية متنوعة لضمان استيعاب الطالب للمفاهيم الأساسية والمتقدمة.',
                'thumbnail_url' => 'courses/thumbnails/course_' . ($index + 1) . '.jpg',
                'subject_id' => $subject->id,
                'price_dzd' => $data['price'],
                'duration_days' => rand(30, 90),
                'is_published' => $index < 12, // 12 published, 3 drafts
                'published_at' => $index < 12 ? now()->subDays(rand(1, 30)) : null,
                'created_by' => $admin->id,
            ]);

            $courses[] = $course;

            // Create modules for each course
            for ($m = 1; $m <= rand(3, 6); $m++) {
                $module = CourseModule::create([
                    'course_id' => $course->id,
                    'title_ar' => 'الوحدة ' . $m . ': ' . ['مقدمة', 'المفاهيم الأساسية', 'التطبيقات', 'التمارين', 'المراجعة', 'الاختبارات'][rand(0, 5)],
                    'description_ar' => 'وصف تفصيلي للوحدة الدراسية',
                    'order' => $m,
                ]);

                // Create lessons for each module
                for ($l = 1; $l <= rand(4, 8); $l++) {
                    CourseLesson::create([
                        'course_module_id' => $module->id,
                        'title_ar' => 'الدرس ' . $l . ': ' . ['مقدمة', 'شرح نظري', 'أمثلة تطبيقية', 'تمارين محلولة'][rand(0, 3)],
                        'description_ar' => 'شرح مفصل للدرس مع أمثلة توضيحية',
                        'video_type' => 'youtube',
                        'video_url' => 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
                        'video_duration_seconds' => rand(600, 2700),
                        'has_pdf' => rand(0, 1),
                        'pdf_path' => rand(0, 1) ? 'courses/pdfs/sample.pdf' : null,
                        'order' => $l,
                        'is_preview' => $l == 1,
                    ]);
                }
            }

            // Create reviews for published courses
            if ($course->is_published) {
                $studentsCollection = collect($students);
                $reviewCount = min(rand(5, 15), $studentsCollection->count());
                $reviewers = $studentsCollection->random($reviewCount);

                foreach ($reviewers as $reviewer) {
                    CourseReview::create([
                        'course_id' => $course->id,
                        'user_id' => $reviewer->id,
                        'rating' => rand(3, 5),
                        'review_text_ar' => 'دورة ممتازة وشرح واضح ومفيد جداً. أنصح بها بشدة لكل الطلاب.',
                        'is_approved' => rand(1, 10) > 2, // 80% approved
                    ]);
                }
            }
        }

        // Create 6 Subscription Packages
        $packages = [];
        $packageData = [
            [
                'name' => 'الباقة الأساسية',
                'description' => 'باقة تحتوي على 3 دورات أساسية للمبتدئين',
                'price' => 25000,
                'duration' => 90,
                'courses' => 3
            ],
            [
                'name' => 'الباقة المتوسطة',
                'description' => 'باقة شاملة تحتوي على 5 دورات متنوعة',
                'price' => 40000,
                'duration' => 120,
                'courses' => 5
            ],
            [
                'name' => 'الباقة الذهبية',
                'description' => 'باقة متميزة تحتوي على 7 دورات مع مزايا إضافية',
                'price' => 55000,
                'duration' => 180,
                'courses' => 7
            ],
            [
                'name' => 'باقة البكالوريا',
                'description' => 'باقة خاصة بطلاب البكالوريا تحتوي على جميع المواد الأساسية',
                'price' => 70000,
                'duration' => 270,
                'courses' => 10
            ],
            [
                'name' => 'الباقة الشاملة',
                'description' => 'الوصول الكامل لجميع الدورات المتاحة',
                'price' => 100000,
                'duration' => 365,
                'courses' => 12
            ],
            [
                'name' => 'باقة التجريبية',
                'description' => 'باقة تجريبية لمدة شهر مع دورتين',
                'price' => 15000,
                'duration' => 30,
                'courses' => 2
            ],
        ];

        foreach ($packageData as $index => $data) {
            $package = SubscriptionPackage::create([
                'name_ar' => $data['name'],
                'description_ar' => $data['description'],
                'price_dzd' => $data['price'],
                'duration_days' => $data['duration'],
            ]);

            // Attach random courses to package using raw inserts to avoid relationship issues
            $coursesCollection = collect($courses);
            $packageCourseCount = min($data['courses'], $coursesCollection->count());
            $packageCourses = $coursesCollection->random($packageCourseCount);

            foreach ($packageCourses as $packageCourse) {
                \DB::table('package_courses')->insert([
                    'package_id' => $package->id,
                    'course_id' => $packageCourse->id,
                ]);
            }

            $packages[] = $package;
        }

        // Create Subscription Codes
        $codes = [];

        $coursesCollection = collect($courses);
        $packagesCollection = collect($packages);

        for ($i = 0; $i < 30; $i++) {
            $hasCourse = rand(0, 1);
            $code = SubscriptionCode::create([
                'code' => strtoupper(Str::random(8)),
                'course_id' => $hasCourse && $coursesCollection->isNotEmpty() ? $coursesCollection->random()->id : null,
                'package_id' => !$hasCourse && $packagesCollection->isNotEmpty() ? $packagesCollection->random()->id : null,
                'max_uses' => rand(1, 10),
                'current_uses' => rand(0, 5),
                'expires_at' => rand(0, 1) ? now()->addDays(rand(30, 180)) : null,
                'is_active' => rand(0, 10) > 1, // 90% active
                'created_by' => $admin->id,
            ]);
            $codes[] = $code;
        }

        // Create Payment Receipts and Subscriptions (only for courses, not packages)
        $statuses = ['pending', 'approved', 'rejected'];
        $paymentMethods = ['bank_transfer', 'ccp', 'baridimob'];

        foreach ($students as $student) {
            // Each student has 1-2 course subscriptions
            $count = rand(1, 2);

            for ($i = 0; $i < $count; $i++) {
                if ($coursesCollection->isEmpty()) {
                    continue;
                }

                $selectedCourse = $coursesCollection->random();
                $amount = $selectedCourse->price_dzd;

                // Create payment receipt (70% of subscriptions)
                if (rand(1, 10) <= 7 && $amount > 0) {
                    $status = $statuses[array_rand($statuses)];

                    $receipt = PaymentReceipt::create([
                        'user_id' => $student->id,
                        'course_id' => $selectedCourse->id,
                        'receipt_image_url' => 'receipts/dummy_receipt_' . rand(1000, 9999) . '.jpg',
                        'amount_dzd' => $amount,
                        'payment_method' => $paymentMethods[array_rand($paymentMethods)],
                        'status' => $status,
                        'admin_note' => $status === 'rejected' ? 'الإيصال غير واضح، يرجى رفع صورة أوضح' : null,
                        'reviewed_at' => $status !== 'pending' ? now()->subDays(rand(0, 10)) : null,
                        'reviewed_by' => $status !== 'pending' ? $admin->id : null,
                    ]);

                    // Create subscription if approved
                    if ($status === 'approved') {
                        UserSubscription::create([
                            'user_id' => $student->id,
                            'course_id' => $selectedCourse->id,
                            'activated_by' => 'receipt',
                            'receipt_id' => $receipt->id,
                            'activated_at' => now()->subDays(rand(1, 60)),
                            'expires_at' => now()->addDays($selectedCourse->duration_days ?? 60),
                            'is_active' => now()->addDays($selectedCourse->duration_days ?? 60) > now(),
                        ]);
                    }
                } else {
                    // Create subscription via code
                    $codesCollection = collect($codes);
                    if ($amount > 0 && $codesCollection->isNotEmpty()) {
                        UserSubscription::create([
                            'user_id' => $student->id,
                            'course_id' => $selectedCourse->id,
                            'activated_by' => 'code',
                            'code_id' => $codesCollection->random()->id,
                            'activated_at' => now()->subDays(rand(1, 90)),
                            'expires_at' => now()->addDays(rand(-30, 120)),
                            'is_active' => rand(0, 10) > 3, // 70% active
                        ]);
                    }
                }
            }
        }

        $this->command->info('✅ Test data created successfully!');
        $this->command->info('📚 Created ' . count($courses) . ' courses');
        $this->command->info('📦 Created ' . count($packages) . ' packages');
        $this->command->info('🎟️ Created ' . count($codes) . ' subscription codes');
        $this->command->info('👥 Created ' . count($students) . ' test students');
        $this->command->info('📄 Created payment receipts and subscriptions');
    }
}
