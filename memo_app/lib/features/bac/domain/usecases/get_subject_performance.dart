import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/bac_repository.dart';

/// Use case to get user's performance statistics for a subject
class GetSubjectPerformance {
  final BacRepository repository;

  GetSubjectPerformance(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(String subjectSlug) async {
    return await repository.getSubjectPerformance(subjectSlug);
  }
}
