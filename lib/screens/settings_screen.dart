import 'package:flutter/material.dart';
import '../services/tts_service.dart';
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
  bool _isLoading = true;

  // Voix par langue
  final Map<String, List<VoiceInfo>> _voicesByLang = {};
  final Map<String, String?> _selectedByLang = {};
  String? _testingVoice;

  static const _languages = [
    {'code': 'fr', 'label': 'Français', 'flag': '', 'testText': 'Bienvenue à Saint-Lambert! Je suis Marco, ton guide.'},
    {'code': 'en', 'label': 'English', 'flag': '', 'testText': 'Welcome to Saint-Lambert! I\'m Marco, your guide.'},
    {'code': 'es', 'label': 'Español', 'flag': '', 'testText': '¡Bienvenido a Saint-Lambert! Soy Marco, tu guía.'},
  ];

  @override
  void initState() {
    super.initState();
    _tts.init();
    _loadAllVoices();
  }

  Future<void> _loadAllVoices() async {
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
    // Appliquer temporairement cette voix
    final locale = voice.locale;
    await _tts.setLanguage(locale.substring(0, 2));
    // Force cette voix spécifique
    await _tts.setUserVoice(
      locale.startsWith('fr') ? 'fr' : locale.startsWith('en') ? 'en' : 'es',
      voice.name,
    );
    await _tts.speak(testText);

    // Attendre la fin
    _tts.stateStream.listen((state) {
      if (state == TtsState.stopped && mounted) {
        setState(() => _testingVoice = null);
      }
    });
  }

  Future<void> _selectVoice(String langCode, String voiceName) async {
    await _tts.stop();
    await _tts.setUserVoice(langCode, voiceName);
    setState(() => _selectedByLang[langCode] = voiceName);
  }

  @override
  void dispose() {
    _tts.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Header
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
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 24),

                // Section par langue
                ..._languages.map((lang) => _buildLanguageSection(
                  langCode: lang['code'] as String,
                  label: lang['label'] as String,
                  flag: lang['flag'] as String,
                  testText: lang['testText'] as String,
                )),
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
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
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
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
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
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
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
      color: isSelected
          ? AppTheme.primaryColor.withValues(alpha: 0.08)
          : null,
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
              : Icon(Icons.play_circle_fill,
                  color: AppTheme.primaryColor, size: 28),
          onPressed: isTesting ? null : () => _testVoice(voice, testText),
        ),
        onTap: () => _selectVoice(langCode, voice.name),
      ),
    );
  }
}
