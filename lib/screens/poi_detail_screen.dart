import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/point.dart' as models;
import '../models/script.dart';
import '../services/supabase_service.dart';
import '../services/audio_service.dart';
import '../services/tts_service.dart';
import '../config/categories.dart';
import '../config/theme.dart';

/// Écran détail POI — Infos complètes + lecture audio TTS.

class PoiDetailScreen extends StatefulWidget {
  final models.Point poi;
  final LatLng? userPosition;

  const PoiDetailScreen({
    super.key,
    required this.poi,
    this.userPosition,
  });

  @override
  State<PoiDetailScreen> createState() => _PoiDetailScreenState();
}

class _PoiDetailScreenState extends State<PoiDetailScreen> {
  final AudioService _audio = AudioService();
  Script? _currentScript;
  String _selectedLanguage = 'fr';
  bool _isLoadingScript = true;
  bool _isSpeaking = false;
  List<VoiceInfo> _availableVoices = [];
  String? _selectedVoiceName;

  @override
  void initState() {
    super.initState();
    _audio.init();
    _audio.stateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isSpeaking = state == TtsState.playing;
        });
      }
    });
    _loadScript();
    _loadVoices();
  }

  Future<void> _loadVoices() async {
    final voices = await _audio.tts.getLocalVoices(_selectedLanguage);
    final userVoice = await _audio.tts.getUserVoice(_selectedLanguage);
    if (mounted) {
      setState(() {
        _availableVoices = voices;
        _selectedVoiceName = userVoice;
      });
    }
  }

  Future<void> _loadScript() async {
    setState(() => _isLoadingScript = true);
    try {
      final scriptJson = await SupabaseService.getScriptForPoint(
        widget.poi.id,
        _selectedLanguage,
      );
      setState(() {
        _currentScript =
            scriptJson != null ? Script.fromJson(scriptJson) : null;
        _isLoadingScript = false;
      });
    } catch (e) {
      setState(() => _isLoadingScript = false);
    }
  }

  Future<void> _togglePlayback() async {
    if (_isSpeaking) {
      await _audio.stop();
    } else if (_currentScript != null) {
      await _audio.playText(
        _currentScript!.content,
        language: _selectedLanguage,
      );
    }
  }

  Future<void> _changeLanguage(String lang) async {
    if (lang == _selectedLanguage) return;
    await _audio.stop();
    setState(() => _selectedLanguage = lang);
    await _loadScript();
    await _loadVoices();
  }

  Future<void> _openNavigation() async {
    final lat = widget.poi.lat;
    final lng = widget.poi.lng;
    final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=walking');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  int? get _distanceMeters {
    if (widget.userPosition == null) return null;
    return Geolocator.distanceBetween(
      widget.userPosition!.latitude,
      widget.userPosition!.longitude,
      widget.poi.lat,
      widget.poi.lng,
    ).round();
  }

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cat = Categories.byKey(widget.poi.primaryCategory);
    final distance = _distanceMeters;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header avec mini-carte
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.poi.localizedName('fr'),
                style: const TextStyle(
                  fontSize: 16,
                  shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                ),
              ),
              background: FlutterMap(
                options: MapOptions(
                  initialCenter:
                      LatLng(widget.poi.lat, widget.poi.lng),
                  initialZoom: 16,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.none,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.rayv.appvoyage',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(widget.poi.lat, widget.poi.lng),
                        width: 40,
                        height: 40,
                        child: Container(
                          decoration: BoxDecoration(
                            color: cat?.color ?? Colors.grey,
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: Colors.white, width: 3),
                          ),
                          child: Center(
                            child: Text(
                              cat?.emoji ?? '📍',
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Contenu
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges catégories + distance
                  Row(
                    children: [
                      ...widget.poi.categories.map((catKey) {
                        final c = Categories.byKey(catKey);
                        if (c == null) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: c.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: c.color.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              '${c.emoji} ${c.labelFr}',
                              style: TextStyle(
                                fontSize: 12,
                                color: c.color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      }),
                      const Spacer(),
                      if (distance != null)
                        Row(
                          children: [
                            Icon(Icons.near_me,
                                size: 16, color: AppTheme.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              distance < 1000
                                  ? '${distance}m'
                                  : '${(distance / 1000).toStringAsFixed(1)}km',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Lecteur audio
                  _buildAudioPlayer(),
                  const SizedBox(height: 24),

                  // Script texte
                  if (_currentScript != null) ...[
                    Text(
                      'Script audio',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Text(
                        _currentScript!.content,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '~${_currentScript!.content.split(' ').length} mots · ${(_currentScript!.content.split(' ').length * 0.4).round()} sec',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Infos logistiques
                  if (widget.poi.logistics != null &&
                      widget.poi.logistics!.isNotEmpty)
                    _buildLogisticsSection(),

                  // Bouton itinéraire
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _openNavigation,
                      icon: const Icon(Icons.directions_walk),
                      label: const Text('Itinéraire'),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogisticsSection() {
    final logistics = widget.poi.logistics!;
    final items = <_LogisticsItem>[];

    if (logistics['toilets'] != null && logistics['toilets'].toString().isNotEmpty) {
      items.add(_LogisticsItem(Icons.wc, 'Toilettes', logistics['toilets'].toString()));
    }
    if (logistics['parking'] != null && logistics['parking'].toString().isNotEmpty) {
      items.add(_LogisticsItem(Icons.local_parking, 'Stationnement', logistics['parking'].toString()));
    }
    if (logistics['photo_spot'] != null && logistics['photo_spot'].toString().isNotEmpty) {
      items.add(_LogisticsItem(Icons.camera_alt, 'Photo', logistics['photo_spot'].toString()));
    }
    if (logistics['tips'] != null && logistics['tips'].toString().isNotEmpty) {
      items.add(_LogisticsItem(Icons.lightbulb_outline, 'Bon à savoir', logistics['tips'].toString()));
    }
    if (logistics['accessibility'] != null && logistics['accessibility'].toString().isNotEmpty) {
      items.add(_LogisticsItem(Icons.accessible, 'Accessibilité', logistics['accessibility'].toString()));
    }
    if (logistics['hours'] != null && logistics['hours'].toString().isNotEmpty) {
      items.add(_LogisticsItem(Icons.schedule, 'Horaires', logistics['hours'].toString()));
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Infos pratiques',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(item.icon, size: 18, color: AppTheme.primaryColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.value,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildAudioPlayer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          // Sélecteur de langue
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLanguageChip('fr', '🇫🇷 FR'),
              const SizedBox(width: 8),
              _buildLanguageChip('en', '🇬🇧 EN'),
              const SizedBox(width: 8),
              _buildLanguageChip('es', '🇪🇸 ES'),
            ],
          ),
          // Sélecteur de voix
          if (_availableVoices.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.record_voice_over, size: 14, color: AppTheme.textSecondary),
                const SizedBox(width: 6),
                DropdownButton<String>(
                  value: _availableVoices.any((v) => v.name == _selectedVoiceName)
                      ? _selectedVoiceName
                      : null,
                  hint: Text('Voix par défaut', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  isDense: true,
                  style: TextStyle(fontSize: 12, color: AppTheme.textPrimary),
                  underline: const SizedBox.shrink(),
                  items: _availableVoices.map((v) {
                    return DropdownMenuItem(
                      value: v.name,
                      child: Text(v.displayName, style: const TextStyle(fontSize: 12)),
                    );
                  }).toList(),
                  onChanged: (voiceName) async {
                    if (voiceName != null) {
                      setState(() => _selectedVoiceName = voiceName);
                      await _audio.tts.setUserVoice(_selectedLanguage, voiceName);
                    }
                  },
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          // Bouton play/stop
          if (_isLoadingScript)
            const CircularProgressIndicator()
          else if (_currentScript == null)
            Text(
              'Aucun script disponible',
              style: TextStyle(color: AppTheme.textSecondary),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Bouton principal
                GestureDetector(
                  onTap: _togglePlayback,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color:
                              AppTheme.primaryColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isSpeaking ? Icons.stop : Icons.play_arrow,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ],
            ),
          if (_isSpeaking) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.volume_up,
                    size: 16, color: AppTheme.primaryColor),
                const SizedBox(width: 6),
                Text(
                  'En cours de lecture...',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLanguageChip(String lang, String label) {
    final isSelected = _selectedLanguage == lang;
    return GestureDetector(
      onTap: () => _changeLanguage(lang),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

/// Item d'info logistique (icône + label + valeur).
class _LogisticsItem {
  final IconData icon;
  final String label;
  final String value;

  const _LogisticsItem(this.icon, this.label, this.value);
}
