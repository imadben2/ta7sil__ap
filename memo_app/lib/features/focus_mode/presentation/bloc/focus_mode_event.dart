import 'package:equatable/equatable.dart';
import 'package:memo_app/features/focus_mode/domain/entities/focus_mode_settings.dart';
import 'package:memo_app/features/focus_mode/domain/entities/focus_session_entity.dart';

/// Focus Mode Events
abstract class FocusModeEvent extends Equatable {
  const FocusModeEvent();

  @override
  List<Object?> get props => [];
}

/// Initialize focus mode
class InitializeFocusMode extends FocusModeEvent {
  const InitializeFocusMode();
}

/// Start focus mode
class StartFocusMode extends FocusModeEvent {
  final FocusModeType type;
  final Duration? duration;
  final String? studySessionId;

  const StartFocusMode({
    required this.type,
    this.duration,
    this.studySessionId,
  });

  @override
  List<Object?> get props => [type, duration, studySessionId];
}

/// End focus mode
class EndFocusMode extends FocusModeEvent {
  const EndFocusMode();
}

/// Update settings
class UpdateFocusModeSettings extends FocusModeEvent {
  final FocusModeSettings settings;

  const UpdateFocusModeSettings(this.settings);

  @override
  List<Object?> get props => [settings];
}

/// Check DND permission
class CheckDndPermission extends FocusModeEvent {
  const CheckDndPermission();
}

/// Request DND permission
class RequestDndPermission extends FocusModeEvent {
  const RequestDndPermission();
}
