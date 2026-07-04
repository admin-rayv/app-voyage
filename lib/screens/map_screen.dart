import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/constants.dart';
import '../config/route_data.dart';
import '../models/city.dart';
import '../models/discovery_playback_result.dart';
import '../models/point.dart' as models;
import '../models/audio_state.dart';
import '../services/audio_service.dart' as audio_svc;
import '../services/debug_log.dart';
import '../services/city_download_service.dart';
import '../services/discovery_playback_service.dart';
import '../services/favorite_poi_service.dart';
import '../services/geofencing_service.dart';
import '../services/group_session_service.dart';
import '../services/notification_service.dart';
import '../services/permission_service.dart';
import '../services/supabase_service.dart';
import '../services/user_preferences_service.dart';
import '../services/visited_poi_service.dart';
import '../config/categories.dart';
import '../l10n/l10n.dart';
import '../config/theme.dart';
import '../widgets/group_session_sheet.dart';
import '../widgets/map_tiles.dart';
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
  final NotificationService _notificationService = NotificationService();
  final PermissionService _permissionService = PermissionService();
  final audio_svc.AudioService _audioService = audio_svc.AudioService();
  final VisitedPoiService _visitedPoiService = VisitedPoiService();
  final FavoritePoiService _favoritePoiService = FavoritePoiService();
  List<models.Point> _allPoints = [];
  final Set<String> _activeFilters = {};
  bool _showList = false;
  bool _showUnvisitedOnly = false;
  bool _showFavoritesOnly = false;
  bool _isLoading = true;
  bool _discoveryModeEnabled = false;
  bool _discoveryBusy = false;
  bool _restoreDiscoveryModeOnLoad = false;
  String? _error;
  String? _lastTriggeredPoiId;
  String? _lastAutoPlayedPoiId;
  String? _currentPlayingPoiId;
  LatLng? _userPosition;
  StreamSubscription<Position>? _positionSubscription;
  StreamSubscription<models.Point>? _discoverySubscription;
  StreamSubscription<AudioState>? _audioStateSubscription;
  StreamSubscription<DiscoveryNotificationPayload>?
  _notificationTapSubscription;
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
    _notificationTapSubscription = _notificationService.tapStream.listen((
      payload,
    ) {
      _handleNotificationPayload(payload);
    });
    unawaited(_visitedPoiService.init());
    unawaited(_favoritePoiService.init());
    _favoritePoiService.listenable.addListener(_onFavoritesChanged);
    _loadPoints();
    _getUserPosition();
    _audioStateSubscription = _audioService.stateStream.listen((state) {
      if (!mounted) return;
      setState(() {
        _currentPlayingPoiId =
            state.playState == AudioPlayState.playing &&
                state.currentPoi != null
            ? state.currentPoi!.id
            : null;

        if (state.playState == AudioPlayState.playing &&
            state.playbackSource == AudioPlaybackSource.autoDiscovery &&
            state.currentPoi != null) {
          _lastAutoPlayedPoiId = state.currentPoi!.id;
        }

        if (state.playState == AudioPlayState.stopped &&
            state.playbackSource == AudioPlaybackSource.autoDiscovery &&
            _lastAutoPlayedPoiId != null) {
          _lastAutoPlayedPoiId = null;
        }
      });
    });
  }

  void _onFavoritesChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _favoritePoiService.listenable.removeListener(_onFavoritesChanged);
    _positionSubscription?.cancel();
    _discoverySubscription?.cancel();
    _audioStateSubscription?.cancel();
    _notificationTapSubscription?.cancel();
    _discoveryPulseController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _syncDiscoveryUiWithService();
      _handleNotificationPayload(_notificationService.pendingPayload);
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
      _handleNotificationPayload(_notificationService.pendingPayload);
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
      _startPositionUpdates();
    } catch (_) {
      // GPS non disponible, pas grave
    }
  }

  /// Suivre la position en continu pendant que l'écran est visible, pour que
  /// le point bleu et les distances restent à jour pendant la balade.
  void _startPositionUpdates() {
    if (_positionSubscription != null) return;
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: AppConstants.gpsDistanceFilterMeters,
      ),
    ).listen(
      (position) {
        if (!mounted) return;
        setState(() {
          _userPosition = LatLng(position.latitude, position.longitude);
        });
      },
      onError: (Object error) {
        DebugLog().log('[MapScreen] position stream error: $error');
      },
    );
  }

  List<models.Point> get _basePoints {
    Iterable<models.Point> points = _allPoints;
    if (_showUnvisitedOnly) {
      points = points.where((poi) => !_visitedPoiService.isVisitedPoint(poi));
    }
    if (_showFavoritesOnly) {
      points = points.where(_favoritePoiService.isFavoritePoint);
    }
    return points.toList();
  }

  List<models.Point> get _filteredPoints {
    final basePoints = _basePoints;
    if (_activeFilters.isEmpty) return basePoints;
    return basePoints
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
      if (!mounted) return;
      _showSnackBar(context.l10n.noPointsAvailable);
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

      final permissionResult = await _permissionService
          .requestDiscoveryPermissions(
            context,
            requestBackground: !isRestoring,
          );
      if (!permissionResult.isGranted || !mounted) {
        await _persistDiscoveryPreference(false);
        _setDiscoveryModeState(enabled: false);
        final message = _permissionMessage(permissionResult);
        if (!isRestoring && message != null) {
          _showSnackBar(message);
        }
        return;
      }

      await _notificationService.ensurePermissions();
      _geofencingService.resetTriggered();

      // Ne pas re-déclencher les POIs déjà écoutés (persistés), sauf si
      // l'utilisateur a activé le réglage "rejouer les POIs écoutés".
      final replayVisited =
          await UserPreferencesService.isDiscoveryReplayVisitedEnabled();
      if (!replayVisited) {
        await _visitedPoiService.init();
        _geofencingService.seedTriggered(
          _visitedPoiService.visitedPoiIdsForCity(widget.city.id),
        );
      }

      final started = await _geofencingService.start(points);
      if (!mounted) return;

      if (!started) {
        await _persistDiscoveryPreference(false);
        _setDiscoveryModeState(enabled: false);
        if (!mounted) return;
        _showSnackBar(context.l10n.discoveryStartFailed);
        return;
      }

      _listenToDiscoveryTriggers();
      _setDiscoveryModeState(enabled: true);
      await _persistDiscoveryPreference(true);

      if (!isRestoring && mounted) {
        _showSnackBar(
          _permissionMessage(permissionResult) ?? context.l10n.discoveryEnabled,
        );
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
      await _notificationService.cancelDiscoveryNotification();
      await _discoverySubscription?.cancel();
      _discoverySubscription = null;
      _setDiscoveryModeState(enabled: false);
      await _persistDiscoveryPreference(false);
      if (!mounted) return;
      _showSnackBar(context.l10n.discoveryDisabled);
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
    final l10n = context.l10n;
    final poiName = result.poi.localizedName(result.language);
    if (result.played) {
      final delaySec = result.delayApplied.inSeconds;
      return delaySec > 0
          ? l10n.msgAutoplayIn(poiName, delaySec)
          : l10n.msgAutoplayNow(poiName);
    }

    switch (result.skipReason) {
      case DiscoveryPlaybackSkipReason.autoplayDisabled:
        return l10n.msgAutoplayDisabled(poiName);
      case DiscoveryPlaybackSkipReason.pausedByUser:
        return l10n.msgPausedSkip(poiName);
      case DiscoveryPlaybackSkipReason.manualAudioInProgress:
        return l10n.msgManualSkip(poiName);
      case DiscoveryPlaybackSkipReason.autoAudioAlreadyPlayingPoi:
        return l10n.msgAlreadyPlaying(poiName);
      case DiscoveryPlaybackSkipReason.scriptNotFound:
      case DiscoveryPlaybackSkipReason.missingScriptContent:
        return l10n.msgNoScript(poiName);
      case DiscoveryPlaybackSkipReason.missingPoiName:
      case null:
        return l10n.msgDetectedOnly(poiName);
    }
  }

  /// Message localisé selon le statut de permission (les messages portés
  /// par DiscoveryPermissionResult sont en dur — on localise ici).
  String? _permissionMessage(DiscoveryPermissionResult result) {
    final l10n = context.l10n;
    switch (result.status) {
      case DiscoveryPermissionStatus.serviceDisabled:
        return l10n.permServiceDisabled;
      case DiscoveryPermissionStatus.denied:
        return l10n.permDenied;
      case DiscoveryPermissionStatus.deniedForever:
        return l10n.permDeniedForever;
      case DiscoveryPermissionStatus.grantedForegroundOnly:
        return result.message != null ? l10n.permForegroundOnly : null;
      case DiscoveryPermissionStatus.grantedAlways:
        return null;
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

  void _handleNotificationPayload(DiscoveryNotificationPayload? payload) {
    if (!mounted || payload == null || _allPoints.isEmpty) {
      return;
    }

    models.Point? matchedPoi;
    for (final poi in _allPoints) {
      if (poi.id == payload.poiId) {
        matchedPoi = poi;
        break;
      }
    }

    if (matchedPoi == null) {
      return;
    }

    _notificationService.markPendingPayloadHandled(payload);
    context.pushNamed(
      'poiDetail',
      extra: PoiDetailRouteData(poi: matchedPoi, userPosition: _userPosition),
    );
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
    setState(() {
      _activeFilters.clear();
      _showUnvisitedOnly = false;
      _showFavoritesOnly = false;
    });
  }

  void _centerOnUser() {
    if (_userPosition != null) {
      _mapController.move(_userPosition!, 15);
    }
  }

  /// Télécharger le pack offline de la ville: données des POIs + scripts,
  /// MP3 Edge TTS (langue préférée) et tuiles de carte — à faire en Wi-Fi;
  /// ensuite toute la ville fonctionne sans réseau.
  Future<void> _downloadCityAudios() async {
    final language = await UserPreferencesService.getPreferredLanguage();
    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.downloadDialogTitle),
        content: Text(
          context.l10n.downloadDialogBody(
            widget.city.localizedName(context.languageCode),
            language.toUpperCase(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(context.l10n.download),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final progressNotifier = ValueNotifier<(int, int)>((0, 1));
    var cancelled = false;

    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: Text(context.l10n.downloadProgressTitle),
          content: ValueListenableBuilder<(int, int)>(
            valueListenable: progressNotifier,
            builder: (context, progress, _) {
              final (current, total) = progress;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearProgressIndicator(
                    value: total == 0 ? null : current / total,
                  ),
                  const SizedBox(height: 12),
                  Text(context.l10n.downloadProgressCount(current, total)),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                cancelled = true;
                Navigator.of(dialogContext).pop();
              },
              child: Text(context.l10n.stopAction),
            ),
          ],
        ),
      ),
    );

    try {
      await CityDownloadService.downloadCity(
        cityId: widget.city.id,
        points: _allPoints,
        audioLanguage: language,
        tileUrlFor: MapTiles.tileUrlBuilder(context),
        isCancelled: () => cancelled,
        onProgress: (current, total) {
          progressNotifier.value = (current, total);
        },
      );
    } catch (error) {
      DebugLog().log('[MapScreen] download pack error: $error');
    }

    if (!mounted) return;
    if (!cancelled) {
      Navigator.of(context, rootNavigator: true).pop();
      final (done, total) = progressNotifier.value;
      _showSnackBar(
        done >= total && total > 0
            ? context.l10n.downloadDone(done)
            : context.l10n.downloadInterrupted(done, total),
      );
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
                  color: AppTheme.subtleBorderOf(context),
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
                    poi.localizedName(context.languageCode),
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
                      '${cat.emoji} ${cat.label(context.languageCode)}',
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
                  Icon(Icons.near_me, size: 16, color: AppTheme.textSecondaryOf(context)),
                  const SizedBox(width: 4),
                  Text(
                    distance < 1000
                        ? '${distance}m'
                        : '${(distance / 1000).toStringAsFixed(1)}km',
                    style: TextStyle(color: AppTheme.textSecondaryOf(context)),
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
                        if (this.context.mounted) {
                          _showSnackBar(this.context.l10n.noScriptForPoi);
                        }
                      }
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: Text(context.l10n.listen),
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
                    label: Text(context.l10n.detail),
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
        title: Text(widget.city.localizedName(context.languageCode)),
        actions: [
          // Écouter ensemble (sync groupe) — point vert quand session active
          ValueListenableBuilder<String?>(
            valueListenable: GroupSessionService().activeCode,
            builder: (context, sessionCode, _) => IconButton(
              icon: Badge(
                isLabelVisible: sessionCode != null,
                smallSize: 10,
                backgroundColor: Colors.greenAccent,
                child: const Icon(Icons.group_outlined),
              ),
              onPressed: () => GroupSessionSheet.show(context),
              tooltip: sessionCode != null
                  ? context.l10n.groupActiveBadge(sessionCode)
                  : context.l10n.groupListenTooltip,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.download_for_offline_outlined),
            onPressed: _isLoading ? null : _downloadCityAudios,
            tooltip: context.l10n.downloadAudiosTooltip,
          ),
          // Toggle carte/liste
          IconButton(
            icon: Icon(_showList ? Icons.map : Icons.list),
            onPressed: () => setState(() => _showList = !_showList),
            tooltip: _showList ? context.l10n.viewMapTooltip : context.l10n.viewListTooltip,
          ),
          if (_userPosition != null && !_showList)
            IconButton(
              icon: const Icon(Icons.my_location),
              onPressed: _centerOnUser,
              tooltip: context.l10n.myPositionTooltip,
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
                  Text(context.l10n.errorWith(_error ?? '')),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                        _error = null;
                      });
                      _loadPoints();
                    },
                    child: Text(context.l10n.retry),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                _buildFilterBar(),
                AnimatedBuilder(
                  animation: _visitedPoiService.listenable,
                  builder: (context, _) => _buildProgressSection(),
                ),
                _buildDiscoveryBanner(),
                Expanded(
                  child: AnimatedBuilder(
                    animation: _visitedPoiService.listenable,
                    builder: (context, _) =>
                        _showList ? _buildList() : _buildMap(),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterBar() {
    final basePoints = _basePoints;

    // Compter les POIs par catégorie
    final counts = <String, int>{};
    for (final p in basePoints) {
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
              selected: _activeFilters.isEmpty &&
                  !_showUnvisitedOnly &&
                  !_showFavoritesOnly,
              label: Text(context.l10n.allFilter(_allPoints.length)),
              onSelected: (_) => _clearFilters(),
              selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
              checkmarkColor: AppTheme.primaryColor,
              visualDensity: VisualDensity.compact,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: FilterChip(
              selected: _showUnvisitedOnly,
              label: Text(context.l10n.unvisitedOnlyFilter(basePoints.length)),
              onSelected: (_) {
                setState(() {
                  _showUnvisitedOnly = !_showUnvisitedOnly;
                });
              },
              selectedColor: Colors.orange.withValues(alpha: 0.18),
              checkmarkColor: Colors.orange.shade800,
              visualDensity: VisualDensity.compact,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: FilterChip(
              selected: _showFavoritesOnly,
              label: Text(
                context.l10n.favoritesFilter(
                  _allPoints.where(_favoritePoiService.isFavoritePoint).length,
                ),
              ),
              onSelected: (_) {
                setState(() {
                  _showFavoritesOnly = !_showFavoritesOnly;
                });
              },
              selectedColor: Colors.redAccent.withValues(alpha: 0.15),
              checkmarkColor: Colors.redAccent,
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
                label: Text('${cat.emoji} ${cat.label(context.languageCode)} ($count)'),
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

  Widget _buildProgressSection() {
    final totalCount = _allPoints.length;
    final visitedCount = _visitedPoiService.visitedCountForCity(widget.city.id);
    final progress = totalCount == 0 ? 0.0 : visitedCount / totalCount;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 2, 12, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceOf(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.progressListened(visitedCount, totalCount),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                totalCount == 0 ? '0%' : '${(progress * 100).round()}%',
                style: TextStyle(
                  color: AppTheme.textSecondaryOf(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildLegendChip(
                icon: Icons.radio_button_checked,
                label: context.l10n.legendToDiscover,
                color: AppTheme.primaryColor,
              ),
              _buildLegendChip(
                icon: Icons.check_circle,
                label: context.l10n.legendListened,
                color: Colors.grey.shade600,
              ),
              _buildLegendChip(
                icon: Icons.graphic_eq,
                label: context.l10n.legendPlaying,
                color: Colors.green.shade700,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
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
            Text(context.l10n.noPoisWithFilters),
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
          isVisited: _visitedPoiService.isVisitedPoint(poi),
          isPlaying: _currentPlayingPoiId == poi.id,
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

    return AnimatedBuilder(
      animation: _discoveryPulseController,
      builder: (context, _) => FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: LatLng(widget.city.centerLat, widget.city.centerLng),
          initialZoom: 14.5,
        ),
        children: [
          MapTiles.tileLayer(context),
          // Rayons de déclenchement — visibles en mode découverte pour
          // calibrer le geofencing pendant les tests terrain.
          if (_discoveryModeEnabled)
            CircleLayer(
              circles: points
                  .map(
                    (poi) => CircleMarker(
                      point: LatLng(poi.lat, poi.lng),
                      radius: poi.triggerRadiusM.toDouble(),
                      useRadiusInMeter: true,
                      color: Colors.green.withValues(alpha: 0.08),
                      borderColor: Colors.green.withValues(alpha: 0.35),
                      borderStrokeWidth: 1.5,
                    ),
                  )
                  .toList(),
            ),
          MarkerClusterLayerWidget(
            options: MarkerClusterLayerOptions(
              maxClusterRadius: 46,
              size: const Size(44, 44),
              padding: const EdgeInsets.all(50),
              maxZoom: 17,
              markers: points.map(_buildMarkerFor).toList(),
              builder: (context, markers) => _buildClusterBubble(markers),
            ),
          ),
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
          MapTiles.attribution(),
        ],
      ),
    );
  }

  Marker _buildMarkerFor(models.Point poi) {
    final cat = Categories.byKey(poi.primaryCategory);
    final color = cat?.color ?? Categories.defaultColor;
    final isHighlighted = _lastTriggeredPoiId == poi.id;
    final isPlaying = _currentPlayingPoiId == poi.id;
    final isVisited = _visitedPoiService.isVisitedPoint(poi);
    final size = isPlaying
        ? 58.0
        : isHighlighted
        ? 46.0
        : 40.0;

    return Marker(
      point: LatLng(poi.lat, poi.lng),
      width: size,
      height: size,
      child: GestureDetector(
        onTap: () => _showPoiPreview(poi),
        child: _buildPoiMarker(
          emoji: cat?.emoji ?? '📍',
          color: color,
          isVisited: isVisited,
          isHighlighted: isHighlighted,
          isPlaying: isPlaying,
        ),
      ),
    );
  }

  Widget _buildClusterBubble(List<Marker> markers) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '${markers.length}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildPoiMarker({
    required String emoji,
    required Color color,
    required bool isVisited,
    required bool isHighlighted,
    required bool isPlaying,
  }) {
    final pulse = isPlaying ? _discoveryPulseController.value : 0.0;
    final ringScale = 1 + (pulse * 0.22);
    final markerColor = isVisited ? Colors.grey.shade500 : color;
    final borderColor = isPlaying
        ? Colors.white
        : isHighlighted
        ? Colors.lightGreenAccent
        : Colors.white;
    final markerOpacity = isVisited && !isPlaying ? 0.72 : 1.0;
    final size = isPlaying
        ? 38.0
        : isHighlighted
        ? 34.0
        : 30.0;

    return Stack(
      alignment: Alignment.center,
      children: [
        if (isPlaying)
          Transform.scale(
            scale: ringScale,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green.withValues(alpha: 0.12),
                border: Border.all(
                  color: Colors.green.withValues(alpha: 0.28),
                  width: 2,
                ),
              ),
            ),
          ),
        AnimatedOpacity(
          opacity: markerOpacity,
          duration: const Duration(milliseconds: 220),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: isPlaying ? Colors.green.shade700 : markerColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: borderColor,
                width: isPlaying
                    ? 3
                    : isHighlighted
                    ? 2.5
                    : 2,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      (isPlaying
                              ? Colors.green
                              : isVisited
                              ? Colors.grey
                              : Colors.black)
                          .withValues(alpha: 0.25),
                  blurRadius: isPlaying
                      ? 12
                      : isHighlighted
                      ? 8
                      : 4,
                  spreadRadius: isPlaying ? 2 : 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                isVisited && !isPlaying ? '✓' : emoji,
                style: TextStyle(
                  fontSize: isPlaying
                      ? 18
                      : isHighlighted
                      ? 16
                      : 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDiscoveryBanner() {
    if (!_discoveryModeEnabled && !_discoveryBusy) {
      return const SizedBox.shrink();
    }

    final triggeredCount = _geofencingService.sessionTriggerCount;
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
                      ? context.l10n.discoveryActiveTitle
                      : context.l10n.discoveryActivating,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: isActive ? Colors.green[800] : Colors.grey[800],
                  ),
                ),
                if (lastTriggeredPoi != null)
                  Text(
                    autoPlayedPoi != null
                        ? context.l10n.nowPlayingPoi(autoPlayedPoi.localizedName(context.languageCode))
                        : context.l10n.lastDetected(lastTriggeredPoi.localizedName(context.languageCode)),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondaryOf(context),
                    ),
                  )
                else
                  Text(
                    isActive
                        ? context.l10n.watchingPois(_discoveryPoints.length)
                        : context.l10n.checkingPermissions,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondaryOf(context),
                    ),
                  ),
              ],
            ),
          ),
          if (isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.surfaceOf(context),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                context.l10n.triggeredCount(triggeredCount),
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
        ? context.l10n.fabActivating
        : _discoveryModeEnabled
        ? context.l10n.fabDiscoveryOn
        : context.l10n.fabEnableDiscovery;

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
