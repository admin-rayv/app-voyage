import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Dialog de configuration des voix TTS.
///
/// Affiché au premier lancement si les voix FR-CA de qualité ne sont pas détectées.
/// Guide l'utilisateur vers les paramètres TTS du système.

class VoiceSetupDialog {
  static const String _prefKey = 'voice_setup_done';
  static const _channel = MethodChannel('com.rayv.appvoyage/tts_settings');

  /// Vérifier et afficher le dialog si nécessaire.
  static Future<void> checkAndShow(BuildContext context) async {
    // Les instructions (moteur Google, données vocales) ne concernent
    // qu'Android — ne pas afficher sur iOS/web.
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;

    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_prefKey) == true) return;

    // Vérifier les voix disponibles
    final tts = FlutterTts();
    final voices = await tts.getVoices;
    if (voices == null) return;

    final voiceList = voices as List;
    final hasFrCA = voiceList.any((v) {
      final locale = v['locale']?.toString() ?? '';
      return locale.contains('fr-CA') || locale.contains('fr_CA');
    });

    if (!hasFrCA && context.mounted) {
      await _showDialog(context, prefs);
    } else {
      await prefs.setBool(_prefKey, true);
    }
  }

  static Future<void> _showDialog(
      BuildContext context, SharedPreferences prefs) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Text('🎙️', style: TextStyle(fontSize: 28)),
            SizedBox(width: 8),
            Expanded(
              child: Text('Voix de Marco', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pour que Marco te guide avec une belle voix, '
              'installe les voix de qualité sur ton téléphone.',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            SizedBox(height: 16),
            Text(
              '📋 Étapes rapides :',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            SizedBox(height: 8),
            Text(
              '1. Clique "Installer les voix"\n'
              '2. Sélectionne le moteur Google\n'
              '3. Appuie sur ⚙️ → "Installer les données vocales"\n'
              '4. Télécharge :\n'
              '   🇨🇦 Français (Canada)\n'
              '   🇺🇸 English (US)\n'
              '   🇪🇸 Español\n'
              '5. Reviens dans l\'app',
              style: TextStyle(fontSize: 13, height: 1.6),
            ),
            SizedBox(height: 12),
            Text(
              '⏱️ Ça prend 30 secondes et c\'est gratuit !',
              style: TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              prefs.setBool(_prefKey, true);
              Navigator.pop(ctx);
            },
            child: const Text('Plus tard'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              _openTtsSettings();
              prefs.setBool(_prefKey, true);
              Navigator.pop(ctx);
            },
            icon: const Icon(Icons.settings, size: 18),
            label: const Text('Installer les voix'),
          ),
        ],
      ),
    );
  }

  /// Ouvrir les paramètres TTS Android.
  static Future<void> _openTtsSettings() async {
    try {
      await _channel.invokeMethod('openTtsSettings');
    } catch (_) {
      // Fallback: si le channel natif n'est pas dispo,
      // on ne fait rien — l'utilisateur peut aller manuellement
    }
  }
}
