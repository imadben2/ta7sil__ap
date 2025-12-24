# 🎓 Courses Feature - الدورات المدفوعة

## 📋 Overview

Feature شاملة للدورات التعليمية المدفوعة مع نظام اشتراكات متقدم، مشغل فيديو احترافي، وتتبع تقدم الطالب.

**الحالة:** 60% مكتمل
**تاريخ الإنشاء:** 2025-11-21
**التصميم:** Material Design 3 + RTL Support

---

## 🏗️ Architecture

البنية تتبع **Clean Architecture** بشكل كامل:

```
lib/features/courses/
├── domain/              # Business Logic Layer
│   ├── entities/       # 11 Domain Entities
│   ├── repositories/   # 2 Repository Interfaces
│   └── usecases/       # 5 Use Cases (15+ متبقي)
│
├── data/               # Data Layer
│   ├── models/        # 11 Models + .g.dart files
│   ├── datasources/   # Remote + Local DataSources
│   └── repositories/  # 2 Repository Implementations
│
└── presentation/       # UI Layer
    ├── bloc/          # BLoC State Management
    ├── pages/         # 2 Pages (4 متبقي)
    └── widgets/       # 5 Reusable Widgets
```

---

## 📦 Domain Layer

### Entities (11)

#### 1. CourseEntity
**الملف:** `domain/entities/course_entity.dart`

المعلومات الكاملة للدورة.

**الحقول الرئيسية:**
- `id`, `titleAr`, `slug`, `descriptionAr`
- `priceDzd`, `level`, `language`
- `instructorName`, `subjectNameAr`
- `totalModules`, `totalLessons`, `totalDurationMinutes`
- `averageRating`, `totalReviews`, `totalStudents`
- `isFreeAccess`, `isFeatured`, `isPublished`

**Getters ذكية:**
- `formattedPrice` → "مجاني" أو "5000 دج"
- `formattedDuration` → "5 ساعات 30 دقيقة"
- `levelText` → "ثانوي" أو "بكالوريا"
- `enrollmentText` → نص مناسب للالتحاق

#### 2. CourseModuleEntity
الوحدات (Chapters) داخل الدورة.

#### 3. CourseLessonEntity
الدروس الفردية مع معلومات الفيديو.

#### 4. LessonAttachmentEntity
المرفقات (PDF, ملفات) للدروس.

**Getters:**
- `fileIcon` → أيقونة حسب نوع الملف
- `formattedFileSize` → "2.5 MB"

#### 5. CourseProgressEntity
تتبع تقدم الطالب في الدورة.

**Getters:**
- `isCompleted` → true إذا >= 90%
- `formattedWatchTime` → "3 ساعات 45 دقيقة"

#### 6. LessonProgressEntity
تقدم الطالب في درس معين.

#### 7. UserSubscriptionEntity
اشتراكات المستخدم.

**Getters:**
- `remainingDays` → الأيام المتبقية
- `statusText` → "نشط" / "منتهي"
- `isExpired` → boolean

#### 8. PaymentReceiptEntity
إيصالات الدفع المرفوعة.

**Getters:**
- `statusColor` → لون حسب الحالة
- `statusIcon` → أيقونة الحالة
- `statusText` → "قيد المراجعة" / "مقبول" / "مرفوض"

#### 9. CourseReviewEntity
تقييمات ومراجعات الدورات.

#### 10. SubscriptionPackageEntity
باقات الاشتراك المتاحة.

**Getters:**
- `hasDiscount` → bool
- `discountPercentage` → نسبة الخصم
- `formattedPrice` → السعر مع/بدون خصم

#### 11. CertificateEntity
شهادات إتمام الدورات.

**Getters:**
- `formattedIssueDate`
- `isValid` → التحقق من الصلاحية

---

### Repositories (2)

#### 1. CoursesRepository
**الملف:** `domain/repositories/courses_repository.dart`

