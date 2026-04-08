import 'dart:async';

import 'package:flutter/services.dart';

import '../models/audio_state.dart';
import '../models/discovery_playback_result.dart';
import '../models/point.dart';
import 'audio_service.dart';
import 'debug_log.dart';
import 'supabase_service.dart';
import 'user_preferences_service.dart';

class DiscoveryPlaybackService {
  DiscoveryPlaybackService({AudioService? audioService})
    : _audioService = audioService ?? AudioService();

  final AudioService _audioService;

  Future<DiscoveryPlaybackResult> handleTriggeredPoi(Point poi) async {
    final autoplayEnabled =
        await UserPreferencesService.isDiscoveryAutoplayEnabled();
    final preferredLanguage =
        await UserPreferencesService.getPreferredLanguage();

    if (!autoplayEnabled) {
      _logSkip(poi, preferredLanguage, 'autoplay_disabled');
      return DiscoveryPlaybackResult.skipped(
        poi: poi,
        language: preferredLanguage,
        reason: DiscoveryPlaybackSkipReason.autoplayDisabled,
        message: 'Lecture automatique désactivée.',
      );
    }

    await _audioService.init();
    final audioState = _audioService.currentState;

    if (audioState.playState == AudioPlayState.paused) {
      _logSkip(poi, preferredLanguage, 'paused_by_user');
      return DiscoveryPlaybackResult.skipped(
        poi: poi,
        language: preferredLanguage,
        reason: DiscoveryPlaybackSkipReason.pausedByUser,
        message: 'Lecture en pause, auto-play ignoré.',
      );
    }

    if (audioState.playState == AudioPlayState.playing &&
        audioState.playbackSource == AudioPlaybackSource.manual) {
      _logSkip(poi, preferredLanguage, 'manual_audio_in_progress');
      return DiscoveryPlaybackResult.skipped(
        poi: poi,
        language: preferredLanguage,
        reason: DiscoveryPlaybackSkipReason.manualAudioInProgress,
        message: 'Lecture manuelle en cours, auto-play ignoré.',
      );
    }

    if (audioState.playState == AudioPlayState.playing &&
        audioState.playbackSource == AudioPlaybackSource.autoDiscovery &&
        audioState.currentPoi?.id == poi.id) {
      _logSkip(poi, preferredLanguage, 'auto_audio_already_playing_same_poi');
      return DiscoveryPlaybackResult.skipped(
        poi: poi,
        language: preferredLanguage,
        reason: DiscoveryPlaybackSkipReason.autoAudioAlreadyPlayingPoi,
        message: 'Ce POI est déjà en lecture automatique.',
      );
    }

    final script = await _resolveScriptWithFallback(poi.id, preferredLanguage);
    if (script == null) {
      _logSkip(poi, preferredLanguage, 'script_not_found');
      return DiscoveryPlaybackResult.skipped(
        poi: poi,
        language: preferredLanguage,
        reason: DiscoveryPlaybackSkipReason.scriptNotFound,
        message: 'Aucun script disponible pour ce POI.',
      );
    }

    final content = (script['content'] as String? ?? '').trim();
    final language = script['language'] as String? ?? preferredLanguage;
    final scriptId = script['id'] as String?;
    final poiName = poi.localizedName(language).trim();

    if (content.isEmpty || scriptId == null || scriptId.isEmpty) {
      _logSkip(poi, language, 'missing_script_content');
      return DiscoveryPlaybackResult.skipped(
        poi: poi,
        language: language,
        reason: DiscoveryPlaybackSkipReason.missingScriptContent,
        message: 'Script incomplet, lecture ignorée.',
      );
    }

    if (poiName.isEmpty) {
      _logSkip(poi, language, 'missing_poi_name');
      return DiscoveryPlaybackResult.skipped(
        poi: poi,
        language: language,
        reason: DiscoveryPlaybackSkipReason.missingPoiName,
        message: 'Nom de POI indisponible, lecture ignorée.',
      );
    }

    if (audioState.playState == AudioPlayState.playing &&
        audioState.playbackSource == AudioPlaybackSource.autoDiscovery) {
      DebugLog().log(
        '[DiscoveryPlayback] stop previous auto audio poi=${audioState.currentPoi?.id}',
      );
      await _audioService.stop();
    }

    final vibrationEnabled =
        await UserPreferencesService.isDiscoveryAutoplayVibrationEnabled();
    if (vibrationEnabled) {
      await HapticFeedback.mediumImpact();
    }

    final delaySec =
        await UserPreferencesService.getDiscoveryAutoplayDelaySec();
    final delay = Duration(seconds: delaySec);
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }

    final refreshedState = _audioService.currentState;
    if (refreshedState.playState == AudioPlayState.paused ||
        (refreshedState.playState == AudioPlayState.playing &&
            refreshedState.playbackSource == AudioPlaybackSource.manual)) {
      _logSkip(poi, language, 'conflict_after_delay');
      return DiscoveryPlaybackResult.skipped(
        poi: poi,
        language: language,
        reason: refreshedState.playState == AudioPlayState.paused
            ? DiscoveryPlaybackSkipReason.pausedByUser
            : DiscoveryPlaybackSkipReason.manualAudioInProgress,
        message: 'Conflit audio détecté avant lecture.',
      );
    }

    if (refreshedState.playState == AudioPlayState.playing &&
        refreshedState.playbackSource == AudioPlaybackSource.autoDiscovery) {
      await _audioService.stop();
    }

    await _audioService.playText(
      content,
      language: language,
      poiName: poiName,
      poi: poi,
      scriptId: scriptId,
      source: AudioPlaybackSource.autoDiscovery,
    );

    DebugLog().log(
      '[DiscoveryPlayback] played poi=${poi.id} lang=$language delay=${delay.inSeconds}s script=$scriptId',
    );

    return DiscoveryPlaybackResult.played(
      poi: poi,
      language: language,
      scriptId: scriptId,
      delayApplied: delay,
      message: 'Lecture automatique lancée.',
    );
  }

  Future<Map<String, dynamic>?> _resolveScriptWithFallback(
    String pointId,
    String preferredLanguage,
  ) async {
    return SupabaseService.getScriptForPointWithFallback(
      pointId,
      _fallbackLanguages(preferredLanguage),
    );
  }

  List<String> _fallbackLanguages(String preferredLanguage) {
    final ordered = <String>[
      preferredLanguage,
      UserPreferencesService.defaultPreferredLanguage,
      'en',
    ];
    return ordered.toSet().toList();
  }

  void _logSkip(Point poi, String language, String reason) {
    DebugLog().log(
      '[DiscoveryPlayback] skipped poi=${poi.id} lang=$language reason=$reason',
    );
  }
}
