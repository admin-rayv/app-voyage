import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/audio_state.dart';
import '../models/point.dart';
import 'audio_service.dart';
import 'debug_log.dart';
import 'supabase_service.dart';
import 'user_preferences_service.dart';

/// Un participant d'une session de groupe (via Supabase Presence).
class GroupParticipant {
  const GroupParticipant({
    required this.key,
    required this.label,
    required this.isHost,
    required this.isMe,
  });

  final String key;
  final String label;
  final bool isHost;
  final bool isMe;
}

/// Script relayé par l'hôte dans le message `play` (mode invité).
class RelayedScript {
  const RelayedScript({
    required this.id,
    required this.language,
    required this.content,
  });

  final String? id;
  final String language;
  final String content;
}

/// Sync groupe « Écouter ensemble » (mode Host) — Supabase Realtime.
///
/// Architecture: un canal Realtime par session (`group:CODE`), sans table.
/// - **Presence** fournit la liste des participants en direct.
/// - **Broadcast** transporte les commandes du Host: play/pause/resume/stop
///   avec l'ID du POI. Chaque membre joue le script du POI **dans sa propre
///   langue** — la sync est à la seconde (suffisant pour de la narration),
///   sans seek.
///
/// **Le contenu transite par la session, pas par la base**: sur `play`,
/// le Host (qui a accès à la ville) joint le POI et ses scripts dans
/// toutes les langues au message. Les invités jouent ce qui leur est
/// relayé sans requête DB — ils suivent la visite sans « recevoir » la
/// ville. C'est la plomberie du futur modèle payant: quand l'accès aux
/// villes sera verrouillé côté serveur (comptes + RLS), les sessions de
/// groupe continueront de fonctionner pour les invités non-acheteurs.
/// (Un fallback DB est conservé si le message ne contient pas le contenu
/// — ancien hôte — et reste possible tant que la base est publique.)
///
/// Seul le Host diffuse (il écoute AudioService.stateStream); les membres
/// appliquent les commandes reçues. Pas de compte requis (Sprint 10).
class GroupSessionService {
  GroupSessionService._internal();

  static final GroupSessionService _instance = GroupSessionService._internal();
  factory GroupSessionService() => _instance;

  /// Alphabet sans caractères ambigus (pas de I/L/O/0/1).
  static const String codeAlphabet = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
  static const int codeLength = 6;
  static const Duration _connectTimeout = Duration(seconds: 10);

  final Random _random = Random.secure();

  RealtimeChannel? _channel;
  StreamSubscription<AudioState>? _audioSubscription;
  bool _isHost = false;
  String? _lastBroadcastKey;
  AudioPlayState _lastHostPlayState = AudioPlayState.stopped;
  String? _lastHostPoiId;
  String? _applyingPoiId;

  /// File d'envoi du Host: les scripts d'un `play` sont récupérés avant
  /// l'envoi — la chaîne garantit que pause/stop ne doublent pas un play
  /// encore en préparation.
  Future<void> _sendChain = Future<void>.value();

  /// Cache des scripts déjà relayés (par POI) — évite de re-requêter la
  /// base quand le Host rejoue le même POI.
  final Map<String, Map<String, dynamic>> _relayedScriptsCache = {};

  late final String _myKey = _generateKey();
  late final String _myLabel = _generateLabel();

  /// Code de la session active (null si aucune) — pour l'UI.
  final ValueNotifier<String?> activeCode = ValueNotifier<String?>(null);

  /// Participants de la session active.
  final ValueNotifier<List<GroupParticipant>> participants =
      ValueNotifier<List<GroupParticipant>>(const []);

  bool get isHost => _isHost;
  bool get isActive => _channel != null;
  String get myLabel => _myLabel;

  /// Générer un code de session lisible (6 caractères non ambigus).
  String generateCode() {
    return List.generate(
      codeLength,
      (_) => codeAlphabet[_random.nextInt(codeAlphabet.length)],
    ).join();
  }

  /// Normaliser un code saisi par l'utilisateur.
  static String normalizeCode(String rawCode) {
    return rawCode.trim().toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
  }

