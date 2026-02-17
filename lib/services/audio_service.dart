import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import '../config/constants.dart';

/// Service Audio
/// Gestion de la lecture et du cache audio

class AudioService {
  final AudioPlayer _player = AudioPlayer();
  final Dio _dio = Dio();
  
  AudioPlayer get player => _player;
  
  /// Générer et jouer l'audio pour un script
  Future<void> playScript(String scriptId) async {
    // Vérifier le cache local d'abord
    final cacheFile = await _getCacheFile(scriptId);
    
    if (await cacheFile.exists()) {
      // Jouer depuis le cache
      await _player.setFilePath(cacheFile.path);
    } else {
      // Générer via Edge Function et mettre en cache
      await _generateAndCache(scriptId, cacheFile);
      await _player.setFilePath(cacheFile.path);
    }
    
    await _player.play();
  }
  
  /// Pause
  Future<void> pause() async {
    await _player.pause();
  }
  
  /// Stop
  Future<void> stop() async {
    await _player.stop();
  }
  
  /// Seek
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }
  
  /// Obtenir le fichier cache pour un script
  Future<File> _getCacheFile(String scriptId) async {
    final dir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${dir.path}/${AppConstants.audioCacheDir}');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return File('${cacheDir.path}/$scriptId.mp3');
  }
  
  /// Générer l'audio et le mettre en cache
  Future<void> _generateAndCache(String scriptId, File cacheFile) async {
    final response = await _dio.post(
      '${AppConstants.supabaseUrl}/functions/v1/${AppConstants.generateAudioFunction}',
      data: {'script_id': scriptId},
      options: Options(
        responseType: ResponseType.bytes,
        headers: {
          'Authorization': 'Bearer ${AppConstants.supabaseAnonKey}',
          'Content-Type': 'application/json',
        },
      ),
    );
    
    await cacheFile.writeAsBytes(response.data);
  }
  
  /// Nettoyer le cache
  Future<void> clearCache() async {
    final dir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${dir.path}/${AppConstants.audioCacheDir}');
    if (await cacheDir.exists()) {
      await cacheDir.delete(recursive: true);
    }
  }
  
  /// Dispose
  void dispose() {
    _player.dispose();
  }
}
