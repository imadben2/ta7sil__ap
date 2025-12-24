import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/bac_study_repository.dart';

/// Use case to mark a topic as completed or incomplete
class MarkTopicComplete implements UseCase<Unit, MarkTopicCompleteParams> {
  final BacStudyRepository repository;

  MarkTopicComplete(this.repository);

  @override
  Future<Either<Failure, Unit>> call(MarkTopicCompleteParams params) {
    return repository.markTopicComplete(params.topicId, params.isCompleted);
  }
}

class MarkTopicCompleteParams {
  final int topicId;
  final bool isCompleted;

  const MarkTopicCompleteParams({
    required this.topicId,
    required this.isCompleted,
  });
}
