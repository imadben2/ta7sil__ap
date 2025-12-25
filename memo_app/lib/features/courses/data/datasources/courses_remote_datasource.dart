import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/certificate_model.dart';
import '../models/course_lesson_model.dart';
import '../models/course_model.dart';
import '../models/course_module_model.dart';
import '../models/course_progress_model.dart';
import '../models/course_review_model.dart';
import '../models/lesson_progress_model.dart';
import '../models/payment_receipt_model.dart';
import '../models/subscription_package_model.dart';
import '../models/user_subscription_model.dart';

/// Remote Data Source للدورات
abstract class CoursesRemoteDataSource {
  // ========== Browse & Discover ==========
  Future<List<CourseModel>> getCourses({
    String? search,
    int? subjectId,
    String? level,
    int? academicPhaseId,
    bool? featured,
    bool? isFree,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
    int page = 1,
    int perPage = 20,
  });

  Future<List<CourseModel>> getFeaturedCourses({int limit = 5});
  Future<CourseModel> getCourseDetails(int courseId);
  Future<List<CourseModuleModel>> getCourseModules(int courseId);
  Future<List<CourseModel>> searchCourses(String query);

  // ========== Access Management ==========
  Future<bool> checkCourseAccess(int courseId);

  // ========== Video Lessons ==========
  Future<CourseLessonModel> getLessonDetails(int lessonId);
  Future<String> getSignedVideoUrl(int lessonId);

  // ========== Progress Tracking ==========
  Future<CourseProgressModel> getCourseProgress(int courseId);
  Future<LessonProgressModel?> getLessonProgress(int lessonId);
  Future<LessonProgressModel> updateLessonProgress({
    required int lessonId,
    required int watchTimeSeconds,
    required double progressPercentage,
  });
  Future<void> markLessonCompleted(int lessonId);
  Future<CourseLessonModel?> getNextLesson(int courseId);
  Future<List<CourseModel>> getMyCourses({String? status});

  // ========== Certificate ==========
  Future<CertificateModel> generateCertificate(int courseId);

  // ========== Reviews ==========
  Future<List<CourseReviewModel>> getCourseReviews(
    int courseId, {
    int? rating,
    int page = 1,
    int perPage = 20,
  });
  Future<CourseReviewModel> submitReview({
    required int courseId,
    required int rating,
    required String reviewText,
  });
  Future<bool> canReviewCourse(int courseId);

  // ========== Subscriptions ==========
  Future<List<UserSubscriptionModel>> getMySubscriptions({bool? activeOnly});
  Future<Map<String, dynamic>> getMyStats();
  Future<Map<String, dynamic>> validateSubscriptionCode(String code);
  Future<UserSubscriptionModel> redeemSubscriptionCode(String code);

  // ========== Packages ==========
  Future<List<SubscriptionPackageModel>> getPackages({bool? activeOnly});
  Future<SubscriptionPackageModel> getPackageDetails(int packageId);

  // ========== Payment Receipts ==========
  Future<PaymentReceiptModel> submitReceipt({
    int? courseId,
    int? packageId,
    required File receiptImage,
    required int amountDzd,
    String? paymentMethod,
    String? transactionReference,
    String? userNotes,
  });
  Future<List<PaymentReceiptModel>> getMyPaymentReceipts({String? status});
  Future<PaymentReceiptModel> getReceiptDetails(int receiptId);
}

class CoursesRemoteDataSourceImpl implements CoursesRemoteDataSource {
  final Dio dio;

  CoursesRemoteDataSourceImpl({required this.dio});

  // ========== Browse & Discover ==========

