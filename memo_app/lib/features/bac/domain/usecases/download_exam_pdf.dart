import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/bac_repository.dart';

/// Parameters for downloading an exam PDF
class DownloadExamPdfParams {
  final int examId;
  final String examTitle;

  DownloadExamPdfParams({required this.examId, required this.examTitle});
}

/// Use case to download an exam PDF
class DownloadExamPdf {
  final BacRepository repository;

  DownloadExamPdf(this.repository);

  Future<Either<Failure, String>> call(DownloadExamPdfParams params) async {
    return await repository.downloadExamPdf(params.examId, params.examTitle);
  }
}
