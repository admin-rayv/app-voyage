import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'debug_log.dart';

/// Service Edge TTS — Génère de l'audio via Microsoft Edge TTS + cache local.
///
/// Priorité: cache local → Edge TTS (si internet) → null (fallback au TTS natif)
/// Les MP3 sont cachés dans le dossier app pour réutilisation offline.

/// Jeton anti-abus exigé par l'API Edge depuis fin 2024 (paramètre
/// `Sec-MS-GEC`): SHA-256 de l'heure courante en "Windows file time"
/// arrondie aux 5 minutes, concaténée au TrustedClientToken. Sans lui,
/// le serveur répond 403. Algorithme répliqué de la librairie de
/// référence edge-tts (Python), incluant la correction de décalage
/// d'horloge si celle du téléphone est trop désynchronisée.
class EdgeTtsDrm {
  static const String trustedClientToken = '6A5AA1D4EAFF4E9FB37E23D68491D6F4';

  /// Décalage appliqué à l'horloge locale (corrigé après un refus serveur).
  static int clockSkewSeconds = 0;

  static String secMsGec({int? unixSeconds}) {
    var seconds = (unixSeconds ??
            DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000) +
        clockSkewSeconds;
    // Epoch Windows (1601-01-01), arrondi aux 5 min, en intervalles de 100 ns.
    seconds += 11644473600;
    seconds -= seconds % 300;
    final ticks = seconds * 10000000;
    final digest = sha256.convert(ascii.encode('$ticks$trustedClientToken'));
    return digest.toString().toUpperCase();
  }

  /// Recale [clockSkewSeconds] sur l'heure du serveur (header Date de
  /// l'endpoint public de la liste des voix).
  static Future<void> syncClockSkew() async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(EdgeTtsService._voiceListUrl));
      EdgeTtsService._baseHeaders.forEach(request.headers.set);
      final response = await request.close();
      await response.drain<void>();
      final serverDate = response.headers.date;
      if (serverDate != null) {
        clockSkewSeconds = serverDate
            .toUtc()
            .difference(DateTime.now().toUtc())
            .inSeconds;
        DebugLog().log('[EdgeTTS] horloge recalée: ${clockSkewSeconds}s');
      }
    } finally {
      client.close(force: true);
    }
  }
}

class EdgeTtsService {
  // Voix par langue — voix masculines pour Marco
  static const Map<String, String> _voices = {
    'fr': 'fr-CA-ThierryNeural',
    'en': 'en-US-GuyNeural',
    'es': 'es-MX-JorgeNeural',
  };

  // Edge TTS WebSocket config — doit suivre la librairie de référence
  // edge-tts (version Chromium, en-têtes, jeton Sec-MS-GEC), sinon 403.
  static const String _chromiumFullVersion = '143.0.3650.75';
  static const String _chromiumMajor = '143';
  static const String _secMsGecVersion = '1-$_chromiumFullVersion';
  static const String _baseUrl =
      'speech.platform.bing.com/consumer/speech/synthesize/readaloud';
  static const String _wsUrl =
      'wss://$_baseUrl/edge/v1?TrustedClientToken=${EdgeTtsDrm.trustedClientToken}';
  static const String _voiceListUrl =
      'https://$_baseUrl/voices/list?trustedclienttoken=${EdgeTtsDrm.trustedClientToken}';

  static const Map<String, String> _baseHeaders = {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
            '(KHTML, like Gecko) Chrome/$_chromiumMajor.0.0.0 Safari/537.36 '
            'Edg/$_chromiumMajor.0.0.0',
    'Accept-Language': 'en-US,en;q=0.9',
  };

  /// Obtenir le chemin du fichier audio caché pour un script donné.
  ///
  /// Retourne le fichier MP3 si déjà caché, sinon génère via Edge TTS.
  /// Retourne null si pas d'internet et pas de cache (→ fallback TTS natif).
  Future<String?> getAudioPath({
    required String scriptId,
    required String text,
    required String language,
  }) async {
    // 1. Vérifier le cache (la clé inclut un hash du texte: si le script
    //    change dans Supabase, l'audio est régénéré automatiquement)
    final cachePath = await _getCachePath(scriptId, language, text);
    final cacheFile = File(cachePath);
    if (await cacheFile.exists() && await cacheFile.length() > 0) {
      return cachePath;
    }

    // 2. Vérifier la connectivité
    final connectivity = await Connectivity().checkConnectivity();
    final hasInternet = !connectivity.contains(ConnectivityResult.none);
    if (!hasInternet) return null;

    // 3. Générer via Edge TTS
    try {
      final audioBytes = await _synthesize(text, language);
      if (audioBytes != null && audioBytes.isNotEmpty) {
        await cacheFile.parent.create(recursive: true);
        await cacheFile.writeAsBytes(audioBytes);
        return cachePath;
      }
    } catch (e) {
      // Fallback TTS natif, mais on trace la cause réelle (diagnostic
      // terrain via l'écran de debug — un échec silencieux est invisible).
      DebugLog().log('[EdgeTTS] génération échouée: $e');
    }

    return null;
  }

  /// Télécharger tous les audios d'une ville pour écoute offline.
  ///
  /// [scripts] — Liste de {id, content, language}
  /// [onProgress] — Callback (current, total)
  Future<void> downloadAll({
    required List<Map<String, dynamic>> scripts,
    required void Function(int current, int total) onProgress,
  }) async {
    for (var i = 0; i < scripts.length; i++) {
      final s = scripts[i];
      await getAudioPath(
        scriptId: s['id'] as String,
        text: s['content'] as String,
        language: s['language'] as String? ?? 'fr',
      );
      onProgress(i + 1, scripts.length);
    }
  }

