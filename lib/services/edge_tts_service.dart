import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service Edge TTS — Génère de l'audio via Microsoft Edge TTS + cache local.
///
/// Priorité: cache local → Edge TTS (si internet) → null (fallback au TTS natif)
/// Les MP3 sont cachés dans le dossier app pour réutilisation offline.

class EdgeTtsService {
  // Voix par langue — voix masculines pour Marco
  static const Map<String, String> _voices = {
    'fr': 'fr-CA-ThierryNeural',
    'en': 'en-US-GuyNeural',
    'es': 'es-MX-JorgeNeural',
  };

  // Edge TTS WebSocket config
  static const String _trustedClientToken = '6A5AA1D4EAFF4E9FB37E23D68491D6F4';
  static const String _wsUrl =
      'wss://speech.platform.bing.com/consumer/speech/synthesize/readaloud/edge/v1?TrustedClientToken=$_trustedClientToken';

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
      // Silencieux — on retourne null pour fallback
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

  /// Synthétiser du texte en audio MP3 via Edge TTS WebSocket.
  Future<Uint8List?> _synthesize(String text, String language) async {
    final voice = _voices[language] ?? _voices['fr']!;
    final requestId = _generateRequestId();

    final ws = await WebSocket.connect(
      '$_wsUrl&ConnectionId=$requestId',
      headers: {
        'Origin': 'chrome-extension://jdiccldimpdaibmpdmdez',
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
      },
    );

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