  @override
  Future<List<CourseModel>> getCourses({
    String? search,
    int? subjectId,
    String? level,
    int? academicPhaseId,
    bool? featured,
    bool? isFree,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
        'sort_by': sortBy,
        'sort_order': sortOrder,
        if (search != null) 'search': search,
        if (subjectId != null) 'subject_id': subjectId,
        if (level != null) 'level': level,
        if (academicPhaseId != null) 'academic_phase_id': academicPhaseId,
        if (featured != null) 'featured': featured ? 1 : 0,
        if (isFree != null) 'is_free': isFree ? 1 : 0,
      };

      final response = await dio.get('/v1/courses', queryParameters: queryParams);

      // Log API response for courses list
      debugPrint('╔══════════════════════════════════════════════════════════════');
      debugPrint('║ 📚 GET COURSES API RESPONSE');
      debugPrint('╠══════════════════════════════════════════════════════════════');
      debugPrint('║ Status: ${response.statusCode}');
      debugPrint('║ Full Response: ${response.data}');
      debugPrint('╚══════════════════════════════════════════════════════════════');

      if (response.statusCode == 200) {
        final data = response.data['data'];
        List<dynamic> coursesList = [];

        if (data is List) {
          coursesList = data;
        } else if (data is Map && data.containsKey('data')) {
          coursesList = data['data'] as List;
        }

        // Log each course's thumbnail info
        for (var course in coursesList) {
          debugPrint('║ Course: ${course['title_ar']} | thumbnail_url: ${course['thumbnail_url']} | thumbnail_full_url: ${course['thumbnail_full_url']}');
        }

        return coursesList.map((json) {
          final courseData = Map<String, dynamic>.from(json as Map);
          _ensureRequiredFields(courseData);
          return CourseModel.fromJson(courseData);
        }).toList();
      } else {
        throw Exception('فشل تحميل الدورات');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<CourseModel>> getFeaturedCourses({int limit = 5}) async {
    try {
      final response = await dio.get(
        '/v1/courses/featured',
        queryParameters: {'limit': limit},
      );

      // Log API response for featured courses
      debugPrint('╔══════════════════════════════════════════════════════════════');
      debugPrint('║ ⭐ FEATURED COURSES API RESPONSE');
      debugPrint('╠══════════════════════════════════════════════════════════════');
      debugPrint('║ Status: ${response.statusCode}');
      debugPrint('║ Full Response: ${response.data}');
      debugPrint('╚══════════════════════════════════════════════════════════════');

      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data is List) {
          // Log each featured course's thumbnail info
          for (var course in data) {
            debugPrint('║ ⭐ Featured: ${course['title_ar']} | thumbnail_url: ${course['thumbnail_url']} | thumbnail_full_url: ${course['thumbnail_full_url']}');
          }
          return data.map((json) {
            final courseData = Map<String, dynamic>.from(json as Map);
            _ensureRequiredFields(courseData);
            return CourseModel.fromJson(courseData);
          }).toList();
        }
        return [];
      } else {
        throw Exception('فشل تحميل الدورات المميزة');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<CourseModel> getCourseDetails(int courseId) async {
    try {
      final response = await dio.get('/v1/courses/$courseId');

      // Log full API response for debugging
      debugPrint('╔══════════════════════════════════════════════════════════════');
      debugPrint('║ 📚 COURSE DETAILS API RESPONSE (Course ID: $courseId)');
      debugPrint('╠══════════════════════════════════════════════════════════════');
      debugPrint('║ Status Code: ${response.statusCode}');
      debugPrint('║ Full Response Data:');
      debugPrint('║ ${response.data}');
      debugPrint('╚══════════════════════════════════════════════════════════════');

      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data == null) {
          throw Exception('لا توجد بيانات للدورة');
        }

        // Course details are nested under 'course' key
        final courseData = data['course'] != null
            ? Map<String, dynamic>.from(data['course'] as Map)
            : Map<String, dynamic>.from(data as Map);

        // Log parsed course data
        debugPrint('╔══════════════════════════════════════════════════════════════');
        debugPrint('║ 🎯 PARSED COURSE DATA:');
        debugPrint('║ thumbnail_url: ${courseData['thumbnail_url']}');
        debugPrint('║ thumbnail_full_url: ${courseData['thumbnail_full_url']}');
        debugPrint('║ title_ar: ${courseData['title_ar']}');
        debugPrint('║ price_dzd: ${courseData['price_dzd']}');
        debugPrint('║ is_featured: ${courseData['is_featured']}');
        debugPrint('║ modules_count: ${courseData['modules_count']}');
        debugPrint('║ lessons_count: ${courseData['lessons_count']}');
        debugPrint('╚══════════════════════════════════════════════════════════════');

        _ensureRequiredFields(courseData);
        return CourseModel.fromJson(courseData);
      } else {
        throw Exception('فشل تحميل تفاصيل الدورة');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<CourseModuleModel>> getCourseModules(int courseId) async {
    try {
      final response = await dio.get('/v1/courses/$courseId/modules');

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => CourseModuleModel.fromJson(json)).toList();
      } else {
        throw Exception('فشل تحميل محتوى الدورة');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<CourseModel>> searchCourses(String query) async {
    try {
      final response = await dio.get(
        '/v1/courses/search',
        queryParameters: {'q': query},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) {
          final courseData = Map<String, dynamic>.from(json as Map);
          _ensureRequiredFields(courseData);
          return CourseModel.fromJson(courseData);
        }).toList();
      } else {
        throw Exception('فشل البحث عن الدورات');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ========== Access Management ==========

  @override
  Future<bool> checkCourseAccess(int courseId) async {
    try {
      final response = await dio.get('/v1/courses/$courseId/check-access');

      if (response.statusCode == 200) {
        // API returns has_access directly in response, not inside 'data'
        final data = response.data;
        if (data is Map<String, dynamic>) {
          // Check both possible response formats
          if (data.containsKey('has_access')) {
            return data['has_access'] as bool? ?? false;
          } else if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
            return data['data']['has_access'] as bool? ?? false;
          }
        }
        return false;
      }
      return false;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ========== Video Lessons ==========

  @override
  Future<CourseLessonModel> getLessonDetails(int lessonId) async {
    try {
      final response = await dio.get('/v1/lessons/$lessonId');

      if (response.statusCode == 200) {
        return CourseLessonModel.fromJson(response.data['data']);
      } else {
        throw Exception('فشل تحميل تفاصيل الدرس');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<String> getSignedVideoUrl(int lessonId) async {
    try {
      final response = await dio.get('/v1/lessons/$lessonId/signed-video-url');

      if (response.statusCode == 200) {
        return response.data['data']['signed_url'] as String;
      } else {
        throw Exception('فشل الحصول على رابط الفيديو');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ========== Progress Tracking ==========

  @override
  Future<CourseProgressModel> getCourseProgress(int courseId) async {
    try {
      final response = await dio.get('/v1/progress/courses/$courseId/my-progress');

      if (response.statusCode == 200) {
        return CourseProgressModel.fromJson(response.data['data']);
      } else {
        throw Exception('فشل تحميل تقدم الدورة');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<LessonProgressModel?> getLessonProgress(int lessonId) async {
    try {
      final response = await dio.get('/v1/progress/lessons/$lessonId/progress');

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return data != null ? LessonProgressModel.fromJson(data) : null;
      } else if (response.statusCode == 404) {
        // No progress found - return null
        return null;
      } else {
        throw Exception('فشل تحميل تقدم الدرس');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // No progress found - return null
        return null;
      }
      throw _handleDioError(e);
    }
  }

  @override
  Future<LessonProgressModel> updateLessonProgress({
    required int lessonId,
    required int watchTimeSeconds,
    required double progressPercentage,
  }) async {
    try {
      final response = await dio.post(
        '/v1/progress/lessons/$lessonId/progress',
        data: {
          'watch_time_seconds': watchTimeSeconds,
          'progress_percentage': progressPercentage,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return LessonProgressModel.fromJson(response.data['data']);
      } else {
        throw Exception('فشل حفظ التقدم');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> markLessonCompleted(int lessonId) async {
    try {
      final response = await dio.post('/v1/progress/lessons/$lessonId/complete');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('فشل تعليم الدرس كمكتمل');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<CourseLessonModel?> getNextLesson(int courseId) async {
    try {
      final response = await dio.get('/v1/progress/courses/$courseId/next-lesson');

      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data == null) return null;
        return CourseLessonModel.fromJson(data);
      }
      return null;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<CourseModel>> getMyCourses({String? status}) async {
    try {
      final queryParams = <String, dynamic>{
        if (status != null) 'status': status,
      };

      final response = await dio.get(
        '/v1/progress/my-courses',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) {
          final courseData = Map<String, dynamic>.from(json as Map);
          _ensureRequiredFields(courseData);
          return CourseModel.fromJson(courseData);
        }).toList();
      } else {
        throw Exception('فشل تحميل دوراتي');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ========== Certificate ==========

  @override
  Future<CertificateModel> generateCertificate(int courseId) async {
    try {
      final response = await dio.get('/v1/progress/courses/$courseId/certificate');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return CertificateModel.fromJson(response.data['data']);
      } else {
        throw Exception('فشل إنشاء الشهادة');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ========== Reviews ==========

  @override
  Future<List<CourseReviewModel>> getCourseReviews(
    int courseId, {
    int? rating,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
        if (rating != null) 'rating': rating,
      };

      final response = await dio.get(
        '/v1/reviews/courses/$courseId/reviews',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        List<dynamic> reviewsList = [];

        if (data is List) {
          reviewsList = data;
        } else if (data is Map && data.containsKey('data')) {
          reviewsList = data['data'] as List;
        }

        return reviewsList
            .map((json) => CourseReviewModel.fromJson(json))
            .toList();
      } else {
        throw Exception('فشل تحميل المراجعات');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<CourseReviewModel> submitReview({
    required int courseId,
    required int rating,
    required String reviewText,
  }) async {
    try {
      final response = await dio.post(
        '/v1/reviews/courses/$courseId/reviews',
        data: {'rating': rating, 'review_text': reviewText},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return CourseReviewModel.fromJson(response.data['data']);
      } else {
        throw Exception('فشل إرسال المراجعة');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<bool> canReviewCourse(int courseId) async {
    try {
      final response = await dio.get('/v1/reviews/courses/$courseId/can-review');

      if (response.statusCode == 200) {
        return response.data['data']['can_review'] as bool? ?? false;
      }
      return false;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ========== Subscriptions ==========

  @override
  Future<List<UserSubscriptionModel>> getMySubscriptions({
    bool? activeOnly,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        if (activeOnly != null) 'active_only': activeOnly ? 1 : 0,
      };

      final response = await dio.get(
        '/v1/subscriptions/my-subscriptions',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data
            .map((json) => UserSubscriptionModel.fromJson(json))
            .toList();
      } else {
        throw Exception('فشل تحميل الاشتراكات');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getMyStats() async {
    try {
      final response = await dio.get('/v1/subscriptions/my-stats');

      if (response.statusCode == 200) {
        return response.data['data'] as Map<String, dynamic>;
      } else {
        throw Exception('فشل تحميل الإحصائيات');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> validateSubscriptionCode(String code) async {
    try {
      final response = await dio.post(
        '/v1/subscriptions/validate-code',
        data: {'code': code},
      );

      if (response.statusCode == 200) {
        // Check if validation was successful
        final success = response.data['success'] as bool? ?? false;
        final valid = response.data['valid'] as bool? ?? false;

        if (!success || !valid) {
          // Code is invalid or not found
          final message = response.data['message'] as String? ?? 'رمز الاشتراك غير صالح';
          throw Exception(message);
        }

        // Return the data if code is valid
        final data = response.data['data'];
        if (data == null) {
          throw Exception('رمز الاشتراك غير صالح');
        }

        return data as Map<String, dynamic>;
      } else {
        throw Exception('فشل التحقق من الكود');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<UserSubscriptionModel> redeemSubscriptionCode(String code) async {
    try {
      final response = await dio.post(
        '/v1/subscriptions/redeem-code',
        data: {'code': code},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Check if redemption was successful
        final success = response.data['success'] as bool? ?? false;

        if (!success) {
          // Redemption failed
          final message = response.data['message'] as String? ?? 'فشل استخدام الكود';
          throw Exception(message);
        }

        // Return the subscription data if redemption was successful
        final data = response.data['data'];
        if (data == null) {
          throw Exception('فشل استخدام الكود: لا توجد بيانات');
        }

        return UserSubscriptionModel.fromJson(data);
      } else {
        throw Exception('فشل استخدام الكود');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ========== Packages ==========

  @override
  Future<List<SubscriptionPackageModel>> getPackages({bool? activeOnly}) async {
    try {
      final queryParams = <String, dynamic>{
        if (activeOnly != null) 'active_only': activeOnly ? 1 : 0,
      };

      final response = await dio.get(
        '/v1/subscription-packages',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        List<dynamic> data = [];

        // Handle different response formats
        if (responseData is Map && responseData.containsKey('data')) {
          final innerData = responseData['data'];
          if (innerData is List) {
            data = innerData;
          } else if (innerData is Map && innerData.containsKey('data')) {
            // Paginated response
            data = innerData['data'] as List;
          }
        } else if (responseData is List) {
          data = responseData;
        }

        return data
            .map((json) => SubscriptionPackageModel.fromJson(
                  Map<String, dynamic>.from(json as Map),
                ))
            .toList();
      } else {
        throw Exception('فشل تحميل الباقات');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<SubscriptionPackageModel> getPackageDetails(int packageId) async {
    try {
      final response = await dio.get('/v1/subscription-packages/$packageId');

      if (response.statusCode == 200) {
        return SubscriptionPackageModel.fromJson(response.data['data']);
      } else {
        throw Exception('فشل تحميل تفاصيل الباقة');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ========== Payment Receipts ==========

  @override
  Future<PaymentReceiptModel> submitReceipt({
    int? courseId,
    int? packageId,
    required File receiptImage,
    required int amountDzd,
    String? paymentMethod,
    String? transactionReference,
    String? userNotes,
  }) async {
    try {
      final formData = FormData.fromMap({
        if (courseId != null) 'course_id': courseId,
        if (packageId != null) 'package_id': packageId,
        'amount_dzd': amountDzd,
        if (paymentMethod != null) 'payment_method': paymentMethod,
        if (transactionReference != null)
          'transaction_reference': transactionReference,
        if (userNotes != null) 'user_notes': userNotes,
        'receipt_image': await MultipartFile.fromFile(receiptImage.path),
      });

      final response = await dio.post('/v1/subscriptions/submit-receipt', data: formData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return PaymentReceiptModel.fromJson(response.data['data']);
      } else {
        throw Exception('فشل إرسال إيصال الدفع');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<PaymentReceiptModel>> getMyPaymentReceipts({
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        if (status != null) 'status': status,
      };

      final response = await dio.get(
        '/v1/subscriptions/my-payment-receipts',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => PaymentReceiptModel.fromJson(json)).toList();
      } else {
        throw Exception('فشل تحميل إيصالات الدفع');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<PaymentReceiptModel> getReceiptDetails(int receiptId) async {
    try {
      final response = await dio.get('/v1/subscriptions/payment-receipts/$receiptId');

      if (response.statusCode == 200) {
        return PaymentReceiptModel.fromJson(response.data['data']);
      } else {
        throw Exception('فشل تحميل تفاصيل الإيصال');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ========== Helper Methods ==========

  /// Ensure required fields have defaults
  void _ensureRequiredFields(Map<String, dynamic> courseData) {
    courseData['title_ar'] ??= '';
    courseData['slug'] ??= '';
    courseData['description_ar'] ??= '';
    courseData['subject_name_ar'] ??= '';
    courseData['instructor_name'] ??= '';
  }

  /// Handle Dio errors
  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data['message'] as String?;
        if (statusCode == 401) {
          return Exception('يجب تسجيل الدخول أولاً');
        } else if (statusCode == 403) {
          return Exception('ليس لديك صلاحية للوصول إلى هذه الدورة');
        } else if (statusCode == 404) {
          return Exception('الدورة غير موجودة');
        } else if (statusCode == 422) {
          return Exception(message ?? 'بيانات غير صحيحة');
        } else if (statusCode == 500) {
          return Exception('خطأ في الخادم. يرجى المحاولة لاحقاً');
        }
        return Exception(message ?? 'حدث خطأ غير متوقع');
      case DioExceptionType.cancel:
        return Exception('تم إلغاء الطلب');
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        return Exception('لا يوجد اتصال بالإنترنت. يرجى التحقق من اتصالك');
      default:
        return Exception('حدث خطأ غير متوقع');
    }
  }
}
