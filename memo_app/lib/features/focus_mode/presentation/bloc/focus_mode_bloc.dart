import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memo_app/core/services/focus_mode_service.dart';
import 'package:memo_app/core/services/system_dnd_manager.dart';
import 'package:memo_app/features/focus_mode/domain/entities/focus_session_entity.dart';
import 'package:memo_app/features/focus_mode/presentation/bloc/focus_mode_event.dart';
import 'package:memo_app/features/focus_mode/presentation/bloc/focus_mode_state.dart';

/// Focus Mode BLoC
///
/// Manages focus mode state and coordinates with FocusModeService.
class FocusModeBloc extends Bloc<FocusModeEvent, FocusModeState> {
  final FocusModeService _focusModeService;
  final SystemDndManager _dndManager;
  StreamSubscription<FocusSessionEntity?>? _sessionSubscription;

  FocusModeBloc({
    required FocusModeService focusModeService,
    required SystemDndManager dndManager,
  })  : _focusModeService = focusModeService,
        _dndManager = dndManager,
        super(const FocusModeInitial()) {
    // Register event handlers
    on<InitializeFocusMode>(_onInitialize);
    on<StartFocusMode>(_onStartFocusMode);
    on<EndFocusMode>(_onEndFocusMode);
    on<UpdateFocusModeSettings>(_onUpdateSettings);
    on<CheckDndPermission>(_onCheckPermission);
    on<RequestDndPermission>(_onRequestPermission);
  }

  /// Initialize and start listening to service session changes
  void _startListening() {
    _sessionSubscription?.cancel();
    _sessionSubscription = _focusModeService.onSessionChanged.listen((session) {
      // Convert stream event to BLoC event
      if (session != null) {
        add(StartFocusMode(
          type: session.type,
          duration: session.endTime != null
              ? session.endTime!.difference(DateTime.now())
              : null,
          studySessionId: session.studySessionId,
        ));
      }
    });
  }

  /// Initialize focus mode
  Future<void> _onInitialize(
    InitializeFocusMode event,
    Emitter<FocusModeState> emit,
  ) async {
    try {
      emit(const FocusModeLoading());

      // Initialize service
      await _focusModeService.init();

      // Start listening to session changes
      _startListening();

      // Check permission
      final hasPermission = await _dndManager.hasDndPermission();

      // Check if there's an active session
      if (_focusModeService.isFocusModeActive) {
        emit(FocusModeActive(
          session: _focusModeService.activeSession!,
          settings: _focusModeService.settings,
        ));
      } else {
        emit(FocusModeInactive(
          settings: _focusModeService.settings,
          hasDndPermission: hasPermission,
        ));
      }
    } catch (e) {
      emit(FocusModeError('فشل تحميل وضع التركيز: ${e.toString()}'));
    }
  }

  /// Start focus mode
  Future<void> _onStartFocusMode(
    StartFocusMode event,
    Emitter<FocusModeState> emit,
  ) async {
    try {
      emit(FocusModeStarting(event.type));

      final success = await _focusModeService.startFocusMode(
        type: event.type,
        duration: event.duration,
        studySessionId: event.studySessionId,
      );

      if (success) {
        emit(FocusModeActive(
          session: _focusModeService.activeSession!,
          settings: _focusModeService.settings,
        ));
      } else {
        emit(const FocusModeError('فشل تفعيل وضع التركيز'));
        await _checkPermissionAndEmitInactive();
      }
    } catch (e) {
      emit(FocusModeError('خطأ في تفعيل وضع التركيز: ${e.toString()}'));
      await _checkPermissionAndEmitInactive();
    }
  }

  /// End focus mode
  Future<void> _onEndFocusMode(
    EndFocusMode event,
    Emitter<FocusModeState> emit,
  ) async {
    try {
      if (_focusModeService.activeSession != null) {
        emit(FocusModeEnding(_focusModeService.activeSession!));

        final success = await _focusModeService.endFocusMode();

        if (success) {
          await _checkPermissionAndEmitInactive();
        } else {
          emit(const FocusModeError('فشل إيقاف وضع التركيز'));
        }
      }
    } catch (e) {
      emit(FocusModeError('خطأ في إيقاف وضع التركيز: ${e.toString()}'));
    }
  }

  /// Update settings
  Future<void> _onUpdateSettings(
    UpdateFocusModeSettings event,
    Emitter<FocusModeState> emit,
  ) async {
    try {
      await _focusModeService.updateSettings(event.settings);

      final hasPermission = await _dndManager.hasDndPermission();

      emit(FocusModeSettingsUpdated(
        settings: event.settings,
        hasDndPermission: hasPermission,
      ));

      // Return to appropriate state
      await Future.delayed(const Duration(milliseconds: 500));
      if (_focusModeService.isFocusModeActive) {
        emit(FocusModeActive(
          session: _focusModeService.activeSession!,
          settings: event.settings,
        ));
      } else {
        emit(FocusModeInactive(
          settings: event.settings,
          hasDndPermission: hasPermission,
        ));
      }
    } catch (e) {
      emit(FocusModeError('فشل تحديث الإعدادات: ${e.toString()}',
          settings: event.settings));
    }
  }

  /// Check DND permission
  Future<void> _onCheckPermission(
    CheckDndPermission event,
    Emitter<FocusModeState> emit,
  ) async {
    try {
      final hasPermission = await _dndManager.hasDndPermission();

      emit(DndPermissionChecked(
        hasPermission: hasPermission,
        settings: _focusModeService.settings,
      ));

      // Return to appropriate state
      await Future.delayed(const Duration(milliseconds: 500));
      await _checkPermissionAndEmitInactive();
    } catch (e) {
      emit(FocusModeError('فشل التحقق من الإذن: ${e.toString()}'));
    }
  }

  /// Request DND permission
  Future<void> _onRequestPermission(
    RequestDndPermission event,
    Emitter<FocusModeState> emit,
  ) async {
    try {
      await _dndManager.requestDndPermission();

      // Wait a bit for user to potentially grant permission
      await Future.delayed(const Duration(seconds: 2));

      // Check permission again
      add(const CheckDndPermission());
    } catch (e) {
      emit(FocusModeError('فشل طلب الإذن: ${e.toString()}'));
    }
  }

  /// Helper: Check permission and emit inactive state
  Future<void> _checkPermissionAndEmitInactive() async {
    final hasPermission = await _dndManager.hasDndPermission();
    emit(FocusModeInactive(
      settings: _focusModeService.settings,
      hasDndPermission: hasPermission,
    ));
  }

  @override
  Future<void> close() {
    // Cancel subscription
    _sessionSubscription?.cancel();
    return super.close();
  }
}
