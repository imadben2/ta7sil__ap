import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';

/// Service for uploading PDFs to Laravel API server
///
/// Uploads generated PDFs to public/planner folder on server
class PdfUploadService {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  PdfUploadService({
    Dio? dio,
    FlutterSecureStorage? storage,
  })  : _dio = dio ?? Dio(),
        _storage = storage ?? const FlutterSecureStorage();

  /// Upload PDF file to server
  ///
  /// [filePath] - Local path to PDF file
  /// [fileName] - Optional custom file name (defaults to original)
  /// [type] - Type of PDF: 'schedule' or 'history'
  ///
  /// Returns the server URL of the uploaded PDF
  Future<PdfUploadResponse> uploadPdf({
    required String filePath,
    String? fileName,
    String type = 'schedule',
    Function(int, int)? onProgress,
  }) async {
    try {
      // Get auth token
      final token = await _storage.read(key: 'auth_token');
      print('🔑 Auth token: ${token != null ? "present (${token.length} chars)" : "NULL"}');

      // Prepare file
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File not found: $filePath');
      }
      print('📁 File exists: ${await file.length()} bytes');

      // Extract file name if not provided
      fileName ??= file.path.split('/').last;

      // Build upload URL
      final uploadUrl = '${ApiConstants.baseUrl}/v1/pdfs/upload';
      print('🌐 Upload URL: $uploadUrl');

      // Prepare multipart file
      final formData = FormData.fromMap({
        'pdf_file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
        'file_name': fileName,
        'type': type,
      });

      // Upload with progress tracking
      final response = await _dio.post(
        uploadUrl,
        data: formData,
        options: Options(
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
        onSendProgress: (sent, total) {
          print('📊 Upload progress: $sent / $total');
          if (onProgress != null) {
            onProgress(sent, total);
          }
        },
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response data: ${response.data}');

      if (response.statusCode == 201 && response.data['success'] == true) {
        return PdfUploadResponse.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Upload failed');
      }
    } on DioException catch (e) {
      print('❌ DioException: ${e.type} - ${e.message}');
      print('❌ Response: ${e.response?.data}');
      throw _handleDioError(e);
    } catch (e) {
      print('❌ Exception: $e');
      throw Exception('Failed to upload PDF: $e');
    }
  }

  /// List all PDFs on server
  Future<List<PdfInfo>> listPdfs() async {
    try {
      final token = await _storage.read(key: 'auth_token');

      final response = await _dio.get(
        '${ApiConstants.baseUrl}/v1/pdfs/list',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => PdfInfo.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to list PDFs');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Failed to list PDFs: $e');
    }
  }

  /// Delete PDF from server
  Future<bool> deletePdf(String fileName) async {
    try {
      final token = await _storage.read(key: 'auth_token');

      final response = await _dio.delete(
        '${ApiConstants.baseUrl}/v1/pdfs/delete',
        data: {'file_name': fileName},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      return response.statusCode == 200 && response.data['success'] == true;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Failed to delete PDF: $e');
    }
  }

  /// Get public URL for a PDF
  String getPdfUrl(String fileName) {
    return '${ApiConstants.baseUrl}/planner/$fileName';
  }

  /// Handle Dio errors
  Exception _handleDioError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map && data['message'] != null) {
        return Exception(data['message']);
      }
      return Exception('Server error: ${e.response!.statusCode}');
    } else {
      return Exception('Network error: ${e.message}');
    }
  }
}

/// Response model for PDF upload
class PdfUploadResponse {
  final bool success;
  final String message;
  final PdfData data;

  PdfUploadResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory PdfUploadResponse.fromJson(Map<String, dynamic> json) {
    return PdfUploadResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: PdfData.fromJson(json['data'] ?? {}),
    );
  }
}

/// PDF data model
class PdfData {
  final String fileName;
  final String url;
  final String path;
  final int size;

  PdfData({
    required this.fileName,
    required this.url,
    required this.path,
    required this.size,
  });

  factory PdfData.fromJson(Map<String, dynamic> json) {
    return PdfData(
      fileName: json['file_name'] ?? '',
      url: json['url'] ?? '',
      path: json['path'] ?? '',
      size: json['size'] ?? 0,
    );
  }
}

/// PDF info model (for list)
class PdfInfo {
  final String name;
  final String url;
  final int size;
  final String modified;

  PdfInfo({
    required this.name,
    required this.url,
    required this.size,
    required this.modified,
  });

  factory PdfInfo.fromJson(Map<String, dynamic> json) {
    return PdfInfo(
      name: json['name'] ?? '',
      url: json['url'] ?? '',
      size: json['size'] ?? 0,
      modified: json['modified'] ?? '',
    );
  }

  /// Get formatted file size
  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
