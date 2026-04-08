import 'point.dart';

enum DiscoveryPlaybackStatus { played, skipped }

enum DiscoveryPlaybackSkipReason {
  autoplayDisabled,
  pausedByUser,
  manualAudioInProgress,
  autoAudioAlreadyPlayingPoi,
  scriptNotFound,
  missingScriptContent,
  missingPoiName,
}

class DiscoveryPlaybackResult {
  const DiscoveryPlaybackResult({
    required this.poi,
    required this.status,
    required this.language,
    this.scriptId,
    this.delayApplied = Duration.zero,
    this.skipReason,
    this.message,
  });

  final Point poi;
  final DiscoveryPlaybackStatus status;
  final String language;
  final String? scriptId;
  final Duration delayApplied;
  final DiscoveryPlaybackSkipReason? skipReason;
  final String? message;

  bool get played => status == DiscoveryPlaybackStatus.played;

  factory DiscoveryPlaybackResult.played({
    required Point poi,
    required String language,
    required String scriptId,
    required Duration delayApplied,
    String? message,
  }) {
    return DiscoveryPlaybackResult(
      poi: poi,
      status: DiscoveryPlaybackStatus.played,
      language: language,
      scriptId: scriptId,
      delayApplied: delayApplied,
      message: message,
    );
  }

  factory DiscoveryPlaybackResult.skipped({
    required Point poi,
    required String language,
    required DiscoveryPlaybackSkipReason reason,
    String? message,
  }) {
    return DiscoveryPlaybackResult(
      poi: poi,
      status: DiscoveryPlaybackStatus.skipped,
      language: language,
      skipReason: reason,
      message: message,
    );
  }
}
