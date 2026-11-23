import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/constants.dart';
import '../l10n/l10n.dart';

/// Vérifie au démarrage si une version plus récente de l'APK est publiée
/// (dernière release GitHub) et propose de la télécharger.
///
/// Android seulement : sur iPhone, les mises à jour passent par
/// TestFlight / l'App Store. Toute erreur (hors ligne, GitHub
/// indisponible…) est ignorée silencieusement.
class UpdateService {
  static const _latestReleaseApi =
      'https://api.github.com/repos/admin-rayv/app-voyage/releases/latest';

  /// « Plus tard » : ne pas redemander la même version avant ce délai.
  static const _snoozeKey = 'update_snooze';
  static const _snoozeDuration = Duration(hours: 24);

  static bool _checkedThisSession = false;

  /// true si [latest] (ex. « v0.7.6 ») est plus récente que [current]
  /// (ex. « 0.7.5 »). Les suffixes (« -beta », « +9 ») sont ignorés.
  static bool isNewer(String current, String latest) {
    List<int> parse(String v) {
      final core = v.trim().replaceFirst(RegExp(r'^[vV]'), '').split(
            RegExp(r'[-+]'),
          )[0];
      return core.split('.').map((p) => int.tryParse(p) ?? 0).toList();
    }

    final a = parse(current);
    final b = parse(latest);
    for (var i = 0; i < 3; i++) {
      final x = i < a.length ? a[i] : 0;
      final y = i < b.length ? b[i] : 0;
      if (y != x) return y > x;
    }
    return false;
  }

  static Future<void> checkAndPrompt(BuildContext context) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    if (_checkedThisSession) return;
    _checkedThisSession = true;

    try {
      final res = await http.get(
        Uri.parse(_latestReleaseApi),
        headers: {'Accept': 'application/vnd.github+json'},
      ).timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return;

      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final tag = json['tag_name']?.toString() ?? '';
      if (!isNewer(AppConstants.appVersion, tag)) return;

      final assets = (json['assets'] as List?) ?? const [];
      final apk = assets.cast<Map<String, dynamic>>().where(
            (a) => a['name']?.toString().endsWith('.apk') ?? false,
          );
      if (apk.isEmpty) return;
      final url = apk.first['browser_download_url']?.toString();
      if (url == null) return;

      final prefs = await SharedPreferences.getInstance();
      final snooze = prefs.getString(_snoozeKey);
      if (snooze != null) {
        final parts = snooze.split('|');
        final until = DateTime.tryParse(parts.length == 2 ? parts[1] : '');
        if (parts[0] == tag && until != null && DateTime.now().isBefore(until)) {
          return;
        }
      }

      if (!context.mounted) return;
      final version = tag.replaceFirst(RegExp(r'^[vV]'), '');
      final accept = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(ctx.l10n.updateTitle),
          content: Text(
            ctx.l10n.updateBody(version, AppConstants.appVersion),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(ctx.l10n.updateLater),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(ctx.l10n.updateNow),
            ),
          ],
        ),
      );

      if (accept == true) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        await prefs.setString(
          _snoozeKey,
          '$tag|${DateTime.now().add(_snoozeDuration).toIso8601String()}',
        );
      }
    } catch (e) {
      debugPrint('UpdateService: vérification ignorée ($e)');
    }
  }
}
