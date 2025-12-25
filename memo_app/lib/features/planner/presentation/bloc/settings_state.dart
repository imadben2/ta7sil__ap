import 'package:equatable/equatable.dart';
import '../../domain/entities/planner_settings.dart';
import '../../../../core/errors/failures.dart';

/// State for SettingsCubit
class SettingsState extends Equatable {
  final PlannerSettings? settings;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final Failure? failure;
  final String? successMessage;
  final bool hasUnsavedChanges;

  const SettingsState({
    this.settings,
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.failure,
    this.successMessage,
    this.hasUnsavedChanges = false,
  });

  /// Initial state
  factory SettingsState.initial() {
    return const SettingsState();
  }

  /// Loading state
  SettingsState loading() {
    return copyWith(isLoading: true, errorMessage: null, successMessage: null);
  }

  /// Saving state
  SettingsState saving() {
    return copyWith(isSaving: true, errorMessage: null, successMessage: null);
  }

  /// Loaded state
  SettingsState loaded(PlannerSettings settings) {
    return copyWith(
      settings: settings,
      isLoading: false,
      isSaving: false,
      successMessage: null,
    );
  }

  /// Saved state
  SettingsState saved(PlannerSettings settings, String message) {
    return copyWith(
      settings: settings,
      isLoading: false,
      isSaving: false,
      successMessage: message,
      hasUnsavedChanges: false,
    );
  }

  /// Updated locally (not saved to API yet)
  SettingsState updatedLocally(PlannerSettings settings) {
    return copyWith(
      settings: settings,
      hasUnsavedChanges: true,
    );
  }

  /// Error state
  SettingsState error(String message, {Failure? failure}) {
    return copyWith(
      isLoading: false,
      isSaving: false,
      errorMessage: message,
      failure: failure,
    );
  }

  /// Check if settings are available
  bool get hasSettings => settings != null;

  /// Check if any operation is in progress
  bool get isProcessing => isLoading || isSaving;

  /// Copy with method
  SettingsState copyWith({
    PlannerSettings? settings,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    Failure? failure,
    String? successMessage,
    bool? hasUnsavedChanges,
  }) {
    return SettingsState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
      failure: failure,
      successMessage: successMessage,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
    );
  }

  @override
  List<Object?> get props => [
    settings,
    isLoading,
    isSaving,
    errorMessage,
    failure,
    successMessage,
    hasUnsavedChanges,
  ];

  // Convenience getter for error message
  String? get message => errorMessage;
}

// Convenience state classes
class SettingsLoading extends SettingsState {
  const SettingsLoading() : super(isLoading: true);
}

class SettingsLoaded extends SettingsState {
  const SettingsLoaded(PlannerSettings settings) : super(settings: settings);

  PlannerSettings get loadedSettings => settings!;
}

class SettingsError extends SettingsState {
  const SettingsError(String message) : super(errorMessage: message);

  @override
  String? get message => errorMessage;
}