**Methods (20+):**
```dart
// Browse & Discover
Future<Either<Failure, List<CourseEntity>>> getCourses({...});
Future<Either<Failure, List<CourseEntity>>> getFeaturedCourses({...});
Future<Either<Failure, CourseEntity>> getCourseDetails(int courseId);
Future<Either<Failure, List<CourseModuleEntity>>> getCourseModules(int courseId);
Future<Either<Failure, List<CourseEntity>>> searchCourses(String query);

// Access Management
Future<Either<Failure, bool>> checkCourseAccess(int courseId);

// Video Lessons
Future<Either<Failure, CourseLessonEntity>> getLessonDetails(int lessonId);
Future<Either<Failure, String>> getSignedVideoUrl(int lessonId);

// Progress Tracking
Future<Either<Failure, CourseProgressEntity>> getCourseProgress(int courseId);
Future<Either<Failure, LessonProgressEntity>> updateLessonProgress({...});
Future<Either<Failure, void>> markLessonCompleted(int lessonId);
Future<Either<Failure, CourseLessonEntity?>> getNextLesson(int courseId);
Future<Either<Failure, List<CourseEntity>>> getMyCourses({String? status});

// Certificate
Future<Either<Failure, CertificateEntity>> generateCertificate(int courseId);
Future<Either<Failure, File>> downloadCertificate(String pdfUrl);

// Reviews
Future<Either<Failure, List<CourseReviewEntity>>> getCourseReviews(int courseId, {...});
Future<Either<Failure, CourseReviewEntity>> submitReview({...});
Future<Either<Failure, bool>> canReviewCourse(int courseId);

// Cache
Future<Either<Failure, void>> clearCache();
```

#### 2. SubscriptionRepository
**الملف:** `domain/repositories/subscription_repository.dart`

**Methods (11):**
- User Subscriptions (2)
- Subscription Codes (2)
- Packages (2)
- Payment Receipts (4)
- Cache Management (1)

---

### Use Cases (5 من ~15)

#### ✅ المُنفذة:
1. **GetCoursesUseCase** - مع فلترة متقدمة
2. **GetFeaturedCoursesUseCase** - الدورات المميزة
3. **GetCourseDetailsUseCase** - تفاصيل دورة
4. **GetCourseModulesUseCase** - محتوى الدورة
5. **CheckCourseAccessUseCase** - التحقق من الوصول

#### ⏳ المتبقية (~10):
- UpdateLessonProgressUseCase
- MarkLessonCompletedUseCase
- GetSignedVideoUrlUseCase
- GenerateCertificateUseCase
- SubmitReviewUseCase
- GetMySubscriptionsUseCase
- ValidateCodeUseCase
- RedeemCodeUseCase
- SubmitReceiptUseCase
- GetPackagesUseCase

---

## 💾 Data Layer

### Models (11)

جميع الـ models تستخدم **json_serializable** للتحويل الآلي:

```dart
@JsonSerializable(explicitToJson: true)
class CourseModel {
  factory CourseModel.fromJson(Map<String, dynamic> json) =>
      _$CourseModelFromJson(json);

  Map<String, dynamic> toJson() => _$CourseModelToJson(this);

  CourseEntity toEntity() { /* convert to entity */ }

  factory CourseModel.fromEntity(CourseEntity entity) { /* ... */ }
}
```

**الملفات المُولدة:** 11 ملف `.g.dart` من build_runner

---

### DataSources

#### Remote DataSource
**الملف:** `data/datasources/courses_remote_datasource.dart`

**Features:**
- 30+ API endpoints
- معالجة شاملة للأخطاء مع Dio
- دعم pagination, filtering, sorting
- Upload files مع MultipartFile
- Signed video URLs

**مثال:**
```dart
Future<List<CourseModel>> getCourses({
  String? search,
  int? subjectId,
  String? level,
  bool? featured,
  bool? isFree,
  String sortBy = 'created_at',
  String sortOrder = 'desc',
  int page = 1,
  int perPage = 20,
}) async {
  final response = await dio.get('/v1/courses', queryParameters: {...});
  // ...
}
```

#### Local DataSource
**الملف:** `data/datasources/courses_local_datasource.dart`

**Features:**
- Hive caching مع **TTL 12 ساعة**
- Auto-expiration للبيانات القديمة
- 5 Hive boxes:
  - `courses` - قائمة الدورات
  - `featured_courses` - الدورات المميزة
  - `course_details` - تفاصيل الدورات
  - `course_modules` - محتوى الدورات
  - `subscription_packages` - الباقات

**Cache Strategy:**
```dart
// Try cache first
final cachedCourses = await localDataSource.getCachedCourses();
if (cachedCourses != null && !_isCacheExpired(cachedCourses)) {
  return Right(cachedCourses);
}

// Fetch from network
final courses = await remoteDataSource.getCourses();
await localDataSource.cacheCourses(courses);
```

---

### Repository Implementations (2)

