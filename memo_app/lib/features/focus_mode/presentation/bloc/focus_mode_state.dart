import 'package:equatable/equatable.dart';
import 'package:memo_app/features/focus_mode/domain/entities/focus_mode_settings.dart';
import 'package:memo_app/features/focus_mode/domain/entities/focus_session_entity.dart';

/// Focus Mode States
abstract class FocusModeState extends Equatable {
  const FocusModeState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class FocusModeInitial extends FocusModeState {
  const FocusModeInitial();
}

/// Loading state
class FocusModeLoading extends FocusModeState {
  const FocusModeLoading();
}

/// Loaded state (focus mode inactive)
class FocusModeInactive extends FocusModeState {
  final FocusModeSettings settings;
  final bool hasDndPermission;

  const FocusModeInactive({
    required this.settings,
    required this.hasDndPermission,
  });

  @override
  List<Object?> get props => [settings, hasDndPermission];
}

/// Focus mode active
class FocusModeActive extends FocusModeState {
  final FocusSessionEntity session;
  final FocusModeSettings settings;

  const FocusModeActive({
    required this.session,
    required this.settings,
  });

  @override
  List<Object?> get props => [session, settings];
}

/// Focus mode starting
class FocusModeStarting extends FocusModeState {
  final FocusModeType type;

  const FocusModeStarting(this.type);

  @override
  List<Object?> get props => [type];
}

/// Focus mode ending
class FocusModeEnding extends FocusModeState {
  final FocusSessionEntity session;

  const FocusModeEnding(this.session);

  @override
  List<Object?> get props => [session];
}

/// Settings updated
class FocusModeSettingsUpdated extends FocusModeState {
  final FocusModeSettings settings;
  final bool hasDndPermission;

  const FocusModeSettingsUpdated({
    required this.settings,
    required this.hasDndPermission,
  });

  @override
  List<Object?> get props => [settings, hasDndPermission];
}

/// Permission check result
class DndPermissionChecked extends FocusModeState {
  final bool hasPermission;
  final FocusModeSettings settings;

  const DndPermissionChecked({
    required this.hasPermission,
    required this.settings,
  });

  @override
  List<Object?> get props => [hasPermission, settings];
}

/// Error state
class FocusModeError extends FocusModeState {
  final String message;
  final FocusModeSettings? settings;

  const FocusModeError(this.message, {this.settings});

  @override
  List<Object?> get props => [message, settings];
}
