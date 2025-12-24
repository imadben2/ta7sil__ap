import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/bac_chapter_info_entity.dart';
import '../repositories/bac_repository.dart';

/// Use case to get chapters for a specific BAC subject
class GetBacChapters {
  final BacRepository repository;

  GetBacChapters(this.repository);

  Future<Either<Failure, List<BacChapterInfoEntity>>> call(
    String subjectSlug,
  ) async {
    return await repository.getBacChapters(subjectSlug);
  }
}