#### CoursesRepositoryImpl
**الملف:** `data/repositories/courses_repository_impl.dart`

**Features:**
- Cache-first strategy
- Network connectivity checks
- Smart error mapping (9 Failures)
- Automatic cache invalidation

#### SubscriptionRepositoryImpl
**الملف:** `data/repositories/subscription_repository_impl.dart`

---

## 🎨 Presentation Layer

### BLoC

#### CoursesBloc
**الملفات:**
- `presentation/bloc/courses/courses_event.dart` - 15+ events
- `presentation/bloc/courses/courses_state.dart` - 20+ states
- `presentation/bloc/courses/courses_bloc.dart` - Event handlers

**Events:**
```dart
LoadCoursesEvent              // تحميل الدورات
LoadFeaturedCoursesEvent      // الدورات المميزة
LoadCourseDetailsEvent        // تفاصيل دورة
LoadCourseModulesEvent        // محتوى دورة
SearchCoursesEvent            // البحث
CheckCourseAccessEvent        // التحقق من الوصول
// ... +9 more
```

**States:**
```dart
CoursesInitial
CoursesLoading
CoursesLoaded
FeaturedCoursesLoaded
CourseDetailsLoaded
CourseModulesLoaded
CoursesSearchResultsLoaded
CourseAccessChecked
CoursesError
// ... +11 more
```

---

### Pages (2 من ~6)

#### 1. CoursesPage ✅
**الملف:** `presentation/pages/courses_page.dart`

الصفحة الرئيسية لعرض جميع الدورات.

**Features:**
- Search bar مع live search
- Filter sheet (المستوى، السعر، الترتيب)
- Featured courses carousel
- Courses grid/list
- Pull-to-refresh
- Pagination support
- Empty & error states

**UI Components:**
```dart
CustomScrollView(
  slivers: [
    SliverAppBar(title: 'الدورات التعليمية'),
    SliverToBoxAdapter(child: SearchBar()),
    // Featured Carousel
    FeaturedCoursesCarousel(),
    // Courses List
    SliverList(...),
  ],
)
```

#### 2. CourseDetailPage ✅
**الملف:** `presentation/pages/course_detail_page.dart`

صفحة تفاصيل الدورة مع محتواها الكامل.

**Features:**
- SliverAppBar مع صورة الدورة
- 3 Tabs:
  - نظرة عامة (ماذا ستتعلم، المميزات، المتطلبات)
  - المحتوى (الوحدات والدروس)
  - التقييمات (قريباً)
- معلومات المدرس
- إحصائيات الدورة
- Expandable modules list
- Enroll/Subscribe dialog
- Lock/Unlock icons للدروس

**Tabs:**
```dart
TabBarView(
  children: [
    _buildOverviewTab(),    // نظرة عامة
    _buildCurriculumTab(),  // المحتوى
    _buildReviewsTab(),     // التقييمات
  ],
)
```

#### ⏳ المتبقية:
- VideoPlayerPage - مشغل الفيديو HLS
- SubscriptionsPage - عرض الباقات
- PaymentReceiptPage - رفع إيصال
- CertificatePage - عرض الشهادة

---

### Widgets (5)

#### 1. CourseCard ✅
بطاقة الدورة مع كل المعلومات.

**Features:**
- Thumbnail مع CachedNetworkImage
- Badges (مميزة، مجانية، المستوى)
- Title + Description
- Instructor & Subject
- Stats (Rating, Students, Duration)
- Price

#### 2. FeaturedCoursesCarousel ✅
كاروسيل أفقي للدورات المميزة.

#### 3. CourseStatsRow ✅
صف الإحصائيات (Rating, Students, Lessons).

#### 4. CourseInstructorCard ✅
بطاقة معلومات المدرس.

#### 5. CourseModuleItem ✅
عنصر الوحدة القابل للتوسيع مع الدروس.

**Features:**
- Expandable/Collapsible
- Lessons list
- Lock/Unlock icons
- Free preview badge
- Lesson duration
- Quiz indicator

---

## 🔧 Dependencies

```yaml
# Core
flutter_bloc: ^8.1.6
equatable: ^2.0.5
dartz: ^0.10.1

# Network
dio: ^5.4.0

# Cache
hive: ^2.2.3
hive_flutter: ^1.1.0

# Code Generation
json_annotation: ^4.8.1
json_serializable: ^6.7.1
build_runner: ^2.4.8

# Video (Courses Feature)
video_player: ^2.8.1
chewie: ^1.7.4

# File Handling
image_picker: ^1.0.7
file_picker: ^6.1.1

# PDF (Certificates)
pdf: ^3.10.7
flutter_pdfview: ^1.3.2

# Utilities
share_plus: ^7.2.2
url_launcher: ^6.2.4
photo_view: ^0.14.0
cached_network_image: ^3.3.1
```

