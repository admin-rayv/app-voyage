import 'dart:async';

import 'package:audio_service/audio_service.dart' as audio_svc;
import 'package:audio_session/audio_session.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../models/point.dart' as models;
import 'debug_log.dart';
import 'tts_service.dart';

/// Handler audio TTS — basé sur l'exemple officiel TextPlayerHandler.
///
/// Pause/resume utilise flutter_tts.pause() natif qui sauvegarde la position
/// dans le texte via onRangeStart(). Au prochain speak(), flutter_tts reprend
/// automatiquement avec text.substring(pauseRangeStart).
///
/// Pattern clé: _run() reste bloqué pendant la pause (le Completer n'est PAS
/// complété). Sur resume, on appelle _flutterTts.speak() directement sans
/// passer par le wrapper — le completionHandler du wrapper complète le
/// Completer original quand la lecture finit.
class AppAudioHandler extends audio_svc.BaseAudioHandler {
  final FlutterTts _flutterTts = FlutterTts();

  /// Completer pour attendre la fin de la lecture en cours.
  Completer<void>? _speechCompleter;
  bool _stopped = false;
  bool _paused = false;

  // Timer pour la barre de progression dans l'UI
  Timer? _positionTimer;
  Duration _position = Duration.zero;

  // Métadonnées du POI en cours
  String? _currentText;
  String _currentLanguage = 'fr';
  String _currentPoiName = 'Lecture audio';
  models.Point? _currentPoi;
  Duration _estimatedDuration = Duration.zero;

  bool get _playing => playbackState.value.playing;

  String? get currentText => _currentText;
  String get currentLanguage => _currentLanguage;
  String get currentPoiName => _currentPoiName;
  models.Point? get currentPoi => _currentPoi;
  Duration get estimatedDuration => _estimatedDuration;

  AppAudioHandler() {
    _init();
  }

  Future<void> _init() async {
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.05);
    await _flutterTts.setSpeechRate(0.52);

    // Le completionHandler fire quand la lecture se termine naturellement.
    _flutterTts.setCompletionHandler(() {
      DebugLog().log('[Handler] TTS completionHandler');
      _speechCompleter?.complete();
    });

    // Le cancelHandler fire quand stop() est appelé.
    _flutterTts.setCancelHandler(() {
      DebugLog().log('[Handler] TTS cancelHandler');
      // Compléter seulement si c'est un vrai stop (pas une pause).
      // Pendant pause, on ne veut PAS compléter le Completer.
      if (_stopped) {
        _speechCompleter?.complete();
      }
    });

    // Le pauseHandler fire quand pause() est appelé.
    // On ne complète PAS le Completer — _run() reste bloqué.
    _flutterTts.setPauseHandler(() {
      DebugLog().log('[Handler] TTS pauseHandler');
      // Ne rien faire — le Completer reste en attente.
    });

    _flutterTts.setContinueHandler(() {
      DebugLog().log('[Handler] TTS continueHandler');
    });

