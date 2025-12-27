# دورة تحفيض - Course Import Script

## Instructions

1. Run the PowerShell script to move videos to storage
2. Copy the seeder file to: `memo_api/database/seeders/TahfidCourseSeeder.php`
3. Run: `php artisan storage:link` (if not already done)
4. Run: `php artisan db:seed --class=TahfidCourseSeeder`

---

## Step 1: PowerShell Script to Move Videos

Save this as `move_videos.ps1` and run it from `memo_api` folder:

```powershell
# move_videos.ps1 - Run from memo_api folder
# Usage: powershell -ExecutionPolicy Bypass -File move_videos.ps1

$source = "H:\Nouveau dossier (27)\his"
$dest = ".\storage\app\public\courses\videos\tahfid"

# Create destination folder
New-Item -ItemType Directory -Force -Path $dest | Out-Null

Write-Host "Moving videos from $source to $dest..." -ForegroundColor Cyan

# Copy all subfolders with videos
$folders = @(
    "دروس التاريخ",
    "دروس الجغرافيا",
    "شخصيات التاريخ",
    "مصطلحات التاريخ",
    "مصطلحات الجغرافيا",
    "تواريخ"
)

foreach ($folder in $folders) {
    $sourcePath = Join-Path $source $folder
    $destPath = Join-Path $dest $folder

    if (Test-Path $sourcePath) {
        Write-Host "Copying: $folder" -ForegroundColor Green
        Copy-Item -Path $sourcePath -Destination $destPath -Recurse -Force
    } else {
        Write-Host "Not found: $folder" -ForegroundColor Yellow
    }
}

Write-Host "`nDone! Videos copied to: $dest" -ForegroundColor Cyan
Write-Host "Now run: php artisan storage:link" -ForegroundColor Yellow
Write-Host "Then run: php artisan db:seed --class=TahfidCourseSeeder" -ForegroundColor Yellow
```

---

## Step 2: Seeder File

Save this as `database/seeders/TahfidCourseSeeder.php`:

```php
<?php

namespace Database\Seeders;

use App\Models\Course;
use App\Models\CourseModule;
use App\Models\CourseLesson;
use Illuminate\Database\Seeder;
use Illuminate\Support\Str;

class TahfidCourseSeeder extends Seeder
{
    private $baseVideoPath = '/storage/courses/videos/tahfid';

