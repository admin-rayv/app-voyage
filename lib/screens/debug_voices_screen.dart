import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Écran debug — Liste toutes les voix TTS disponibles sur l'appareil.
/// Temporaire — à retirer avant release.

class DebugVoicesScreen extends StatefulWidget {
  const DebugVoicesScreen({super.key});

  @override
  State<DebugVoicesScreen> createState() => _DebugVoicesScreenState();
}

class _DebugVoicesScreenState extends State<DebugVoicesScreen> {
  final FlutterTts _tts = FlutterTts();
  List<Map<String, String>> _allVoices = [];
  bool _isLoading = true;
  String _filter = '';

  @override
  void initState() {
    super.initState();
    _loadVoices();
  }

  Future<void> _loadVoices() async {
    final voices = await _tts.getVoices;
    if (voices != null) {
      setState(() {
        _allVoices = (voices as List).map<Map<String, String>>((v) {
          return {
            'name': v['name']?.toString() ?? '',
            'locale': v['locale']?.toString() ?? '',
          };
        }).toList();
        _allVoices.sort((a, b) => a['locale']!.compareTo(b['locale']!));
        _isLoading = false;
      });
    }
  }

  Future<void> _testVoice(Map<String, String> voice) async {
    await _tts.setVoice(voice);
    await _tts.setSpeechRate(0.52);
    await _tts.setPitch(1.05);
    
    final locale = voice['locale'] ?? '';
    String text;
    if (locale.startsWith('fr')) {
      text = "Bienvenue à Saint-Lambert! Je suis Marco, ton guide.";
    } else if (locale.startsWith('es')) {
      text = "¡Bienvenido a Saint-Lambert! Soy Marco, tu guía.";
    } else {
      text = "Welcome to Saint-Lambert! I'm Marco, your guide.";
    }
    
    await _tts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filter.isEmpty
        ? _allVoices
        : _allVoices.where((v) =>
            v['name']!.toLowerCase().contains(_filter.toLowerCase()) ||
            v['locale']!.toLowerCase().contains(_filter.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Debug: Voix TTS')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Filtrer (fr, en, es, male...)',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _filter = v),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text('${filtered.length} voix trouvées',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, i) {
                  final v = filtered[i];
                  return ListTile(
                    title: Text(v['name'] ?? '', style: const TextStyle(fontSize: 13)),
                    subtitle: Text(v['locale'] ?? ''),
                    trailing: IconButton(
                      icon: const Icon(Icons.play_arrow),
                      onPressed: () => _testVoice(v),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }
}