  /// Valider la forme d'un code.
  static bool isValidCode(String code) {
    if (code.length != codeLength) return false;
    return code.split('').every(codeAlphabet.contains);
  }

  /// Créer une session — retourne le code, ou null si échec de connexion.
  Future<String?> createSession() async {
    final code = generateCode();
    final connected = await _connect(code, host: true);
    return connected ? code : null;
  }

  /// Rejoindre une session existante par code.
  Future<bool> joinSession(String rawCode) async {
    final code = normalizeCode(rawCode);
    if (!isValidCode(code)) return false;
    return _connect(code, host: false);
  }

  /// Quitter (membre) ou terminer (host) la session.
  Future<void> leaveSession() async {
    await _audioSubscription?.cancel();
    _audioSubscription = null;

    final channel = _channel;
    final wasGuest = channel != null && !_isHost;
    _channel = null;
    _isHost = false;
    _lastBroadcastKey = null;
    _lastHostPlayState = AudioPlayState.stopped;
    _lastHostPoiId = null;
    _sendChain = Future<void>.value();
    _relayedScriptsCache.clear();
    activeCode.value = null;
    participants.value = const [];

    if (channel != null) {
      try {
        await channel.untrack();
      } catch (_) {}
      try {
        await SupabaseService.client.removeChannel(channel);
      } catch (_) {}
      DebugLog().log('[GroupSession] left session');
    }

    // Un invité qui quitte n'emporte pas le contenu: on coupe la lecture
    // relayée. (L'hôte, lui, garde sa propre lecture.)
    if (wasGuest) {
      try {
        await AudioService().stop();
      } catch (_) {}
    }
  }

  Future<bool> _connect(String code, {required bool host}) async {
    await leaveSession();

    final channel = SupabaseService.client.channel(
      'group:$code',
      opts: const RealtimeChannelConfig(self: false),
    );

    channel
      ..onBroadcast(event: 'sync', callback: _handleSyncMessage)
      ..onPresenceSync((_) => _refreshParticipants())
      ..onPresenceJoin((_) => _refreshParticipants())
      ..onPresenceLeave((_) => _refreshParticipants());

    final completer = Completer<bool>();
    channel.subscribe((status, error) async {
      DebugLog().log('[GroupSession] channel status=$status error=$error');
      if (status == RealtimeSubscribeStatus.subscribed) {
        try {
          await channel.track({
            'key': _myKey,
            'label': _myLabel,
            'isHost': host,
          });
        } catch (trackError) {
          DebugLog().log('[GroupSession] track failed: $trackError');
        }
        if (!completer.isCompleted) completer.complete(true);
      } else if (status == RealtimeSubscribeStatus.channelError ||
          status == RealtimeSubscribeStatus.timedOut ||
          status == RealtimeSubscribeStatus.closed) {
        if (!completer.isCompleted) completer.complete(false);
      }
    });

    final connected = await completer.future.timeout(
      _connectTimeout,
      onTimeout: () => false,
    );

    if (!connected) {
      try {
        await SupabaseService.client.removeChannel(channel);
      } catch (_) {}
      DebugLog().log('[GroupSession] connection failed code=$code');
      return false;
    }

    _channel = channel;
    _isHost = host;
    activeCode.value = code;

    if (host) {
      _startHostBroadcasting();
    }

    DebugLog().log(
      '[GroupSession] connected code=$code host=$host label=$_myLabel',
    );
    return true;
  }

  // ── Host: diffusion des changements d'état audio ──

