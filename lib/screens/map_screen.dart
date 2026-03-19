import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/point.dart';
import '../config/categories.dart';
import '../services/supabase_service.dart';
import '../widgets/poi_preview_sheet.dart';
import '../widgets/category_filter_bar.dart';

/// Écran carte — Affiche les POIs sur OpenStreetMap.
class MapScreen extends StatefulWidget {
  final String cityId;
  final String cityName;

  const MapScreen({super.key, required this.cityId, required this.cityName});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  List<Point> _allPoints = [];
  Set<String> _activeCategories = {};
  bool _loading = true;
  String? _error;
  Point? _selectedPoint;

  // Saint-Lambert centre par défaut
  static const _defaultCenter = LatLng(45.5000, -73.5100);
  static const _defaultZoom = 14.5;

  @override
  void initState() {
    super.initState();
    _activeCategories = Categories.all.map((c) => c.key).toSet();
    _loadPoints();
  }

  Future<void> _loadPoints() async {
    try {
      final data = await SupabaseService.getPoints(widget.cityId);
      setState(() {
        _allPoints = data.map((j) => Point.fromJson(j)).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  List<Point> get _filteredPoints {
    return _allPoints
        .where((p) => p.categories.any((c) => _activeCategories.contains(c)))
        .toList();
  }

  void _onToggleCategory(String key) {
    setState(() {
      if (_activeCategories.contains(key)) {
        // Don't allow deselecting all
        if (_activeCategories.length > 1) {
          _activeCategories.remove(key);
        }
      } else {
        _activeCategories.add(key);
      }
    });
  }

  void _onSelectAll() {
    setState(() {
      _activeCategories = Categories.all.map((c) => c.key).toSet();
    });
  }

  void _onMarkerTap(Point point) {
    setState(() => _selectedPoint = point);
  }

  void _onDismissSheet() {
    setState(() => _selectedPoint = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cityName),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Erreur: $_error'))
              : Stack(
                  children: [
                    // ── Carte ──
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _defaultCenter,
                        initialZoom: _defaultZoom,
                        onTap: (_, _) => _onDismissSheet(),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.appvoyage.app',
                        ),
                        MarkerLayer(
                          markers: _filteredPoints.map((point) {
                            final cat = Categories.byKey(point.primaryCategory);
                            final color = cat?.color ?? Categories.defaultColor;
                            final emoji = cat?.emoji ?? '📍';
                            final isSelected = _selectedPoint?.id == point.id;

                            return Marker(
                              point: LatLng(point.lat, point.lng),
                              width: isSelected ? 48 : 40,
                              height: isSelected ? 48 : 40,
                              child: GestureDetector(
                                onTap: () => _onMarkerTap(point),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.white70,
                                      width: isSelected ? 3 : 2,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color:
                                                  color.withValues(alpha: 0.5),
                                              blurRadius: 8,
                                              spreadRadius: 2,
                                            )
                                          ]
                                        : null,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    emoji,
                                    style: TextStyle(
                                        fontSize: isSelected ? 20 : 16),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),

                    // ── Filtre catégories ──
                    Positioned(
                      top: 8,
                      left: 0,
                      right: 0,
                      child: CategoryFilterBar(
                        activeCategories: _activeCategories,
                        onToggle: _onToggleCategory,
                        onSelectAll: _onSelectAll,
                        lang: 'fr',
                      ),
                    ),

                    // ── Compteur POIs ──
                    Positioned(
                      bottom: _selectedPoint != null ? 200 : 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_filteredPoints.length} / ${_allPoints.length} POIs',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13),
                        ),
                      ),
                    ),

                    // ── Bottom sheet POI sélectionné ──
                    if (_selectedPoint != null)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: PoiPreviewSheet(
                          point: _selectedPoint!,
                          lang: 'fr',
                          onClose: _onDismissSheet,
                          onDetail: () {
                            // TODO: Navigate to POI detail screen
                          },
                        ),
                      ),
                  ],
                ),
    );
  }
}
