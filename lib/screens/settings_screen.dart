import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/audio_service.dart' as audio_svc;
import '../services/tts_service.dart';
import '../services/debug_log.dart';
import '../services/user_preferences_service.dart';
import '../services/visited_poi_service.dart';
import '../config/constants.dart';
import '../l10n/l10n.dart';
import '../config/theme.dart';

/// Écran Paramètres — Configuration des voix TTS par langue.
///
/// Accessible depuis le home screen. Les choix s'appliquent
/// automatiquement partout dans l'app.

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TtsService _tts = TtsService();
  final audio_svc.AudioService _audio = audio_svc.AudioService();
  final VisitedPoiService _visitedPoiService = VisitedPoiService();
  StreamSubscription<TtsState>? _ttsStateSubscription;
  bool _isLoading = true;
  bool _isResettingVisited = false;
  String _preferredLanguage = UserPreferencesService.defaultPreferredLanguage;
  bool _discoveryAutoplayEnabled =
      UserPreferencesService.defaultDiscoveryAutoplayEnabled;
  int _discoveryAutoplayDelaySec =
      UserPreferencesService.defaultDiscoveryAutoplayDelaySec;
  bool _discoveryAutoplayVibrationEnabled =
      UserPreferencesService.defaultDiscoveryAutoplayVibrationEnabled;
  bool _discoveryReplayVisitedEnabled =
      UserPreferencesService.defaultDiscoveryReplayVisitedEnabled;

  // Vitesse de lecture
  double _selectedSpeed = 1.0;
  static const Map<String, double> _speedOptions = {
    '0.75x': 0.75,
    '1x': 1.0,
    '1.25x': 1.25,
    '1.5x': 1.5,
  };

  // Voix par langue
  final Map<String, List<VoiceInfo>> _voicesByLang = {};
  final Map<String, String?> _selectedByLang = {};
  String? _testingVoice;

  static const _languages = [
    {
      'code': 'fr',
      'label': 'Français',
      'flag': '',
      'testText': 'Bienvenue à Saint-Lambert! Je suis Marco, ton guide.',
    },
    {
      'code': 'en',
      'label': 'English',
      'flag': '',
      'testText': 'Welcome to Saint-Lambert! I\'m Marco, your guide.',
    },
    {
      'code': 'es',
      'label': 'Español',
      'flag': '',
      'testText': '¡Bienvenido a Saint-Lambert! Soy Marco, tu guía.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tts.init();
    // Un seul abonnement pour suivre la fin des tests de voix
    // (avant: un listener était ajouté — et jamais annulé — à chaque test).
    _ttsStateSubscription = _tts.stateStream.listen((state) {
      if (state == TtsState.stopped && mounted && _testingVoice != null) {
        setState(() => _testingVoice = null);
      }
    });
    _audio.init().then((_) {
      if (mounted) setState(() => _selectedSpeed = _audio.speed);
    });
    _loadAllVoices();
  }

  Future<void> _loadAllVoices() async {
    _preferredLanguage = await UserPreferencesService.getPreferredLanguage();
    await _visitedPoiService.init();
    _discoveryAutoplayEnabled =
        await UserPreferencesService.isDiscoveryAutoplayEnabled();
    _discoveryAutoplayDelaySec =
        await UserPreferencesService.getDiscoveryAutoplayDelaySec();
    _discoveryAutoplayVibrationEnabled =
        await UserPreferencesService.isDiscoveryAutoplayVibrationEnabled();
    _discoveryReplayVisitedEnabled =
        await UserPreferencesService.isDiscoveryReplayVisitedEnabled();

    for (final lang in _languages) {
      final code = lang['code'] as String;
      final voices = await _tts.getLocalVoices(code);
      final userVoice = await _tts.getUserVoice(code);
      _voicesByLang[code] = voices;
      _selectedByLang[code] = userVoice;
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _testVoice(VoiceInfo voice, String testText) async {
    setState(() => _testingVoice = voice.name);
    await _tts.stop();
    // Écoute temporaire seulement — la voix choisie n'est PAS modifiée.
    // (Avant: le test appelait setUserVoice et persistait la voix testée.)
    await _tts.previewVoice(voice, testText);
  }

  Future<void> _selectVoice(String langCode, String voiceName) async {
    await _tts.stop();
    await _tts.setUserVoice(langCode, voiceName);
    setState(() => _selectedByLang[langCode] = voiceName);
  }

  Future<void> _selectPreferredLanguage(String language) async {
    await UserPreferencesService.setPreferredLanguage(language);
    if (!mounted) return;
    setState(() => _preferredLanguage = language);
  }

  Future<void> _setDiscoveryAutoplayEnabled(bool enabled) async {
    await UserPreferencesService.setDiscoveryAutoplayEnabled(enabled);
    if (!mounted) return;
    setState(() => _discoveryAutoplayEnabled = enabled);
  }

  Future<void> _setDiscoveryAutoplayDelay(int delaySec) async {
    await UserPreferencesService.setDiscoveryAutoplayDelaySec(delaySec);
    if (!mounted) return;
    setState(() => _discoveryAutoplayDelaySec = delaySec);
  }

  Future<void> _setDiscoveryAutoplayVibrationEnabled(bool enabled) async {
    await UserPreferencesService.setDiscoveryAutoplayVibrationEnabled(enabled);
    if (!mounted) return;
    setState(() => _discoveryAutoplayVibrationEnabled = enabled);
  }

  Future<void> _setDiscoveryReplayVisitedEnabled(bool enabled) async {
    await UserPreferencesService.setDiscoveryReplayVisitedEnabled(enabled);
    if (!mounted) return;
    setState(() => _discoveryReplayVisitedEnabled = enabled);
  }

  /// Ouvrir les paramètres d'optimisation de batterie (Android) pour que
  /// l'utilisateur exclue l'app — sinon certains fabricants (Samsung,
  /// Xiaomi…) tuent le GPS en arrière-plan après quelques minutes.
  Future<void> _openBatterySettings() async {
    try {
      await AppSettings.openAppSettings(
        type: AppSettingsType.batteryOptimization,
      );
    } catch (error) {
      DebugLog().log('[Settings] batterie: $error');
      // Écran spécifique indisponible sur ce fabricant → réglages de l'app.
      try {
        await AppSettings.openAppSettings();
      } catch (_) {}
    }
  }

  Future<void> _confirmResetVisited() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.resetConfirmTitle),
        content: Text(context.l10n.resetConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.reset),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() => _isResettingVisited = true);
    await _visitedPoiService.resetVisited();
    if (!mounted) {
      return;
    }

    setState(() => _isResettingVisited = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.resetDone)),
    );
  }

  @override
  void dispose() {
    _ttsStateSubscription?.cancel();
    _tts.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.settingsTitle),
        actions: [
          IconButton(
            icon: const Text('🐛', style: TextStyle(fontSize: 20)),
            tooltip: context.l10n.debugLogsTooltip,
            onPressed: () => showDebugLogs(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Icon(Icons.language, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      context.l10n.readingLanguage,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.readingLanguageDesc,
                  style: TextStyle(color: AppTheme.textSecondaryOf(context), fontSize: 13),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _languages.map((lang) {
                    final code = lang['code'] as String;
                    final label = lang['label'] as String;
                    return ChoiceChip(
                      label: Text(label),
                      selected: _preferredLanguage == code,
                      onSelected: (_) => _selectPreferredLanguage(code),
                      selectedColor: AppTheme.primaryColor.withValues(
                        alpha: 0.2,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Icon(Icons.explore, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      context.l10n.discoveryModeSection,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.discoveryModeDesc,
                  style: TextStyle(color: AppTheme.textSecondaryOf(context), fontSize: 13),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(context.l10n.autoplayTitle),
                  subtitle: Text(context.l10n.autoplayDesc),
                  value: _discoveryAutoplayEnabled,
                  onChanged: _setDiscoveryAutoplayEnabled,
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.delayBeforePlay,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: UserPreferencesService.discoveryAutoplayDelayOptions
                      .map((delaySec) {
                        return ChoiceChip(
                          label: Text(context.l10n.delaySeconds(delaySec)),
                          selected: _discoveryAutoplayDelaySec == delaySec,
                          onSelected: (_) =>
                              _setDiscoveryAutoplayDelay(delaySec),
                          selectedColor: AppTheme.primaryColor.withValues(
                            alpha: 0.2,
                          ),
                        );
                      })
                      .toList(),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(context.l10n.vibrationTitle),
                  subtitle: Text(context.l10n.vibrationDesc),
                  value: _discoveryAutoplayVibrationEnabled,
                  onChanged: _setDiscoveryAutoplayVibrationEnabled,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(context.l10n.replayVisitedTitle),
                  subtitle: Text(context.l10n.replayVisitedDesc),
                  value: _discoveryReplayVisitedEnabled,
                  onChanged: _setDiscoveryReplayVisitedEnabled,
                ),
                // Android tue les apps en arrière-plan (optimisation de
                // batterie) — le tueur silencieux du mode découverte.
                if (!kIsWeb &&
                    defaultTargetPlatform == TargetPlatform.android) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.amber.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('🔋', style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                context.l10n.batteryTitle,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          context.l10n.batteryBody,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            color: AppTheme.textSecondaryOf(context),
                          ),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: _openBatterySettings,
                          icon: const Icon(Icons.settings_suggest, size: 18),
                          label: Text(context.l10n.batteryOpenSettings),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                Row(
                  children: [
                    Icon(Icons.checklist, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      context.l10n.progressSection,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.progressSectionDesc,
                  style: TextStyle(color: AppTheme.textSecondaryOf(context), fontSize: 13),
                ),
                const SizedBox(height: 12),
                AnimatedBuilder(
                  animation: _visitedPoiService.listenable,
                  builder: (context, _) {
                    final totalVisited = _visitedPoiService
                        .listenable
                        .value
                        .values
                        .fold<int>(0, (sum, ids) => sum + ids.length);
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.check_circle_outline,
                        color: Colors.grey.shade700,
                      ),
                      title: Text(context.l10n.visitedSaved(totalVisited)),
                      subtitle: Text(context.l10n.resetHint),
                      trailing: TextButton.icon(
                        onPressed: _isResettingVisited || totalVisited == 0
                            ? null
                            : _confirmResetVisited,
                        icon: _isResettingVisited
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.primaryColor,
                                ),
                              )
                            : const Icon(Icons.refresh),
                        label: Text(context.l10n.reset),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                // Section vitesse de lecture
                Row(
                  children: [
                    Icon(Icons.speed, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      context.l10n.speedSection,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.speedSectionDesc,
                  style: TextStyle(color: AppTheme.textSecondaryOf(context), fontSize: 13),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _speedOptions.entries.map((entry) {
                    final isSelected = _selectedSpeed == entry.value;
                    return ChoiceChip(
                      label: Text(entry.key),
                      selected: isSelected,
                      onSelected: (_) async {
                        await _audio.setSpeed(entry.value);
                        if (mounted) {
                          setState(() => _selectedSpeed = entry.value);
                        }
                      },
                      selectedColor: AppTheme.primaryColor.withValues(
                        alpha: 0.2,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),

                // Header voix
                Row(
                  children: [
                    Icon(Icons.record_voice_over, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      context.l10n.voiceSection,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.voiceSectionDesc,
                  style: TextStyle(color: AppTheme.textSecondaryOf(context), fontSize: 13),
                ),
                const SizedBox(height: 24),

                // Section par langue
                ..._languages.map(
                  (lang) => _buildLanguageSection(
                    langCode: lang['code'] as String,
                    label: lang['label'] as String,
                    flag: lang['flag'] as String,
                    testText: lang['testText'] as String,
                  ),
                ),

                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.info_outline, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      context.l10n.aboutSection,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.aboutVersion(AppConstants.appVersion),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.aboutDesc,
                  style: TextStyle(
                    color: AppTheme.textSecondaryOf(context),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
    );
  }

  Widget _buildLanguageSection({
    required String langCode,
    required String label,
    required String flag,
    required String testText,
  }) {
    final voices = _voicesByLang[langCode] ?? [];
    final selected = _selectedByLang[langCode];

    // Séparer local et network
    final localVoices = voices.where((v) => v.isLocal).toList();
    final networkVoices = voices.where((v) => !v.isLocal).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header langue
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.translate, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                context.l10n.localVoicesCount(localVoices.length),
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondaryOf(context)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Voix locales
        if (localVoices.isNotEmpty) ...[
          ...localVoices.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final voice = entry.value;
            final isSelected = selected == voice.name;
            final isTesting = _testingVoice == voice.name;

            return _buildVoiceTile(
              title: context.l10n.voiceN(index),
              subtitle: context.l10n.voiceLocalLabel,
              voice: voice,
              testText: testText,
              langCode: langCode,
              isSelected: isSelected,
              isTesting: isTesting,
            );
          }),
        ],

        // Voix réseau (collapsible)
        if (networkVoices.isNotEmpty) ...[
          const SizedBox(height: 4),
          ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 8),
            title: Text(
              context.l10n.networkVoicesHeader(networkVoices.length),
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondaryOf(context)),
            ),
            children: networkVoices.asMap().entries.map((entry) {
              final index = entry.key + 1;
              final voice = entry.value;
              final isSelected = selected == voice.name;
              final isTesting = _testingVoice == voice.name;

              return _buildVoiceTile(
                title: context.l10n.voiceNetworkN(index),
                subtitle: context.l10n.voiceNetworkDesc,
                voice: voice,
                testText: testText,
                langCode: langCode,
                isSelected: isSelected,
                isTesting: isTesting,
              );
            }).toList(),
          ),
        ],

        if (voices.isEmpty)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              context.l10n.noVoicesInstalled,
              style: TextStyle(color: AppTheme.textSecondaryOf(context), fontSize: 13),
            ),
          ),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildVoiceTile({
    required String title,
    required String subtitle,
    required VoiceInfo voice,
    required String testText,
    required String langCode,
    required bool isSelected,
    required bool isTesting,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
      color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.08) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: isSelected
            ? BorderSide(color: AppTheme.primaryColor, width: 1.5)
            : BorderSide.none,
      ),
      child: ListTile(
        dense: true,
        leading: isSelected
            ? Icon(Icons.check_circle, color: AppTheme.primaryColor)
            : Icon(Icons.radio_button_unchecked, color: Colors.grey[400]),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
        trailing: IconButton(
          icon: isTesting
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.primaryColor,
                  ),
                )
              : Icon(
                  Icons.play_circle_fill,
                  color: AppTheme.primaryColor,
                  size: 28,
                ),
          onPressed: isTesting ? null : () => _testVoice(voice, testText),
        ),
        onTap: () => _selectVoice(langCode, voice.name),
      ),
    );
  }

  static void showDebugLogs(BuildContext context) {
    final logs = DebugLog().entries;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.3,
        maxChildSize: 0.95,
        expand: false,
        builder: (ctx, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Text(
                    '🐛 Logs de debug',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const Spacer(),
                  // Export pour analyse post-balade (les logs sont perdus
                  // quand l'app est tuée).
                  TextButton.icon(
                    onPressed: () async {
                      final buffer = StringBuffer()
                        ..writeln('=== App Voyage — logs de debug ===')
                        ..writeln(DebugLog().entries.join('\n'))
                        ..writeln()
                        ..writeln('=== Décisions géofencing ===')
                        ..writeln(
                          'timestamp|lat|lng|accuracy|poi|distance|confidence|approaching|decision|reason',
                        )
                        ..writeln(DebugLog().geoDecisions.join('\n'));
                      await Clipboard.setData(
                        ClipboardData(text: buffer.toString()),
                      );
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(
                            content: Text(ctx.l10n.logsCopied),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.copy, size: 16),
                    label: Text(ctx.l10n.copyAction),
                  ),
                  TextButton(
                    onPressed: () {
                      DebugLog().clear();
                      Navigator.pop(ctx);
                    },
                    child: Text(ctx.l10n.clearAction),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: logs.isEmpty
                  ? Center(child: Text(ctx.l10n.noLogs))
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: logs.length,
                      itemBuilder: (ctx, i) => Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 2,
                        ),
                        child: Text(
                          logs[logs.length - 1 - i],
                          style: const TextStyle(
                            fontSize: 11,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
