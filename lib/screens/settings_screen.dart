import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/audio_service.dart' as audio_svc;
import '../services/tts_service.dart';
import '../services/debug_log.dart';
import '../services/user_preferences_service.dart';
import '../services/visited_poi_service.dart';
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

  Future<void> _confirmResetVisited() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Réinitialiser la progression ?'),
        content: const Text(
          'Tous les POIs marqués comme écoutés seront supprimés de cet appareil.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset'),
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
      const SnackBar(content: Text('Progression des POIs réinitialisée.')),
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
        title: const Text('Paramètres'),
        actions: [
          IconButton(
            icon: const Text('🐛', style: TextStyle(fontSize: 20)),
            tooltip: 'Logs de debug',
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
                      'Langue de lecture',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Langue utilisée par défaut pour les scripts audio et le mode découverte.',
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
                      'Mode découverte',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Configure la lecture automatique quand un POI est détecté à proximité.',
                  style: TextStyle(color: AppTheme.textSecondaryOf(context), fontSize: 13),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Lecture automatique des POIs'),
                  subtitle: const Text(
                    'Démarre automatiquement un script quand le mode découverte déclenche un POI.',
                  ),
                  value: _discoveryAutoplayEnabled,
                  onChanged: _setDiscoveryAutoplayEnabled,
                ),
                const SizedBox(height: 8),
                Text(
                  'Délai avant lecture',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: UserPreferencesService.discoveryAutoplayDelayOptions
                      .map((delaySec) {
                        return ChoiceChip(
                          label: Text('${delaySec}s'),
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
                  title: const Text('Vibration avant lecture'),
                  subtitle: const Text(
                    'Ajoute un retour haptique avant le lancement automatique du script.',
                  ),
                  value: _discoveryAutoplayVibrationEnabled,
                  onChanged: _setDiscoveryAutoplayVibrationEnabled,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Rejouer les POIs déjà écoutés'),
                  subtitle: const Text(
                    'Si activé, le mode découverte redéclenche aussi les POIs '
                    'déjà marqués comme écoutés (utile pour les tests terrain).',
                  ),
                  value: _discoveryReplayVisitedEnabled,
                  onChanged: _setDiscoveryReplayVisitedEnabled,
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Icon(Icons.checklist, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'Progression des POIs',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Réinitialise les POIs marqués comme déjà écoutés sur cet appareil.',
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
                      title: Text('$totalVisited POIs écoutés enregistrés'),
                      subtitle: const Text(
                        'Le reset efface la progression locale de toutes les villes.',
                      ),
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
                        label: const Text('Reset'),
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
                      'Vitesse de lecture',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'La vitesse s\'applique à toutes les lectures.',
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
                      'Voix de Marco',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Choisis la voix pour chaque langue. Appuie sur ▶️ pour tester.',
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
                '${localVoices.length} locale${localVoices.length > 1 ? 's' : ''}',
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
              title: 'Voix $index',
              subtitle: voice.isLocal ? '📱 Locale (offline)' : '☁️ Réseau',
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
              '☁️ Voix réseau (${networkVoices.length}) — nécessite internet',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondaryOf(context)),
            ),
            children: networkVoices.asMap().entries.map((entry) {
              final index = entry.key + 1;
              final voice = entry.value;
              final isSelected = selected == voice.name;
              final isTesting = _testingVoice == voice.name;

              return _buildVoiceTile(
                title: 'Voix réseau $index',
                subtitle: '☁️ Meilleure qualité, besoin de wifi/data',
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
              'Aucune voix installée pour cette langue.\nVa dans Paramètres → TTS pour en télécharger.',
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
                          const SnackBar(
                            content: Text('Logs copiés dans le presse-papier.'),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Copier'),
                  ),
                  TextButton(
                    onPressed: () {
                      DebugLog().clear();
                      Navigator.pop(ctx);
                    },
                    child: const Text('Effacer'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: logs.isEmpty
                  ? const Center(child: Text('Aucun log'))
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