  void _startHostBroadcasting() {
    _audioSubscription = AudioService().stateStream.listen((state) {
      final poiId = state.currentPoi?.id;
      String? type;

      switch (state.playState) {
        case AudioPlayState.playing:
          if (poiId == null) break;
          type = (_lastHostPlayState == AudioPlayState.paused &&
                  _lastHostPoiId == poiId)
              ? 'resume'
              : 'play';
          break;
        case AudioPlayState.paused:
          type = 'pause';
          break;
        case AudioPlayState.stopped:
          // Ne diffuser stop que si quelque chose jouait.
          type = _lastHostPlayState == AudioPlayState.stopped ? null : 'stop';
          break;
      }

      final broadcastKey = '$type:$poiId';
      if (type != null && broadcastKey != _lastBroadcastKey) {
        _lastBroadcastKey = broadcastKey;
        final sendType = type;
        // Sur play: joindre le POI + ses scripts (contenu relayé aux
        // invités). La chaîne préserve l'ordre des messages.
        final poi = sendType == 'play' ? state.currentPoi : null;
        _sendChain = _sendChain.then(
          (_) => _sendSync(type: sendType, poiId: poiId, poi: poi),
        );
      }

      _lastHostPlayState = state.playState;
      if (poiId != null) {
        _lastHostPoiId = poiId;
      }
    });
  }

  Future<void> _sendSync({
    required String type,
    String? poiId,
    Point? poi,
  }) async {
    final channel = _channel;
    if (channel == null) return;

    try {
      await channel.sendBroadcastMessage(
        event: 'sync',
        payload: <String, dynamic>{
          'type': type,
          'poiId': ?poiId,
          'from': _myKey,
          if (poi != null) 'poi': poi.toJson(),
          if (poi != null) 'scripts': await _relayedScripts(poi.id),
        },
      );
      DebugLog().log('[GroupSession] sent $type poi=$poiId');
    } catch (error) {
      DebugLog().log('[GroupSession] broadcast failed: $error');
    }
  }

  /// Scripts d'un POI groupés par langue (`{fr: {id, content}, …}`) pour
  /// le message relayé. Vide en cas d'erreur → les invités retomberont
  /// sur le fallback DB.
  Future<Map<String, dynamic>> _relayedScripts(String poiId) async {
    final cached = _relayedScriptsCache[poiId];
    if (cached != null) return cached;

    final byLanguage = <String, dynamic>{};
    try {
      for (final script in await SupabaseService.getScriptsForPoint(poiId)) {
        final language = script['language'] as String?;
        final content = (script['content'] as String? ?? '').trim();
        if (language == null || content.isEmpty) continue;
        byLanguage[language] = {'id': script['id'], 'content': content};
      }
      _relayedScriptsCache[poiId] = byLanguage;
    } catch (error) {
      DebugLog().log('[GroupSession] scripts fetch failed poi=$poiId: $error');
    }
    return byLanguage;
  }

  // ── Membre: application des commandes du Host ──

  void _handleSyncMessage(Map<String, dynamic> payload) {
    if (_isHost) return;
    unawaited(_applySync(payload));
  }

  Future<void> _applySync(Map<String, dynamic> payload) async {
    final type = payload['type'] as String?;
    final poiId = payload['poiId'] as String?;
    DebugLog().log('[GroupSession] received $type poi=$poiId');

    final audio = AudioService();
    switch (type) {
      case 'play':
        if (poiId == null || poiId == _applyingPoiId) return;
        // Déjà en train de jouer ce POI → rien à faire.
        final current = audio.currentState;
        if (current.playState == AudioPlayState.playing &&
            current.currentPoi?.id == poiId) {
          return;
        }
        _applyingPoiId = poiId;
        try {
          await _playPoi(audio, poiId, payload);
        } finally {
          _applyingPoiId = null;
        }
        break;
      case 'resume':
        await audio.resume();
        break;
      case 'pause':
        await audio.pause();
        break;
      case 'stop':
        await audio.stop();
        break;
    }
  }