---

## 🚀 Usage

### 1. Load Courses
```dart
context.read<CoursesBloc>().add(const LoadCoursesEvent());
```

### 2. Search Courses
```dart
context.read<CoursesBloc>().add(SearchCoursesEvent(query: 'رياضيات'));
```

### 3. Load Course Details
```dart
context.read<CoursesBloc>().add(LoadCourseDetailsEvent(courseId: 123));
```

### 4. Check Access
```dart
context.read<CoursesBloc>().add(CheckCourseAccessEvent(courseId: 123));
```

### 5. Navigate to Course
```dart
context.push('/courses/123');
```

---

## 📱 API Endpoints

### Base URL
```
/v1/courses
```

### Endpoints

#### GET `/v1/courses`
List courses with filters.

**Query Params:**
- `search`, `subject_id`, `level`, `featured`, `is_free`
- `sort_by`, `sort_order`, `page`, `per_page`

#### GET `/v1/courses/featured`
Featured courses.

#### GET `/v1/courses/{id}`
Course details.

#### GET `/v1/courses/{id}/modules`
Course curriculum.

#### GET `/v1/courses/{id}/check-access`
Check user access.

#### GET `/v1/lessons/{id}`
Lesson details.

#### GET `/v1/lessons/{id}/signed-video-url`
Get HLS video URL.

#### POST `/v1/lessons/{id}/progress`
Update lesson progress.

**Body:**
```json
{
  "watch_time_seconds": 300,
  "progress_percentage": 45.5
}
```

---

## 🎯 Roadmap

### Phase 1: Foundation ✅ (60%)
- [x] Domain entities
- [x] Repositories
- [x] Basic use cases
- [x] Data models
- [x] Remote & Local datasources
- [x] Repository implementations
- [x] CoursesBloc
- [x] CoursesPage
- [x] CourseDetailPage
- [x] Core widgets

### Phase 2: Video & Progress ⏳ (0%)
- [ ] VideoPlayerBloc
- [ ] VideoPlayerPage (HLS streaming)
- [ ] Progress tracking use cases
- [ ] Progress widgets
- [ ] Next lesson navigation

### Phase 3: Subscriptions ⏳ (0%)
- [ ] SubscriptionBloc
- [ ] SubscriptionsPage
- [ ] PaymentReceiptPage
- [ ] Code redemption
- [ ] Receipt upload

### Phase 4: Advanced Features ⏳ (0%)
- [ ] CertificateBloc
- [ ] CertificatePage
- [ ] Reviews system
- [ ] Bookmarks
- [ ] Offline downloads

### Phase 5: Polish & Testing ⏳ (0%)
- [ ] Unit tests
- [ ] Widget tests
- [ ] Integration tests
- [ ] Performance optimization
- [ ] Documentation

---

## 📊 Statistics

| Metric | Value |
|--------|-------|
| **Total Files** | 46 |
| **Lines of Code** | ~5,800+ |
| **Domain Files** | 18 |
| **Data Files** | 25 |
| **Presentation Files** | 10 |
| **Test Coverage** | 0% (TBD) |
| **Completion** | 60% |

---

## 🤝 Contributing

عند إضافة ميزات جديدة:

1. **Domain First** - ابدأ بالـ Entity و Repository
2. **Use Cases** - أنشئ use case منفصل لكل عملية
3. **Models** - أضف Model مع json_serializable
4. **DataSource** - نفذ في Remote/Local datasource
5. **Repository** - نفذ في Repository implementation
6. **BLoC** - أضف Events & States
7. **UI** - أنشئ الشاشات والـ widgets
8. **Tests** - اكتب tests للـ use cases

---

## 📝 Notes

- جميع النصوص بالعربية (RTL)
- استخدم Cairo font
- Material Design 3
- Dark mode support (مستقبلاً)
- Accessibility (مستقبلاً)

---

## 📧 Contact

للأسئلة أو المشاكل، افتح issue في الـ repository.

---

**آخر تحديث:** 2025-11-21
**الإصدار:** 0.1.0 (Alpha)
