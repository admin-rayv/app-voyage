import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/route_data.dart';
import '../models/city.dart';
import '../models/discovery_playback_result.dart';
import '../models/point.dart' as models;
import '../models/audio_state.dart';
import '../services/audio_service.dart' as audio_svc;
import '../services/debug_log.dart';
import '../services/discovery_playback_service.dart';
import '../services/geofencing_service.dart';
import '../services/supabase_service.dart';
import '../services/user_preferences_service.dart';
import '../config/categories.dart';
import '../config/theme.dart';
import '../widgets/poi_list_item.dart';

/// Écran carte — Affiche tous les POIs d'une ville sur OpenStreetMap.

class MapScreen extends StatefulWidget {
  final City city;
  const MapScreen({super.key, required this.city});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  static const String _discoveryModePrefKey = 'discovery_mode_enabled';

  final MapController _mapController = MapController();
  final GeofencingService _geofencingService = GeofencingService();
  final DiscoveryPlaybackService _discoveryPlaybackService =
      DiscoveryPlaybackService();
  final audio_svc.AudioService _audioService = audio_svc.AudioService();
  List<models.Point> _allPoints = [];
  final Set<String> _activeFilters = {};
  bool _showList = false;
  bool _isLoading = true;
  bool _discoveryModeEnabled = false;
  bool _discoveryBusy = false;
  bool _restoreDiscoveryModeOnLoad = false;
  String? _error;
  String? _lastTriggeredPoiId;
  String? _lastAutoPlayedPoiId;
  LatLng? _userPosition;
  StreamSubscription<models.Point>? _discoverySubscription;
  StreamSubscription<AudioState>? _audioStateSubscription;
  late final AnimationController _discoveryPulseController;
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _discoveryPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _loadDiscoveryPreference();
    _loadPoints();
    _getUserPosition();
    _audioStateSubscription = _audioService.stateStream.listen((state) {
      if (!mounted) return;
      if (state.playState == AudioPlayState.playing &&
          state.playbackSource == AudioPlaybackSource.autoDiscovery &&
          state.currentPoi != null) {
        setState(() {
          _lastAutoPlayedPoiId = state.currentPoi!.id;
        });
      }
      if (state.playState == AudioPlayState.stopped &&
          state.playbackSource == AudioPlaybackSource.autoDiscovery &&
          _lastAutoPlayedPoiId != null) {
        setState(() {
          _lastAutoPlayedPoiId = null;
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _discoverySubscription?.cancel();
    _audioStateSubscription?.cancel();
    _discoveryPulseController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _syncDiscoveryUiWithService();
    }
  }

  Future<void> _loadPoints() async {
    try {
      final pointsJson = await SupabaseService.getPoints(widget.city.id);
      if (!mounted) return;

      setState(() {
        _allPoints = pointsJson.map((j) => models.Point.fromJson(j)).toList();
        _isLoading = false;
      });
      _maybeRestoreDiscoveryMode();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _getUserPosition() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requested = await Geolocator.requestPermission();
        if (requested == LocationPermission.denied ||
            requested == LocationPermission.deniedForever) {
          return;
        }
      }
      final pos = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      setState(() {
        _userPosition = LatLng(pos.latitude, pos.longitude);
      });
    } catch (_) {
      // GPS non disponible, pas grave
    }
  }

  List<models.Point> get _filteredPoints {
    if (_activeFilters.isEmpty) return _allPoints;
    return _allPoints
        .where((p) => p.categories.any((c) => _activeFilters.contains(c)))
        .toList();
  }

  List<models.Point> get _discoveryPoints {
    // Le mode découverte surveille tous les POIs chargés de la ville pour ne
    // pas dépendre des filtres visuels temporaires de la carte.
    return _allPoints;
  }

  models.Point? get _lastTriggeredPoi {
    final poiId = _lastTriggeredPoiId;
    if (poiId == null) {
      return null;
    }
    for (final poi in _allPoints) {
      if (poi.id == poiId) {
        return poi;
      }
    }
    return null;
  }

  models.Point? get _lastAutoPlayedPoi {
    final poiId = _lastAutoPlayedPoiId;
    if (poiId == null) {
      return null;
    }
    for (final poi in _allPoints) {
      if (poi.id == poiId) {
        return poi;
      }
    }
    return null;
  }

  Future<void> _loadDiscoveryPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool(_discoveryModePrefKey) ?? false;
    if (!mounted) return;

    _prefs = prefs;

    if (isEnabled && _geofencingService.isMonitoring) {
      _listenToDiscoveryTriggers();
      _setDiscoveryModeState(enabled: true);
      return;
    }

    if (isEnabled) {
      _restoreDiscoveryModeOnLoad = true;
      _maybeRestoreDiscoveryMode();
    }
  }

  void _maybeRestoreDiscoveryMode() {
    if (!_restoreDiscoveryModeOnLoad || _isLoading || _allPoints.isEmpty) {
      return;
    }

    _restoreDiscoveryModeOnLoad = false;
    unawaited(_enableDiscoveryMode(isRestoring: true));
  }

  Future<void> _toggleDiscoveryMode() async {
    if (_discoveryBusy) {
      return;
    }

    if (_discoveryModeEnabled || _geofencingService.isMonitoring) {
      await _disableDiscoveryMode();
      return;
    }

    await _enableDiscoveryMode();
  }

  Future<void> _enableDiscoveryMode({bool isRestoring = false}) async {
    if (_discoveryBusy) {
      return;
    }

    final points = _discoveryPoints;
    if (points.isEmpty) {
      await _persistDiscoveryPreference(false);
      _showSnackBar('Aucun point disponible pour activer la découverte.');
      return;
    }

    setState(() => _discoveryBusy = true);

    try {
      if (_geofencingService.isMonitoring) {
        _listenToDiscoveryTriggers();
        _setDiscoveryModeState(enabled: true);
        await _persistDiscoveryPreference(true);
        return;
      }

      final hasPermission = await _ensureDiscoveryPermissions();
      if (!hasPermission || !mounted) {
        await _persistDiscoveryPreference(false);
        _setDiscoveryModeState(enabled: false);
        return;
      }

      _geofencingService.resetTriggered();
      final started = await _geofencingService.start(points);
      if (!mounted) return;

      if (!started) {
        await _persistDiscoveryPreference(false);
        _setDiscoveryModeState(enabled: false);
        _showSnackBar('Impossible de démarrer le mode découverte.');
        return;
      }

      _listenToDiscoveryTriggers();
      _setDiscoveryModeState(enabled: true);
      await _persistDiscoveryPreference(true);

      if (!isRestoring) {
        _showSnackBar('Mode découverte activé.');
      }
    } finally {
      if (mounted) {
        setState(() => _discoveryBusy = false);
      }
    }
  }

  Future<void> _disableDiscoveryMode() async {
    if (_discoveryBusy) {
      return;
    }

    setState(() => _discoveryBusy = true);

    try {
      _geofencingService.stop();
      await _discoverySubscription?.cancel();
      _discoverySubscription = null;
      _setDiscoveryModeState(enabled: false);
      await _persistDiscoveryPreference(false);
      _showSnackBar('Mode découverte désactivé.');
    } finally {
      if (mounted) {
        setState(() => _discoveryBusy = false);
      }
    }
  }

  Future<void> _persistDiscoveryPreference(bool enabled) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    _prefs = prefs;
    await prefs.setBool(_discoveryModePrefKey, enabled);
  }