  /// Jouer le script d'un POI dans la langue préférée DU MEMBRE — le
  /// groupe peut être multilingue, chacun écoute Marco dans sa langue.
  ///
  /// Le contenu vient d'abord du message relayé par l'hôte (`poi` +
  /// `scripts`) — l'invité n'a pas besoin d'accès à la ville. Fallback DB
  /// si le message n'en contient pas (hôte sur une ancienne version).
  Future<void> _playPoi(
    AudioService audio,
    String poiId,
    Map<String, dynamic> payload,
  ) async {
    final language = await UserPreferencesService.getPreferredLanguage();

    // 1. Contenu relayé par l'hôte.
    final relayedPoi = payload['poi'];
    final relayedScripts = payload['scripts'];
    if (relayedPoi is Map && relayedScripts is Map) {
      final script = pickRelayedScript(
        Map<String, dynamic>.from(relayedScripts),
        language,
      );
      if (script != null) {
        final poi = Point.fromJson(Map<String, dynamic>.from(relayedPoi));
        await audio.playText(
          script.content,
          language: script.language,
          poiName: poi.localizedName(script.language),
          poi: poi,
          scriptId: script.id,
          source: AudioPlaybackSource.manual,
        );
        return;
      }
      DebugLog().log('[GroupSession] relayed payload sans script exploitable');
    }

    // 2. Fallback: lecture directe en base (hôte sur une ancienne version).
    //    Restera fonctionnel tant que la base est en lecture publique.
    final pointJson = await SupabaseService.getPoint(poiId);
    if (pointJson == null) {
      DebugLog().log('[GroupSession] point not found poi=$poiId');
      return;
    }
    final poi = Point.fromJson(pointJson);

    final script = await SupabaseService.getScriptForPointWithFallback(
      poi.id,
      <String>{language, 'fr', 'en'}.toList(),
    );
    if (script == null) {
      DebugLog().log('[GroupSession] no script poi=$poiId lang=$language');
      return;
    }

    final content = (script['content'] as String? ?? '').trim();
    final scriptLanguage = script['language'] as String? ?? language;
    if (content.isEmpty) return;

    await audio.playText(
      content,
      language: scriptLanguage,
      poiName: poi.localizedName(scriptLanguage),
      poi: poi,
      scriptId: script['id'] as String?,
      source: AudioPlaybackSource.manual,
    );
  }

  /// Choisir le script relayé dans la langue préférée du membre, avec
  /// fallback fr → en → n'importe quelle langue disponible.
  @visibleForTesting
  static RelayedScript? pickRelayedScript(
    Map<String, dynamic> scriptsByLanguage,
    String preferredLanguage,
  ) {
    final candidates = <String>[
      preferredLanguage,
      'fr',
      'en',
      ...scriptsByLanguage.keys,
    ];
    for (final language in candidates) {
      final raw = scriptsByLanguage[language];
      if (raw is! Map) continue;
      final content = (raw['content'] as String? ?? '').trim();
      if (content.isEmpty) continue;
      return RelayedScript(
        id: raw['id'] as String?,
        language: language,
        content: content,
      );
    }
    return null;
  }

  // ── Presence → liste des participants ──

  void _refreshParticipants() {
    final channel = _channel;
    if (channel == null) {
      participants.value = const [];
      return;
    }

    final result = <GroupParticipant>[];
    try {
      for (final state in channel.presenceState()) {
        for (final presence in state.presences) {
          final payload = presence.payload;
          final key = payload['key']?.toString() ?? presence.presenceRef;
          result.add(
            GroupParticipant(
              key: key,
              label: payload['label']?.toString() ?? '—',
              isHost: payload['isHost'] == true,
              isMe: key == _myKey,
            ),
          );
        }
      }
    } catch (error) {
      DebugLog().log('[GroupSession] presence parse error: $error');
    }

    // Host d'abord, puis par label.
    result.sort((a, b) {
      if (a.isHost != b.isHost) return a.isHost ? -1 : 1;
      return a.label.compareTo(b.label);
    });
    participants.value = result;
    DebugLog().log('[GroupSession] participants=${result.length}');
  }

  String _generateKey() {
    return List.generate(
      16,
      (_) => codeAlphabet[_random.nextInt(codeAlphabet.length)],
    ).join();
  }

  /// Étiquette amicale pour la liste des participants (pas de compte).
  String _generateLabel() {
    const names = [
      'Explorateur', 'Voyageuse', 'Curieux', 'Flâneuse', 'Marcheur',
      'Aventurière', 'Promeneur', 'Globe-trotteuse',
    ];
    final name = names[_random.nextInt(names.length)];
    final suffix = _random.nextInt(90) + 10;
    return '$name-$suffix';
  }

  @visibleForTesting
  void debugReset() {
    _channel = null;
    _isHost = false;
    activeCode.value = null;
    participants.value = const [];
  }
}
