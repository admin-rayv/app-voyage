import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../models/city.dart';
import '../models/point.dart' as models;
import '../services/supabase_service.dart';
import '../config/categories.dart';
import '../config/theme.dart';
import 'poi_detail_screen.dart';

/// Écran carte — Affiche tous les POIs d'une ville sur OpenStreetMap.

class MapScreen extends StatefulWidget {
  final City city;
  const MapScreen({super.key, required this.city});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  List<models.Point> _allPoints = [];
  final Set<String> _activeFilters = {};
  bool _isLoading = true;
  String? _error;
  LatLng? _userPosition;

  @override
  void initState() {
    super.initState();
    _loadPoints();
    _getUserPosition();
  }

  Future<void> _loadPoints() async {
    try {
      final pointsJson = await SupabaseService.getPoints(widget.city.id);
      setState(() {
        _allPoints = pointsJson.map((j) => models.Point.fromJson(j)).toList();
        _isLoading = false;
      });
    } catch (e) {
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
                poi.lng)
            .round()
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
            const SizedBox(height: 16),
            // Bouton détail
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PoiDetailScreen(
                        poi: poi,
                        userPosition: _userPosition,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.info_outline),
                label: const Text('Voir le détail'),
              ),
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
          if (_userPosition != null)
            IconButton(
              icon: const Icon(Icons.my_location),
              onPressed: _centerOnUser,
              tooltip: 'Ma position',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline,
                          size: 48, color: Colors.grey[400]),
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
                    Expanded(child: _buildMap()),
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
                label: Text('${cat.emoji} $count'),
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

  Widget _buildMap() {
    final points = _filteredPoints;

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter:
            LatLng(widget.city.centerLat, widget.city.centerLng),
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
            return Marker(
              point: LatLng(poi.lat, poi.lng),
              width: 36,
              height: 36,
              child: GestureDetector(
                onTap: () => _showPoiPreview(poi),
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      cat?.emoji ?? '📍',
                      style: const TextStyle(fontSize: 16),
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
}