  void _listenToDiscoveryTriggers() {
    _discoverySubscription?.cancel();
    _discoverySubscription = _geofencingService.triggeredPois.listen((
      poi,
    ) async {
      if (!mounted) return;

      setState(() {
        _lastTriggeredPoiId = poi.id;
      });

      final result = await _discoveryPlaybackService.handleTriggeredPoi(poi);
      if (!mounted) return;

      if (result.played) {
        setState(() {
          _lastAutoPlayedPoiId = poi.id;
        });
      }

      _showSnackBar(_buildDiscoveryMessage(result));
    });
  }

  String _buildDiscoveryMessage(DiscoveryPlaybackResult result) {
    final poiName = result.poi.localizedName(result.language);
    if (result.played) {
      final delaySec = result.delayApplied.inSeconds;
      final delayMessage = delaySec > 0 ? ' dans ${delaySec}s' : '';
      return 'POI détecté: $poiName. Lecture automatique$delayMessage.';
    }

    switch (result.skipReason) {
      case DiscoveryPlaybackSkipReason.autoplayDisabled:
        return 'POI détecté: $poiName. Lecture automatique désactivée.';
      case DiscoveryPlaybackSkipReason.pausedByUser:
        return 'POI détecté: $poiName. Lecture ignorée car l’audio est en pause.';
      case DiscoveryPlaybackSkipReason.manualAudioInProgress:
        return 'POI détecté: $poiName. Lecture manuelle en cours, auto-play ignoré.';
      case DiscoveryPlaybackSkipReason.autoAudioAlreadyPlayingPoi:
        return 'POI détecté: $poiName déjà en lecture.';
      case DiscoveryPlaybackSkipReason.scriptNotFound:
      case DiscoveryPlaybackSkipReason.missingScriptContent:
        return 'POI détecté: $poiName. Aucun script disponible.';
      case DiscoveryPlaybackSkipReason.missingPoiName:
        return 'POI détecté. Lecture automatique ignorée.';
      case null:
        return 'POI détecté: $poiName.';
    }
  }