    public function run(): void
    {
        // Create the main course
        $course = Course::create([
            'subject_id' => null,
            'title_ar' => 'دورة تحفيض',
            'slug' => 'dawra-tahfid-' . Str::random(6),
            'description_ar' => 'دورة شاملة في التاريخ والجغرافيا تتضمن دروس، شخصيات، مصطلحات وتواريخ مهمة',
            'short_description_ar' => 'دورة تحفيض في التاريخ والجغرافيا',
            'thumbnail_url' => null,
            'trailer_video_url' => null,
            'price_dzd' => 2000.00,
            'is_free' => false,
            'requires_subscription' => true,
            'duration_days' => 365,
            'instructor_name' => 'الأستاذ',
            'instructor_bio_ar' => 'أستاذ متخصص في التاريخ والجغرافيا',
            'total_modules' => 10,
            'total_lessons' => 0,
            'is_published' => false,
            'is_featured' => false,
        ]);

        $this->command->info("Created course: دورة تحفيض (ID: {$course->id})");

        $moduleOrder = 1;
        $totalLessons = 0;

        // ========================================
        // MODULE 1: بروز الصراع وتشكل العالم
        // ========================================
        $module1 = CourseModule::create([
            'course_id' => $course->id,
            'title_ar' => 'بروز الصراع وتشكل العالم',
            'description_ar' => 'دروس حول بروز الصراع وتشكل العالم بعد الحرب العالمية الثانية',
            'order' => $moduleOrder++,
            'is_published' => false,
        ]);

        $lessons1 = [
            ['title' => 'التاريخية و السياسية', 'file' => '1-التاريخية و السياسية.mp4'],
            ['title' => 'الاجتماعية و الاقتصادية', 'file' => '2-الاجتماعية و الاقتصادية.mp4'],
            ['title' => 'العلمية و التكنولوجيا', 'file' => '3-العلمية و التكنولوجيا.mp4'],
            ['title' => 'طبيعة العلاقات بين الكتلتين', 'file' => '4-طبيعة العلاقات بين الكتلتين.mp4'],
            ['title' => 'اسباب صراع الحرب الباردة', 'file' => '5-اسباب صراع الحرب الباردة.mp4'],
            ['title' => 'الاستراتيجيات الاقتصادية للكتلة الغربية', 'file' => '6-الاستراتيجيات الاقتصادية للكتلة الغربية.mp4'],
            ['title' => 'المشاريع الاقتصادية', 'file' => '7-المشاريع الاقتصادية.mp4'],
            ['title' => 'سياسة انشاء الاحلاف العسكرية', 'file' => '8-سياسة انشاء الاحلاف العسكرية (2).mp4'],
            ['title' => 'الاستراتيجيات الاقتصادية', 'file' => '9-الاستراتيجيات الاقتصادية.mp4'],
            ['title' => 'استراتيجية الكتلة الشرقية الاقتصادية', 'file' => '10-استراتيجية الكتلة الشرقية الاقتصادية.mp4'],
            ['title' => 'العسكرية', 'file' => '11-العسكرية.mp4'],
            ['title' => 'نتائج الصراع على العالم الثالث', 'file' => '12-نتائج الصراع على العالم الثالث.mp4'],
            ['title' => 'نتائج الصراع على قارة اوروبا', 'file' => 'نتائج الصراع على قارة اوروبا.mp4'],
        ];
        $totalLessons += $this->createLessonsWithVideos($module1, $lessons1, 'دروس التاريخ/1-بروز الصراع وتشكل العالم');

        // ========================================
        // MODULE 2: الازمات الدولية
        // ========================================
        $module2 = CourseModule::create([
            'course_id' => $course->id,
            'title_ar' => 'الازمات الدولية',
            'description_ar' => 'دروس حول الأزمات الدولية خلال الحرب الباردة',
            'order' => $moduleOrder++,
            'is_published' => false,
        ]);

        $lessons2 = [
            ['title' => 'الازمات الدولية ازمة برلين', 'file' => '1-الازمات الدوية ازمة برلين.mp4'],
            ['title' => 'ازمة برلين الثانية', 'file' => '2-ازمة برلين الثانية.mp4'],
            ['title' => 'ازمة الكوريتين', 'file' => '3-ازمة الكوريتين.mp4'],
            ['title' => 'ازمة السويس', 'file' => '4-ازمة السويس.mp4'],
        ];
        $totalLessons += $this->createLessonsWithVideos($module2, $lessons2, 'دروس التاريخ/2-الازمات الدولية');

        // ========================================
        // MODULE 3: مساعي الانفراج الدولي
        // ========================================
        $module3 = CourseModule::create([
            'course_id' => $course->id,
            'title_ar' => 'مساعي الانفراج الدولي',
            'description_ar' => 'دروس حول مساعي الانفراج الدولي والتعايش السلمي',
            'order' => $moduleOrder++,
            'is_published' => false,
        ]);

        $lessons3 = [
            ['title' => 'عوامل ظهور سياسة التعايش السلمي', 'file' => '2-عوامل ظهور سياسة التعايش السلمي.mp4'],
            ['title' => 'مظاهر التعايش السلمي', 'file' => '3-مظاهر التعايش السلمي.mp4'],
            ['title' => 'نتائج سياسة التعايش السلمي', 'file' => '4-نتائج سياسة التعايش السلمي.mp4'],
            ['title' => 'دور حركة عدم الانحياز في تجسيد الانفراج الدولي', 'file' => '5-دور جركة عدم الانحياز في تجسيد الانفراج الدولي.mp4'],
            ['title' => 'دور الحركة في قضايا التحرر في العالم', 'file' => '6-دور الحركة في قضايا التحرر في العالم.mp4'],
            ['title' => 'مطالب حركة عدم الانحياز قبل مؤتمر الجزائر', 'file' => '7- مطالب حركة عدم الانحياز قبل مؤتمر الجزائر.mp4'],
            ['title' => 'مطالب حركة عدم الانحياز بعد مؤتمر الجزائر', 'file' => '8-مطالب حركة عدم الانحياز بعد مؤتمر الجزائر.mp4'],
            ['title' => 'مبادئ الحركة خلال مؤتمر باندونغ', 'file' => '9-مبادئ الحركة خلال مؤتمر باندونغ.mp4'],
        ];
        $totalLessons += $this->createLessonsWithVideos($module3, $lessons3, 'دروس التاريخ/3-مساعي الانفراج الدولي');

        // ========================================
        // MODULE 4: من الثنائية الى الاحادية القطبية
        // ========================================
        $module4 = CourseModule::create([
            'course_id' => $course->id,
            'title_ar' => 'من الثنائية الى الاحادية القطبية',
            'description_ar' => 'دروس حول تفكك الكتلة الشرقية والنظام الدولي الجديد',
            'order' => $moduleOrder++,
            'is_published' => false,
        ]);

        $lessons4 = [
            ['title' => 'عوامل تفكك الكتلة الشرقية الداخلية', 'file' => '1-عوامل تفكك الكتلة الشرقية الداخلية.mp4'],
            ['title' => 'الاهداف الخفية', 'file' => '5-الاهداف الخفية.mp4'],
            ['title' => 'مظاهر النظام الدولي الجديد', 'file' => '6-مظاهر النظام الدولي الجديد.mp4'],
            ['title' => 'انعكاساته على العالم الثالث', 'file' => '7-انعكاساته على العالم الثالث.mp4'],
        ];
        $totalLessons += $this->createLessonsWithVideos($module4, $lessons4, 'دروس التاريخ/4-من الثنائية الى الاحادية القطبية');

        // ========================================
        // MODULE 5: اشكالية التقدم و التخلف
        // ========================================
        $module5 = CourseModule::create([
            'course_id' => $course->id,
            'title_ar' => 'اشكالية التقدم و التخلف',
            'description_ar' => 'دروس حول معايير التقدم والتخلف وتصنيف الدول',
            'order' => $moduleOrder++,
            'is_published' => false,
        ]);

        $lessons5 = [
            ['title' => 'معايير اجتماعية و ثقافية', 'file' => '2-معايير اجتماعية و ثقافية.mp4'],
            ['title' => 'معايير سياسية', 'file' => '3-معايير سياسية.mp4'],
            ['title' => 'عوامل التقدم', 'file' => '4-عوامل التقدم.mp4'],
            ['title' => 'تصنيف الدول المتقدمة', 'file' => '6-تصنيف الدول المتقدمة.mp4'],
            ['title' => 'تصنيف الدول المتخلفة', 'file' => '7-تصنيف الدول المتخلفة.mp4'],
        ];
        $totalLessons += $this->createLessonsWithVideos($module5, $lessons5, 'دروس الجغرافيا/1-اشكالية التقدم و التخلف');

        // ========================================
        // MODULE 6: المبادلات و التنقلات في العالم
        // ========================================
        $module6 = CourseModule::create([
            'course_id' => $course->id,
            'title_ar' => 'المبادلات و التنقلات في العالم',
            'description_ar' => 'دروس حول المبادلات التجارية والتنقلات العالمية',
            'order' => $moduleOrder++,
            'is_published' => false,
        ]);

        $lessons6 = [
            ['title' => 'العوامل المتحكمة في اسعار المواد الاستراتيجية الخام', 'file' => '1-العوامل المتحكمة في اسعار المواد الاستراتيجية الخام.mp4'],
            ['title' => 'المواد الاستراتيجية الغذائية', 'file' => '2-المواد الاستراتيجية الغذائية.mp4'],
            ['title' => 'اهمية المواد الاستراتيجية الخام', 'file' => '3-اهمية المواد الاستراتيجية الخام.mp4'],
            ['title' => 'اهمية المواد الاستراتيجية الغذائية', 'file' => '4-اهمية المواد الاستراتيجية الغذائية.mp4'],
            ['title' => 'اهداف منظمة الاوبيك', 'file' => '5-اهداف منظمة الاوبيك.mp4'],
            ['title' => 'المشاكل التي تواجهها', 'file' => '6-المشاكل التي تواجهها.mp4'],
            ['title' => 'اثر تراجع اسعار البترول على الدول المصدرة', 'file' => '7-اثر تراجع اسعار البترول على الدول المصدرة.mp4'],
            ['title' => 'واقع حركة رؤوس الاموال ودور الاعلام والتكنولوجيا', 'file' => '8-واقع حركة رؤوس الاموال و دور الاعلام و التكنولوجيا في المبادلات.mp4'],
            ['title' => 'اهمية حركة رؤوس الاموال', 'file' => '9-اهمية حركة رؤوس الاموال.mp4'],
            ['title' => 'دور الاعلام و التكنولوجيا في المبادلات', 'file' => '10- دور الاعلام و التكنولوجيا في المبادلات.mp4'],
        ];
        $totalLessons += $this->createLessonsWithVideos($module6, $lessons6, 'دروس الجغرافيا/2-المبادلات و التنقلات في العالم');

        // ========================================
        // MODULE 7: شخصيات التاريخ
        // ========================================
        $module7 = CourseModule::create([
            'course_id' => $course->id,
            'title_ar' => 'شخصيات التاريخ',
            'description_ar' => 'شخصيات تاريخية مهمة من فترة الحرب الباردة',
            'order' => $moduleOrder++,
            'is_published' => false,
        ]);

        $lessons7 = [
            ['title' => 'نيكيتا خروتشوف', 'file' => '1-نيكيتا  خروتشوف.mp4'],
            ['title' => 'مالينكوف', 'file' => '2-مالينكوف.mp4'],
            ['title' => 'بولغانين', 'file' => '3-بولغانين.mp4'],
            ['title' => 'جوزيف ستالين', 'file' => '4-جوزيف ستالين.mp4'],
            ['title' => 'اندري جدانوف', 'file' => '5-اندري جدانوف.mp4'],
            ['title' => 'ليونيد بريجنيف', 'file' => '6-ليونيد بريجنيف.mp4'],
            ['title' => 'ميخائيل غورباتشوف', 'file' => '6-ميخائيل غورباتشوف.mp4'],
            ['title' => 'فرانكلين روزفلت', 'file' => '7-فرانكلين روزفلت.mp4'],
            ['title' => 'هاري ترومان', 'file' => '8-هاري ترومان.mp4'],
            ['title' => 'ايزنهاور', 'file' => '9-ايزنهاور.mp4'],
            ['title' => 'جيمي كارتر', 'file' => '10-جيمي كارتر.mp4'],
            ['title' => 'رونالد ريغن', 'file' => '11-رونالد ريغن.mp4'],
            ['title' => 'جورج مارشال', 'file' => '12-جورج مارشال.mp4'],
            ['title' => 'ونستون تشرتشل', 'file' => '13-ونستون تشرتشل.mp4'],
            ['title' => 'جوزيف بروز تيتو', 'file' => '14-جوزيف بروز تيتو.mp4'],
            ['title' => 'جورج بوش الاب', 'file' => '15-جورج بوش الاب.mp4'],
        ];
        $totalLessons += $this->createLessonsWithVideos($module7, $lessons7, 'شخصيات التاريخ');

        // ========================================
        // MODULE 8: مصطلحات التاريخ
        // ========================================
        $module8 = CourseModule::create([
            'course_id' => $course->id,
            'title_ar' => 'مصطلحات التاريخ',
            'description_ar' => 'مصطلحات تاريخية أساسية',
            'order' => $moduleOrder++,
            'is_published' => false,
        ]);

        $lessons8 = [
            ['title' => 'الحرب العالمية الثانية', 'file' => '1-الحرب العالمية الثانية.mp4'],
            ['title' => 'ازمة كوبا', 'file' => 'ازمة كوبا.mp4'],
            ['title' => 'الازمات الدولية', 'file' => 'الازمات الدولية.mp4'],
            ['title' => 'الاستعمار التقليدي', 'file' => 'الاستعمار التقليدي.mp4'],
            ['title' => 'الامبريالية', 'file' => 'الامبريالية.mp4'],
            ['title' => 'الانفراج الدولي', 'file' => 'الانفراج الدولي.mp4'],
            ['title' => 'البروسترويكا و الغلاسنوست', 'file' => 'البروسترويكا و الغلاسنوست.mp4'],
            ['title' => 'التعايش السلمي', 'file' => 'التعايش السلمي.mp4'],
            ['title' => 'التوازن الدولي', 'file' => 'التوازن الدولي.mp4'],
            ['title' => 'الثنائية القطبية', 'file' => 'الثنائية القطبية.mp4'],
            ['title' => 'الجيش الاحمر', 'file' => 'الجيش الاحمر.mp4'],
            ['title' => 'الحرب الباردة', 'file' => 'الحرب الباردة.mp4'],
            ['title' => 'الحرب النووية', 'file' => 'الحرب النووية.mp4'],
            ['title' => 'الحلف الاطلسي', 'file' => 'الحلف الاطلسي.mp4'],
            ['title' => 'الحياد الايجابي', 'file' => 'الحياد الايجابي.mp4'],
            ['title' => 'الخطر الشيوعي', 'file' => 'الخطر الشيوعي.mp4'],
            ['title' => 'الديكتاتورية', 'file' => 'الديكتاتورية.mp4'],
            ['title' => 'الراسمالية', 'file' => 'الراسمالية.mp4'],
            ['title' => 'الشرعية الدولية', 'file' => 'الشرعية الدولية.mp4'],
            ['title' => 'الصراع الايديولوجي', 'file' => 'الصراع الايديولوجي.mp4'],
            ['title' => 'الصراع حول النفوذ', 'file' => 'الصراع حول النفوذ.mp4'],
            ['title' => 'العالم الثالث', 'file' => 'العالم الثالث.mp4'],
            ['title' => 'العدوان الثلاثي على مصر', 'file' => 'العدوان الثلاثي على مصر.mp4'],
            ['title' => 'العلاقات الدولية', 'file' => 'العلاقات الدولية.mp4'],
            ['title' => 'الكتلتين', 'file' => 'الكتلتين.mp4'],
            ['title' => 'الكومنفورم', 'file' => 'الكومنفورم.mp4'],
            ['title' => 'الكومنولث', 'file' => 'الكومنولث.mp4'],
            ['title' => 'الليبيرالية', 'file' => 'الليبيرالية.mp4'],
            ['title' => 'المجال الحيوي', 'file' => 'المجال الحيوي.mp4'],
            ['title' => 'المنظمات غير الحكومية', 'file' => 'المنظمات غير الحكومية.mp4'],
            ['title' => 'النظام الدولي الجديد', 'file' => 'النظام الدولي الجديد.mp4'],
            ['title' => 'تقرير المصير', 'file' => 'تقرير المصير.mp4'],
            ['title' => 'جدار برلين', 'file' => 'جدار برلين.mp4'],
            ['title' => 'حركة عدم الانحياز', 'file' => 'حركة عدم الانحياز.mp4'],
            ['title' => 'حلف جنوب شرق اسيا', 'file' => 'حلف جنوب شرق اسيا.mp4'],
            ['title' => 'حلف وارسو', 'file' => 'حلف وارسو.mp4'],
            ['title' => 'دول المحور', 'file' => 'دول المحور.mp4'],
            ['title' => 'سياسة الاحلاف', 'file' => 'سياسة الاحلاف.mp4'],
            ['title' => 'سياسة التسلح', 'file' => 'سياسة التسلح.mp4'],
            ['title' => 'سياسة التكتل', 'file' => 'سياسة التكتل.mp4'],
            ['title' => 'سياسة المشاريع', 'file' => 'سياسة المشاريع.mp4'],
            ['title' => 'سياسة ملا الفراغ', 'file' => 'سياسة ملا الفراغ.mp4'],
            ['title' => 'عالم الجنوب', 'file' => 'عالم الجنوب.mp4'],
            ['title' => 'عالم الشمال', 'file' => 'عالم الشمال.mp4'],
            ['title' => 'مؤتمر بوتسدام', 'file' => 'مؤتمر بوتسدام.mp4'],
            ['title' => 'مؤتمر يالطا', 'file' => 'مؤتمر يالطا.mp4'],
            ['title' => 'مجلس الامن', 'file' => 'مجلس الامن.mp4'],
            ['title' => 'مشروع ايزنهاور', 'file' => 'مشروع ايزنهاور.mp4'],
            ['title' => 'مشروع مارشال', 'file' => 'مشروع مارشال.mp4'],
            ['title' => 'منظمة الكوميكون', 'file' => 'منظمة الكوميكون.mp4'],
            ['title' => 'هيئة الامم المتحدة', 'file' => 'هيئة الامم المتحدة.mp4'],
        ];
        $totalLessons += $this->createLessonsWithVideos($module8, $lessons8, 'مصطلحات التاريخ');

        // ========================================
        // MODULE 9: مصطلحات الجغرافيا
        // ========================================
        $module9 = CourseModule::create([
            'course_id' => $course->id,
            'title_ar' => 'مصطلحات الجغرافيا',
            'description_ar' => 'مصطلحات جغرافية واقتصادية أساسية',
            'order' => $moduleOrder++,
            'is_published' => false,
        ]);

        $lessons9 = [
            ['title' => 'تبييض الاموال', 'file' => '1-تبييض الاموال.mp4'],
            ['title' => 'اقتصاد السوق', 'file' => 'اقتصاد السوق.mp4'],
            ['title' => 'الاتحاد', 'file' => 'الاتحاد.mp4'],
            ['title' => 'الاستثمار', 'file' => 'الاستثمار.mp4'],
            ['title' => 'الاسهم', 'file' => 'الاسهم.mp4'],
            ['title' => 'الاعلام', 'file' => 'الاعلام.mp4'],
            ['title' => 'الاقتصاد الموجه', 'file' => 'الاقتصاد الموجه.mp4'],
            ['title' => 'الاكتفاء الذاتي', 'file' => 'الاكتفاء الذاتي.mp4'],
            ['title' => 'الامن الغذائي', 'file' => 'الامن الغذائي.mp4'],
            ['title' => 'البرميل', 'file' => 'البرميل.mp4'],
            ['title' => 'البورصة', 'file' => 'البورصة.mp4'],
            ['title' => 'التخلف', 'file' => 'التخلف.mp4'],
            ['title' => 'التضخم', 'file' => 'التضخم.mp4'],
            ['title' => 'التقدم', 'file' => 'التقدم.mp4'],
            ['title' => 'التكتلات الاقتصادية', 'file' => 'التكتلات الاقتصادية.mp4'],
            ['title' => 'التكنولوجيا', 'file' => 'التكنولوجيا.mp4'],
            ['title' => 'التنمية', 'file' => 'التنمية.mp4'],
            ['title' => 'الحواجز الجمركية', 'file' => 'الحواجز الجمركية.mp4'],
            ['title' => 'الخوصصة', 'file' => 'الخوصصة.mp4'],
            ['title' => 'الدخل الفردي', 'file' => 'الدخل الفردي.mp4'],
            ['title' => 'الدول الصاعدة', 'file' => 'الدول الصاعدة.mp4'],
            ['title' => 'الدول النامية', 'file' => 'الدول نامية.mp4'],
            ['title' => 'السلاح الاخضر', 'file' => 'السلاح الاخضر.mp4'],
            ['title' => 'السندات', 'file' => 'السندات.mp4'],
            ['title' => 'الشركات الاحتكارية', 'file' => 'الشركات الاحتكارية.mp4'],
            ['title' => 'الشركات متعددة الجنسيات', 'file' => 'الشركات متعددة الجنسيات.mp4'],
            ['title' => 'الشركات', 'file' => 'الشركات.mp4'],
            ['title' => 'الصناعة التحويلية', 'file' => 'الصناعة التحويلية.mp4'],
            ['title' => 'العملة الصعبة', 'file' => 'العملة الصعبة.mp4'],
            ['title' => 'العملة', 'file' => 'العملة.mp4'],
            ['title' => 'الفوائد', 'file' => 'الفوائد.mp4'],
            ['title' => 'القروض', 'file' => 'القروض.mp4'],
            ['title' => 'القطاع الخاص', 'file' => 'القطاع الخاص.mp4'],
            ['title' => 'القطاع العام', 'file' => 'القطاع العام.mp4'],
            ['title' => 'المؤشر', 'file' => 'المؤشر.mp4'],
            ['title' => 'المبادلات التجارية', 'file' => 'المبادلات التجارية.mp4'],
            ['title' => 'المضاربة', 'file' => 'المضاربة.mp4'],
            ['title' => 'المعيار', 'file' => 'المعيار.mp4'],
            ['title' => 'المناطق الحرة', 'file' => 'المناطق الحرة.mp4'],
            ['title' => 'المواد الاولية الطاقوية', 'file' => 'المواد الاولية الطاقوية.mp4'],
            ['title' => 'الميزان التجاري', 'file' => 'الميزان التجاري.mp4'],
            ['title' => 'الناتج المحلي الخام', 'file' => 'الناتج المحلي الخام.mp4'],
            ['title' => 'الناتج الوطني الخام', 'file' => 'الناتج الوطني الخام.mp4'],
            ['title' => 'النمو الاقتصادي', 'file' => 'النمو الاقتصادي.mp4'],
            ['title' => 'رؤوس الاموال', 'file' => 'رؤوس الاموال.mp4'],
            ['title' => 'صندوق النقد الدولي', 'file' => 'صندوق النقد الدولي.mp4'],
            ['title' => 'مؤشر التنمية البشرية', 'file' => 'مؤشر التنمية البشرية.mp4'],
            ['title' => 'منظمة الاوبيك', 'file' => 'منظمة الاوبيك.mp4'],
            ['title' => 'ميزان المدفوعات', 'file' => 'ميزان المدفوعات.mp4'],
        ];
        $totalLessons += $this->createLessonsWithVideos($module9, $lessons9, 'مصطلحات الجغرافيا');

        // ========================================
        // MODULE 10: تواريخ مهمة
        // ========================================
        $module10 = CourseModule::create([
            'course_id' => $course->id,
            'title_ar' => 'تواريخ مهمة',
            'description_ar' => 'تواريخ وأحداث تاريخية مهمة',
            'order' => $moduleOrder++,
            'is_published' => false,
        ]);

        $lessons10 = [
            ['title' => 'فيديو تعريفي مبدا ترومان', 'file' => '1 فيديو تعريفي مبدا ترومان.mp4'],
            ['title' => 'اتفاقية سالت الاولى', 'file' => 'اتفاقية سالت الاولى.mp4'],
            ['title' => 'اتفاقية سالت الثانية', 'file' => 'اتفاقية سالت الثانية.mp4'],
            ['title' => 'استقالة غورباتشوف', 'file' => 'استقالة غورباتشوف.mp4'],
            ['title' => 'الحصار الاقتصادي الامريكي على كوبا', 'file' => 'الحصار الاقتصادي الامريكي على كوبا.mp4'],
            ['title' => 'الحصار العسكري الامريكي على كوبا', 'file' => 'الحصار العسكري الامريكي على كوبا.mp4'],
            ['title' => 'المؤتمر الاسلامي', 'file' => 'المؤتمر الاسلامي.mp4'],
            ['title' => 'اندلاع الحرب الكورية', 'file' => 'اندلاع الحرب الكورية.mp4'],
            ['title' => 'انشاء الخط الهاتفي الاحمر', 'file' => 'انشاء الخط الهاتفي الاحمر.mp4'],
            ['title' => 'انشاء جسر جوي لبرلين', 'file' => 'انشاء جسر جوي لبرلين.mp4'],
            ['title' => 'انشاء مكتب الكومنفورم', 'file' => 'انشاء مكتب الكومنفورم.mp4'],
            ['title' => 'بناء جدار برلين', 'file' => 'بناء جدار برلين.mp4'],
            ['title' => 'تاسيس المانيا الشرقية الشيوعية', 'file' => 'تاسيس المانيا الشرقية الشيوعية.mp4'],
            ['title' => 'تاسيس المانيا الغربية الراسمالية', 'file' => 'تاسيس المانيا الغربية الراسمالية.mp4'],
            ['title' => 'تاسيس حلف الشمال الاطلسي', 'file' => 'تاسيس حلف الشمال الاطلسي.mp4'],
            ['title' => 'تاسيس حلف سياتو', 'file' => 'تاسيس حلف سياتو.mp4'],
            ['title' => 'تاسيس منظمة الكوميكون', 'file' => 'تاسيس منظمة الكوميكون.mp4'],
            ['title' => 'تدخل السوفيات عسكريا في افغانستان', 'file' => 'تدخل السوفيات عسكريا في افغنستان.mp4'],
            ['title' => 'حصار السوفيات لبرلين', 'file' => 'حصار السوفيات لبرلين.mp4'],
            ['title' => 'حل الحزب الشيوعي السوفياتي', 'file' => 'حل الحزب الشيوعي السوفياتي.mp4'],
            ['title' => 'حل حلف وارسو', 'file' => 'حل حلف وارسو.mp4'],
            ['title' => 'حل مكتب الكومنفورم', 'file' => 'حل مكتب الكومنفورم.mp4'],
            ['title' => 'حل منظمة الكوميكون', 'file' => 'حل منظمة الكويميكون.mp4'],
            ['title' => 'رفع الحصار عن برلين', 'file' => 'رفع الحصار عن برلين.mp4'],
            ['title' => 'زيارة خروتشوف لواشنطن', 'file' => 'زيارة خروتشوف لواشنطن.mp4'],
            ['title' => 'سياسة التعايش السلمي', 'file' => 'سياسة التعايش السلمي.mp4'],
            ['title' => 'مؤتمر مالطا', 'file' => 'مؤتمر مالطا.mp4'],
            ['title' => 'مبدا جدانوف', 'file' => 'مبدا جدانوف.mp4'],
            ['title' => 'مشروع مارشال', 'file' => 'مشروع مارشال.mp4'],
            ['title' => 'نجاح الثورة الشيوعية الصينية', 'file' => 'نجاح الثورة الشيوعية الصينية.mp4'],
            ['title' => 'نهاية الحرب الباردة', 'file' => 'نهاية الحرب الباردة.mp4'],
            ['title' => 'نهاية الحرب الكورية', 'file' => 'نهاية الحرب الكورية.mp4'],
        ];
        $totalLessons += $this->createLessonsWithVideos($module10, $lessons10, 'تواريخ');

        // Update course totals
        $course->update([
            'total_lessons' => $totalLessons,
            'total_modules' => $moduleOrder - 1,
        ]);

        $this->command->info("\n=== DONE ===");
        $this->command->info("Total lessons created: {$totalLessons}");
        $this->command->info("Total modules created: " . ($moduleOrder - 1));
        $this->command->info("Course ID: {$course->id}");
    }

