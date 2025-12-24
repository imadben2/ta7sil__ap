import 'package:equatable/equatable.dart';

/// Base class for all sponsors events
abstract class SponsorsEvent extends Equatable {
  const SponsorsEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load sponsors from API
class LoadSponsors extends SponsorsEvent {
  const LoadSponsors();
}

/// Event to refresh sponsors
class RefreshSponsors extends SponsorsEvent {
  const RefreshSponsors();
}

/// Event to record a click on a sponsor's social link
class RecordSponsorClick extends SponsorsEvent {
  final int sponsorId;
  final String platform; // youtube, facebook, instagram, telegram, or general

  const RecordSponsorClick(this.sponsorId, {this.platform = 'general'});

  @override
  List<Object?> get props => [sponsorId, platform];
}
