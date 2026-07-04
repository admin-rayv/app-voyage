/// Stub web d'EdgeTtsService — l'API non officielle Edge TTS nécessite
/// dart:io (WebSocket natif + fichiers). Sur le web, getAudioPath retourne
/// toujours null → AudioService retombe sur le TTS natif du navigateur.
class EdgeTtsService {
  Future<String?> getAudioPath({
    required String scriptId,
    required String text,
    required String language,
  }) async {
    return null;
  }

  Future<void> downloadAll({
    required List<Map<String, dynamic>> scripts,
    required void Function(int current, int total) onProgress,
    bool Function()? isCancelled,
  }) async {
    onProgress(scripts.length, scripts.length);
  }

  Future<bool> isCached(String scriptId, String language, String text) async {
    return false;
  }

  Future<int> getCacheSize() async {
    return 0;
  }

  Future<void> clearCache() async {}
}