    private function createLessonsWithVideos(CourseModule $module, array $lessons, string $folder): int
    {
        $order = 1;
        foreach ($lessons as $lesson) {
            $videoUrl = $this->baseVideoPath . '/' . $folder . '/' . $lesson['file'];

            CourseLesson::create([
                'course_module_id' => $module->id,
                'title_ar' => $lesson['title'],
                'description_ar' => $lesson['title'],
                'order' => $order++,
                'video_type' => 'upload',
                'video_url' => $videoUrl,
                'video_duration_seconds' => 0,
                'has_pdf' => false,
                'is_preview' => false,
                'is_published' => false,
            ]);
        }

        $this->command->info("  Created " . count($lessons) . " lessons in module: {$module->title_ar}");
        return count($lessons);
    }
}
```

---

## Summary

| Item | Count |
|------|-------|
| Total Modules | 10 |
| Total Lessons | ~150+ |
| Course Price | 2000 DZD |
| Course Status | Unpublished (set to published after review) |

---

## Execution Steps

```powershell
# 1. Navigate to memo_api folder
cd "H:\Nouveau dossier (27)\memo_api"

# 2. Create the move_videos.ps1 file with the script above, then run:
powershell -ExecutionPolicy Bypass -File move_videos.ps1

# 3. Create symbolic link for storage (if not already done)
php artisan storage:link

# 4. Run the seeder
php artisan db:seed --class=TahfidCourseSeeder

# 5. Verify in database
php artisan tinker
>>> App\Models\Course::where('title_ar', 'دورة تحفيض')->first()
```

---

## Video URL Access

After running `php artisan storage:link`, videos will be accessible at:
```
http://your-domain/storage/courses/videos/tahfid/{folder}/{filename}.mp4
```

Example:
```
http://your-domain/storage/courses/videos/tahfid/دروس التاريخ/1-بروز الصراع وتشكل العالم/1-التاريخية و السياسية.mp4
```