    _flutterTts.setErrorHandler((msg) {
      DebugLog().log('[Handler] TTS erreur: $msg');
      _speechCompleter?.complete();
    });
  }

  /// Charger un texte à lire.
  Future<void> speakText(
    String text,
    String language,
    String poiName,
    models.Point? poi,
    Duration estimatedDuration,
  ) async {
    DebugLog().log('[Handler] speakText poi=$poiName lang=$language');

    // Arrêter la lecture en cours
    if (_playing || _speechCompleter != null) {
      await stop();
    }

    _currentText = text;
    _currentLanguage = language;
    _currentPoiName = poiName.trim().isEmpty ? 'Lecture audio' : poiName.trim();
    _currentPoi = poi;
    _estimatedDuration = estimatedDuration;
    _paused = false;
    _stopped = false;

    // Informer les clients du media item
    mediaItem.add(audio_svc.MediaItem(
      id: 'tts-${text.hashCode}',
      album: 'App Voyage',
      title: _currentPoiName,
      artist: 'Guide audio',
      duration: estimatedDuration,
    ));

    // Lancer la lecture
    await play();
  }

  @override
  Future<void> play() async {
    if (_playing) return;
    if ((_currentText ?? '').isEmpty) return;

    DebugLog().log('[Handler] play paused=$_paused');

    // Activer la session audio manuellement.
    final session = await AudioSession.instance;
    if (!(await session.setActive(true))) {
      DebugLog().log('[Handler] session audio refusée');
      return;
    }

    // Broadcaster l'état playing
    playbackState.add(playbackState.value.copyWith(
      controls: [
        audio_svc.MediaControl.pause,
        audio_svc.MediaControl.stop,
      ],
      androidCompactActionIndices: const [0, 1],
      processingState: audio_svc.AudioProcessingState.ready,
      playing: true,
      updatePosition: _position,
    ));

    // Forcer l'activation des boutons media sur Android
    audio_svc.AudioService.androidForceEnableMediaButtons();

    // Démarrer le timer de position
    _startPositionUpdates();

    if (_paused) {
      // RESUME: appeler speak() directement — flutter_tts reprend à
      // text.substring(pauseRangeStart) automatiquement.
      // Le Completer existant de _run() est toujours en attente.
      _paused = false;
      DebugLog().log('[Handler] resume: _flutterTts.speak()');
      await _flutterTts.speak(_currentText!);
      // Le completionHandler va compléter le _speechCompleter de _run()
      // quand la lecture finit.
    } else {
      // NOUVELLE LECTURE
      _run();
    }
  }

  /// Lecture initiale.
  Future<void> _run() async {
    _stopped = false;
    _paused = false;

    // Configurer la voix
    DebugLog().log('[Handler] config voix lang=$_currentLanguage');
    try {
      await TtsService.configureVoiceForTts(_flutterTts, _currentLanguage);
    } catch (e) {
      DebugLog().log('[Handler] erreur config voix: $e');
    }

    // Créer le Completer AVANT speak
    _speechCompleter = Completer<void>();

    // Lancer la lecture
    DebugLog().log('[Handler] _flutterTts.speak() start');
    await _flutterTts.speak(_currentText!);

    // Attendre que le Completer soit complété:
    // - Par completionHandler (fin naturelle)
    // - Par cancelHandler (stop)
    // - PAS par pauseHandler (pause garde le Completer en attente)
    await _speechCompleter!.future;
    _speechCompleter = null;

    DebugLog().log('[Handler] _run terminé stopped=$_stopped');

    // Si c'est un stop, ne rien faire (stop() a déjà mis l'état idle)
    if (_stopped) return;

    // Lecture terminée naturellement
    _stopPositionUpdates();
    _position = _estimatedDuration;
    playbackState.add(playbackState.value.copyWith(
      controls: [audio_svc.MediaControl.play],
      androidCompactActionIndices: const [0],
      processingState: audio_svc.AudioProcessingState.completed,
      playing: false,
      updatePosition: _estimatedDuration,
    ));
  }

  @override
  Future<void> pause() async {
    DebugLog().log('[Handler] pause');

    _paused = true;
    _stopPositionUpdates();

    playbackState.add(playbackState.value.copyWith(
      controls: [
        audio_svc.MediaControl.play,
        audio_svc.MediaControl.stop,
      ],
      androidCompactActionIndices: const [0, 1],
      processingState: audio_svc.AudioProcessingState.ready,
      playing: false,
      updatePosition: _position,
    ));

    // Pause natif flutter_tts — sauvegarde la position dans le texte.
    // Le pauseHandler va fire mais ne complète PAS le Completer.
    await _flutterTts.pause();
  }

  @override
  Future<void> stop() async {
    DebugLog().log('[Handler] stop');

    _stopped = true;
    _paused = false;
    _stopPositionUpdates();
    _position = Duration.zero;

    playbackState.add(playbackState.value.copyWith(
      controls: [],
      androidCompactActionIndices: const [],
      processingState: audio_svc.AudioProcessingState.idle,
      playing: false,
      updatePosition: Duration.zero,
    ));

    // Stop flutter_tts — le cancelHandler va compléter le Completer
    // car _stopped = true.
    await _flutterTts.stop();

    // Désactiver la notification
    await super.stop();
  }

  /// Changer la vitesse de lecture.
  Future<void> setSpeed(double speed) async {
    DebugLog().log('[Handler] setSpeed=$speed');
    await _flutterTts.setSpeechRate(speed);
  }

  /// Timer de position pour la barre de progression UI.
  void _startPositionUpdates() {
    _positionTimer?.cancel();
    _positionTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      final next = _position + const Duration(milliseconds: 500);
      _position = next > _estimatedDuration ? _estimatedDuration : next;
      playbackState.add(playbackState.value.copyWith(
        updatePosition: _position,
      ));
    });
  }

  void _stopPositionUpdates() {
    _positionTimer?.cancel();
    _positionTimer = null;
  }
}
