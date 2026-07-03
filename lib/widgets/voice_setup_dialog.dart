import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/l10n.dart';

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
        title: Row(
          children: [
            const Text('🎙️', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(ctx.l10n.vsdTitle,
                  style: const TextStyle(fontSize: 18)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ctx.l10n.vsdIntro,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 16),
            Text(
              ctx.l10n.vsdStepsTitle,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              ctx.l10n.vsdSteps,
              style: const TextStyle(fontSize: 13, height: 1.6),
            ),
            const SizedBox(height: 12),
            Text(
              ctx.l10n.vsdFree,
              style: const TextStyle(
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
            child: Text(ctx.l10n.vsdLater),
          ),
          ElevatedButton.icon(
            onPressed: () {
              _openTtsSettings();
              prefs.setBool(_prefKey, true);
              Navigator.pop(ctx);
            },
            icon: const Icon(Icons.settings, size: 18),
            label: Text(ctx.l10n.vsdInstall),
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
