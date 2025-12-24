import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_sponsors_usecase.dart';
import '../../../domain/usecases/record_sponsor_click_usecase.dart';
import 'sponsors_event.dart';
import 'sponsors_state.dart';

/// BLoC for managing sponsors state
/// Handles loading sponsors from API and recording clicks
class SponsorsBloc extends Bloc<SponsorsEvent, SponsorsState> {
  final GetSponsorsUseCase getSponsorsUseCase;
  final RecordSponsorClickUseCase recordSponsorClickUseCase;

  SponsorsBloc({
    required this.getSponsorsUseCase,
    required this.recordSponsorClickUseCase,
  }) : super(const SponsorsInitial()) {
    on<LoadSponsors>(_onLoadSponsors);
    on<RefreshSponsors>(_onRefreshSponsors);
    on<RecordSponsorClick>(_onRecordSponsorClick);
  }

  /// Handle load sponsors event
  Future<void> _onLoadSponsors(
    LoadSponsors event,
    Emitter<SponsorsState> emit,
  ) async {
    emit(const SponsorsLoading());

    final result = await getSponsorsUseCase();

    result.fold(
      (failure) => emit(SponsorsError(message: failure.message)),
      (response) => emit(SponsorsLoaded(
        sponsors: response.sponsors,
        sectionEnabled: response.sectionEnabled,
      )),
    );
  }

  /// Handle refresh sponsors event
  Future<void> _onRefreshSponsors(
    RefreshSponsors event,
    Emitter<SponsorsState> emit,
  ) async {
    // Keep current data while refreshing
    final currentState = state is SponsorsLoaded
        ? state as SponsorsLoaded
        : null;

    final result = await getSponsorsUseCase();

    result.fold(
      (failure) {
        // If we have cached data, keep showing it
        if (currentState != null) {
          emit(SponsorsLoaded(
            sponsors: currentState.sponsors,
            sectionEnabled: currentState.sectionEnabled,
          ));
        } else {
          emit(SponsorsError(message: failure.message));
        }
      },
      (response) => emit(SponsorsLoaded(
        sponsors: response.sponsors,
        sectionEnabled: response.sectionEnabled,
      )),
    );
  }

  /// Handle record sponsor click event
  /// Tracks clicks per platform (youtube, facebook, instagram, telegram, general)
  Future<void> _onRecordSponsorClick(
    RecordSponsorClick event,
    Emitter<SponsorsState> emit,
  ) async {
    // Record click in background with platform info
    await recordSponsorClickUseCase(event.sponsorId, platform: event.platform);

    // Optionally update local click count for immediate feedback
    if (state is SponsorsLoaded) {
      final currentState = state as SponsorsLoaded;
      final updatedSponsors = currentState.sponsors.map((sponsor) {
        if (sponsor.id == event.sponsorId) {
          // Update both total and platform-specific click count
          return sponsor.copyWith(
            clickCount: sponsor.clickCount + 1,
            youtubeClicks: event.platform == 'youtube'
                ? sponsor.youtubeClicks + 1
                : sponsor.youtubeClicks,
            facebookClicks: event.platform == 'facebook'
                ? sponsor.facebookClicks + 1
                : sponsor.facebookClicks,
            instagramClicks: event.platform == 'instagram'
                ? sponsor.instagramClicks + 1
                : sponsor.instagramClicks,
            telegramClicks: event.platform == 'telegram'
                ? sponsor.telegramClicks + 1
                : sponsor.telegramClicks,
          );
        }
        return sponsor;
      }).toList();

      emit(SponsorsLoaded(
        sponsors: updatedSponsors,
        sectionEnabled: currentState.sectionEnabled,
      ));
    }
  }
}