  /// Vérifier si un script est déjà en cache.
  Future<bool> isCached(String scriptId, String language, String text) async {
    final path = await _getCachePath(scriptId, language, text);
    final file = File(path);
    return await file.exists() && await file.length() > 0;
  }

  /// Obtenir la taille totale du cache en bytes.
  Future<int> getCacheSize() async {
    final dir = await _getCacheDir();
    if (!await dir.exists()) return 0;
    int total = 0;
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File) {
        total += await entity.length();
      }
    }
    return total;
  }

  /// Vider le cache audio.
  Future<void> clearCache() async {
    final dir = await _getCacheDir();
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  /// Ouvrir la connexion WebSocket Edge TTS (jeton Sec-MS-GEC recalculé
  /// à chaque tentative — il dépend de l'horloge).
  Future<WebSocket> _connect(String requestId) {
    final url = '$_wsUrl'
        '&Sec-MS-GEC=${EdgeTtsDrm.secMsGec()}'
        '&Sec-MS-GEC-Version=$_secMsGecVersion'
        '&ConnectionId=$requestId';
    return WebSocket.connect(
      url,
      headers: {
        ..._baseHeaders,
        'Origin': 'chrome-extension://jdiccldimpdaibmpdkjnbmckianbfold',
        'Pragma': 'no-cache',
        'Cache-Control': 'no-cache',
        'Cookie': 'muid=${_generateRequestId().toUpperCase()};',
      },
    );
  }

  /// Synthétiser du texte en audio MP3 via Edge TTS WebSocket.
  Future<Uint8List?> _synthesize(String text, String language) async {
    final voice = _voices[language] ?? _voices['fr']!;
    final requestId = _generateRequestId();

    WebSocket ws;
    try {
      ws = await _connect(requestId);
    } on WebSocketException catch (e) {
      // Refus probable du jeton (horloge du téléphone décalée) —
      // on se recale sur l'heure du serveur et on retente une fois.
      DebugLog().log('[EdgeTTS] connexion refusée ($e), recalage horloge');
      await EdgeTtsDrm.syncClockSkew();
      ws = await _connect(requestId);
    }

    final audioChunks = <int>[];
    final completer = Completer<Uint8List?>();

    ws.listen(
      (data) {
        if (data is String) {
          if (data.contains('turn.end')) {
            if (!completer.isCompleted) {
              completer.complete(Uint8List.fromList(audioChunks));
            }
          }
        } else if (data is List<int>) {
          // Binary frame — extract audio after 2-byte header length
          final headerEnd = _findHeaderEnd(data);
          if (headerEnd >= 0 && headerEnd < data.length) {
            audioChunks.addAll(data.sublist(headerEnd));
          }
        }
      },
      onError: (e) {
        if (!completer.isCompleted) completer.complete(null);
      },
      onDone: () {
        if (!completer.isCompleted) completer.complete(null);
      },
    );

    // Send config
    ws.add(
      'Content-Type:application/json; charset=utf-8\r\n'
      'Path:speech.config\r\n\r\n'
      '{"context":{"synthesis":{"audio":{"metadataoptions":{'
      '"sentenceBoundaryEnabled":"false","wordBoundaryEnabled":"false"},'
      '"outputFormat":"audio-24khz-48kbitrate-mono-mp3"}}}}\r\n',
    );

    // Send SSML
    final ssml =
        '<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" '
        'xml:lang="$language">'
        '<voice name="$voice">'
        '<prosody pitch="+0Hz" rate="+0%">${_escapeXml(text)}</prosody>'
        '</voice></speak>';

    ws.add(
      'X-RequestId:$requestId\r\n'
      'Content-Type:application/ssml+xml\r\n'
      'Path:ssml\r\n\r\n'
      '$ssml',
    );

    // Attendre max 30 secondes
    final result = await completer.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () => null,
    );

    try {
      await ws.close();
    } catch (_) {}

    return result;
  }

  /// Trouver la fin du header dans un frame binaire Edge TTS.
  int _findHeaderEnd(List<int> data) {
    if (data.length < 2) return -1;
    final headerLen = (data[0] << 8) | data[1];
    return headerLen + 2;
  }

  /// Échapper le XML pour SSML.
  String _escapeXml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }

  /// Générer un request ID hex aléatoire.
  String _generateRequestId() {
    final random = Random();
    return List.generate(32, (_) => random.nextInt(16).toRadixString(16))
        .join();
  }

  /// Chemin du cache pour un script.
  ///
  /// La clé inclut un hash du contenu: si le texte du script est corrigé
  /// dans Supabase, l'ancien MP3 devient orphelin et un nouveau est généré.
  Future<String> _getCachePath(
    String scriptId,
    String language,
    String text,
  ) async {
    final dir = await _getCacheDir();
    final contentHash = md5.convert(utf8.encode(text)).toString();
    final hash = md5
        .convert(utf8.encode('$scriptId-$language-$contentHash'))
        .toString();
    return '${dir.path}/$hash.mp3';
  }

  /// Dossier de cache audio.
  Future<Directory> _getCacheDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    return Directory('${appDir.path}/audio_cache');
  }
}