  void _syncDiscoveryUiWithService() {
    if (!mounted) {
      return;
    }

    final shouldBeEnabled =
        (_prefs?.getBool(_discoveryModePrefKey) ?? false) &&
        _geofencingService.isMonitoring;

    if (shouldBeEnabled) {
      _listenToDiscoveryTriggers();
    }

    if (_discoveryModeEnabled != shouldBeEnabled) {
      _setDiscoveryModeState(enabled: shouldBeEnabled);
    }
  }

  void _setDiscoveryModeState({required bool enabled}) {
    if (!mounted) {
      return;
    }

    setState(() {
      _discoveryModeEnabled = enabled;
      if (!enabled) {
        _lastTriggeredPoiId = null;
        _lastAutoPlayedPoiId = null;
      }
    });

    if (enabled) {
      if (!_discoveryPulseController.isAnimating) {
        _discoveryPulseController.repeat(reverse: true);
      }
    } else {
      _discoveryPulseController
        ..stop()
        ..reset();
    }
  }

  Future<bool> _ensureDiscoveryPermissions() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return false;
      final openSettings = await _showDiscoveryDialog(
        title: 'Activer la localisation',
        message:
            'Le mode découverte a besoin de la localisation du téléphone pour surveiller automatiquement les points autour de vous.',
        confirmLabel: 'Réglages',
      );
      if (openSettings) {
        await Geolocator.openLocationSettings();
      }
      return false;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      if (!mounted) return false;
      final shouldRequest = await _showDiscoveryDialog(
        title: 'Autoriser la localisation',
        message:
            'Le mode découverte utilise votre position pour détecter les POIs proches. Autorisez la localisation pour continuer.',
        confirmLabel: 'Continuer',
      );
      if (!shouldRequest) {
        return false;
      }

      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      if (mounted) {
        _showSnackBar('Autorisation GPS refusée. Mode découverte non activé.');
      }
      return false;
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return false;
      final openSettings = await _showDiscoveryDialog(
        title: 'Autorisation requise',
        message:
            'La localisation est bloquée de façon permanente. Ouvrez les réglages pour autoriser le mode découverte.',
        confirmLabel: 'Ouvrir les réglages',
      );
      if (openSettings) {
        await Geolocator.openAppSettings();
      }
      return false;
    }

    if (permission == LocationPermission.whileInUse) {
      if (!mounted) return false;
      final requestAlways = await _showDiscoveryDialog(
        title: 'Accès en arrière-plan recommandé',
        message:
            'Pour garder la découverte active quand l’app passe en arrière-plan, autorisez "Toujours" si votre téléphone le propose.',
        confirmLabel: 'Demander',
      );
      if (requestAlways) {
        permission = await Geolocator.requestPermission();
      }

      if (!mounted) return false;
      if (permission != LocationPermission.always) {
        _showSnackBar('Découverte active avec accès limité au premier plan.');
      }
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<bool> _showDiscoveryDialog({
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  void _showSnackBar(String message) {
    if (!mounted) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _toggleFilter(String category) {
    setState(() {
      if (_activeFilters.contains(category)) {
        _activeFilters.remove(category);
      } else {
        _activeFilters.add(category);
      }
    });
  }

  void _clearFilters() {
    setState(() => _activeFilters.clear());
  }

  void _centerOnUser() {
    if (_userPosition != null) {
      _mapController.move(_userPosition!, 15);
    }
  }

  void _showPoiPreview(models.Point poi) {
    final cat = Categories.byKey(poi.primaryCategory);
    final distance = _userPosition != null
        ? Geolocator.distanceBetween(
            _userPosition!.latitude,
            _userPosition!.longitude,
            poi.lat,
            poi.lng,
          ).round()
        : null;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Nom + catégorie
            Row(
              children: [
                Expanded(
                  child: Text(
                    poi.localizedName('fr'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (cat != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: cat.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: cat.color.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      '${cat.emoji} ${cat.labelFr}',
                      style: TextStyle(
                        fontSize: 12,
                        color: cat.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // Distance
            if (distance != null)
              Row(
                children: [
                  Icon(Icons.near_me, size: 16, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    distance < 1000
                        ? '${distance}m'
                        : '${(distance / 1000).toStringAsFixed(1)}km',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            // Toutes les catégories
            Wrap(
              spacing: 6,
              children: poi.categories.map((catKey) {
                final c = Categories.byKey(catKey);
                if (c == null) return const SizedBox.shrink();
                return Chip(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  label: Text(c.emoji, style: const TextStyle(fontSize: 12)),
                  backgroundColor: c.color.withValues(alpha: 0.1),
                  side: BorderSide(color: c.color.withValues(alpha: 0.3)),
                  padding: EdgeInsets.zero,
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            // Boutons écouter + détail
            Row(
              children: [
                // Bouton écouter
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      final preferredLanguage =
                          await UserPreferencesService.getPreferredLanguage();
                      final scriptJson =
                          await SupabaseService.getScriptForPointWithFallback(
                            poi.id,
                            [preferredLanguage, 'fr', 'en'],
                          );
                      if (scriptJson != null) {
                        final audio = audio_svc.AudioService();
                        await audio.init();
                        final language =
                            scriptJson['language'] as String? ??
                            preferredLanguage;
                        await audio.playText(
                          scriptJson['content'] as String? ?? '',
                          language: language,
                          poiName: poi.localizedName(language),
                          poi: poi,
                          scriptId: scriptJson['id'] as String?,
                          source: AudioPlaybackSource.manual,
                        );
                      } else {
                        DebugLog().log(
                          '[MapScreen] no script found for manual preview poi=${poi.id}',
                        );
                        if (mounted) {
                          _showSnackBar('Aucun script disponible pour ce POI.');
                        }
                      }
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Écouter'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Bouton détail
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      this.context.pushNamed(
                        'poiDetail',
                        extra: PoiDetailRouteData(
                          poi: poi,
                          userPosition: _userPosition,
                        ),
                      );
                    },
                    icon: const Icon(Icons.info_outline),
                    label: const Text('Détail'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.city.localizedName('fr')),
        actions: [
          // Toggle carte/liste
          IconButton(
            icon: Icon(_showList ? Icons.map : Icons.list),
            onPressed: () => setState(() => _showList = !_showList),
            tooltip: _showList ? 'Voir la carte' : 'Voir la liste',
          ),
          if (_userPosition != null && !_showList)
            IconButton(
              icon: const Icon(Icons.my_location),
              onPressed: _centerOnUser,
              tooltip: 'Ma position',
            ),
        ],
      ),
      floatingActionButton: _isLoading || _error != null
          ? null
          : _buildDiscoveryFab(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text('Erreur: $_error'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                        _error = null;
                      });
                      _loadPoints();
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                _buildFilterBar(),
                _buildDiscoveryBanner(),
                Expanded(child: _showList ? _buildList() : _buildMap()),
              ],
            ),
    );
  }

  Widget _buildFilterBar() {
    // Compter les POIs par catégorie
    final counts = <String, int>{};
    for (final p in _allPoints) {
      for (final c in p.categories) {
        counts[c] = (counts[c] ?? 0) + 1;
      }
    }

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        children: [
          // Chip "Tous"
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: FilterChip(
              selected: _activeFilters.isEmpty,
              label: Text('Tous (${_allPoints.length})'),
              onSelected: (_) => _clearFilters(),
              selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
              checkmarkColor: AppTheme.primaryColor,
              visualDensity: VisualDensity.compact,
            ),
          ),
          // Chips par catégorie
          ...Categories.all.map((cat) {
            final count = counts[cat.key] ?? 0;
            if (count == 0) return const SizedBox.shrink();
            final isActive = _activeFilters.contains(cat.key);
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: FilterChip(
                selected: isActive,
                label: Text('${cat.emoji} ${cat.labelFr} ($count)'),
                onSelected: (_) => _toggleFilter(cat.key),
                selectedColor: cat.color.withValues(alpha: 0.2),
                checkmarkColor: cat.color,
                visualDensity: VisualDensity.compact,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildList() {
    var points = _filteredPoints.toList();

    // Trier par distance si position dispo
    if (_userPosition != null) {
      points.sort((a, b) {
        final distA = Geolocator.distanceBetween(
          _userPosition!.latitude,
          _userPosition!.longitude,
          a.lat,
          a.lng,
        );
        final distB = Geolocator.distanceBetween(
          _userPosition!.latitude,
          _userPosition!.longitude,
          b.lat,
          b.lng,
        );
        return distA.compareTo(distB);
      });
    }

    if (points.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            const Text('Aucun POI trouvé avec ces filtres'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: points.length,
      itemBuilder: (context, index) {
        final poi = points[index];
        return PoiListItem(
          poi: poi,
          userPosition: _userPosition,
          onTap: () {
            context.pushNamed(
              'poiDetail',
              extra: PoiDetailRouteData(poi: poi, userPosition: _userPosition),
            );
          },
        );
      },
    );
  }

  Widget _buildMap() {
    final points = _filteredPoints;

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: LatLng(widget.city.centerLat, widget.city.centerLng),
        initialZoom: 14.5,
      ),
      children: [
        // Tuiles OpenStreetMap
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.rayv.appvoyage',
        ),
        // Marqueurs POIs
        MarkerLayer(
          markers: points.map((poi) {
            final cat = Categories.byKey(poi.primaryCategory);
            final color = cat?.color ?? Categories.defaultColor;
            final isHighlighted = _lastTriggeredPoiId == poi.id;
            final isAutoPlaying = _lastAutoPlayedPoiId == poi.id;
            return Marker(
              point: LatLng(poi.lat, poi.lng),
              width: isAutoPlaying
                  ? 50
                  : isHighlighted
                  ? 44
                  : 36,
              height: isAutoPlaying
                  ? 50
                  : isHighlighted
                  ? 44
                  : 36,
              child: GestureDetector(
                onTap: () => _showPoiPreview(poi),
                child: AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isAutoPlaying ? Colors.green[700] : color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isAutoPlaying
                            ? Colors.white
                            : isHighlighted
                            ? Colors.lightGreenAccent
                            : Colors.white,
                        width: isAutoPlaying
                            ? 4
                            : isHighlighted
                            ? 3
                            : 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              (isAutoPlaying
                                      ? Colors.greenAccent
                                      : isHighlighted
                                      ? Colors.green
                                      : Colors.black)
                                  .withValues(alpha: 0.3),
                          blurRadius: isAutoPlaying
                              ? 14
                              : isHighlighted
                              ? 10
                              : 4,
                          spreadRadius: isAutoPlaying
                              ? 3
                              : isHighlighted
                              ? 2
                              : 0,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        cat?.emoji ?? '📍',
                        style: TextStyle(
                          fontSize: isAutoPlaying
                              ? 20
                              : isHighlighted
                              ? 18
                              : 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        // Position utilisateur
        if (_userPosition != null)
          MarkerLayer(
            markers: [
              Marker(
                point: _userPosition!,
                width: 20,
                height: 20,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.3),
                        blurRadius: 8,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildDiscoveryBanner() {
    if (!_discoveryModeEnabled && !_discoveryBusy) {
      return const SizedBox.shrink();
    }

    final triggeredCount = _geofencingService.alreadyTriggered.length;
    final lastTriggeredPoi = _lastTriggeredPoi;
    final isActive = _discoveryModeEnabled;
    final autoPlayedPoi = _lastAutoPlayedPoi;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withValues(alpha: 0.12)
            : Colors.grey.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive
              ? Colors.green.withValues(alpha: 0.35)
              : Colors.grey.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isActive ? Icons.explore : Icons.hourglass_top,
            color: isActive ? Colors.green[700] : Colors.grey[700],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isActive
                      ? 'Mode découverte actif'
                      : 'Activation du mode découverte...',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: isActive ? Colors.green[800] : Colors.grey[800],
                  ),
                ),
                if (lastTriggeredPoi != null)
                  Text(
                    autoPlayedPoi != null
                        ? 'Lecture en cours: ${autoPlayedPoi.localizedName('fr')}'
                        : 'Dernier POI détecté: ${lastTriggeredPoi.localizedName('fr')}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  )
                else
                  Text(
                    isActive
                        ? 'Surveillance de ${_discoveryPoints.length} POIs'
                        : 'Vérification des permissions et du GPS',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          if (isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$triggeredCount déclenché${triggeredCount > 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.green[800],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDiscoveryFab() {
    final color = _discoveryModeEnabled ? Colors.green : Colors.grey.shade700;
    final label = _discoveryBusy
        ? 'Activation...'
        : _discoveryModeEnabled
        ? 'Découverte active'
        : 'Activer la découverte';

    return AnimatedBuilder(
      animation: _discoveryPulseController,
      builder: (context, child) {
        final scale = _discoveryModeEnabled
            ? 1 + (_discoveryPulseController.value * 0.08)
            : 1.0;
        return Transform.scale(scale: scale, child: child);
      },
      child: FloatingActionButton.extended(
        onPressed: _discoveryBusy ? null : _toggleDiscoveryMode,
        backgroundColor: color,
        foregroundColor: Colors.white,
        tooltip: label,
        icon: _discoveryBusy
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: Icon(
                  _discoveryModeEnabled ? Icons.radar : Icons.explore_outlined,
                  key: ValueKey<bool>(_discoveryModeEnabled),
                ),
              ),
        label: Text(label),
      ),
    );
  }
}
