import 'package:equatable/equatable.dart';
import '../../domain/entities/session_history.dart';

/// States for SessionHistoryCubit
abstract class SessionHistoryState extends Equatable {
  const SessionHistoryState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class SessionHistoryInitial extends SessionHistoryState {
  const SessionHistoryInitial();
}

/// Loading state
class SessionHistoryLoading extends SessionHistoryState {
  final String? message;

  const SessionHistoryLoading({this.message});

  @override
  List<Object?> get props => [message];
}

/// Loaded state with history data
class SessionHistoryLoaded extends SessionHistoryState {
  final SessionHistory history;
  final DateTime? selectedDate;

  const SessionHistoryLoaded({required this.history, this.selectedDate});

  @override
  List<Object?> get props => [history, selectedDate];

  /// Get sessions for a specific date
  List<HistoricalSession> getSessionsForDate(DateTime date) {
    final dateKey = DateTime(date.year, date.month, date.day);
    return history.sessions.where((session) {
      final sessionDate = DateTime(
        session.scheduledDate.year,
        session.scheduledDate.month,
        session.scheduledDate.day,
      );
      return sessionDate == dateKey;
    }).toList();
  }
}

/// Error state
class SessionHistoryError extends SessionHistoryState {
  final String message;

  const SessionHistoryError(this.message);

  @override
  List<Object?> get props => [message];
}
