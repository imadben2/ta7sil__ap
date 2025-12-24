import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

/// Base class for all use cases in the application
///
/// A use case represents a single unit of business logic that can be executed.
/// It takes parameters of type [Params] and returns an [Either] with a [Failure] or a result of type [Type].
abstract class UseCase<Type, Params> {
  /// Execute the use case with the given parameters
  Future<Either<Failure, Type>> call(Params params);
}

/// Use case that doesn't require any parameters
class NoParams {
  const NoParams();
}
