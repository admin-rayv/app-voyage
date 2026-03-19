import 'package:flutter/material.dart';
import '../models/city.dart';
import '../services/supabase_service.dart';
import '../config/categories.dart';
import '../config/theme.dart';
import 'map_screen.dart';
import 'debug_voices_screen.dart';
import '../widgets/voice_setup_dialog.dart';

/// Écran d'accueil — Liste des villes disponibles.
///
/// Premier écran affiché au lancement. Affiche les villes depuis Supabase
/// avec leur nombre de POIs et catégories présentes.

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<_CityWithStats>> _citiesFuture;

  @override
  void initState() {
    super.initState();
    _citiesFuture = _loadCities();
    // Vérifier les voix TTS au premier lancement
    WidgetsBinding.instance.addPostFrameCallback((_) {
      VoiceSetupDialog.checkAndShow(context);
    });
  }

  Future<List<_CityWithStats>> _loadCities() async {
    final citiesJson = await SupabaseService.getCities();
    final cities = citiesJson.map((j) => City.fromJson(j)).toList();

    final result = <_CityWithStats>[];
    for (final city in cities) {
      final pointsJson = await SupabaseService.getPoints(city.id);
      // Collecter les catégories uniques
      final categorySet = <String>{};
      for (final p in pointsJson) {
        final cats = p['categories'];
        if (cats is List) {
          for (final c in cats) {
            categorySet.add(c.toString());
          }
        }
      }
      result.add(_CityWithStats(
        city: city,
        poiCount: pointsJson.length,
        categories: categorySet.toList()..sort(),
      ));
    }
    return result;
  }

  Future<void> _refresh() async {
    setState(() {
      _citiesFuture = _loadCities();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(
              child: FutureBuilder<List<_CityWithStats>>(
                future: _citiesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Chargement des villes...'),
                        ],
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return _buildError(snapshot.error.toString());
                  }

                  final cities = snapshot.data ?? [];
                  if (cities.isEmpty) {
                    return _buildEmpty();
                  }

                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: cities.length,
                      itemBuilder: (context, index) =>
                          _buildCityCard(context, cities[index]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.headphones,
                size: 32,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 12),
              Text(
                'App Voyage',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Un ami historien dans tes écouteurs 🎧',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Explore une ville',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              // Debug button — temporaire
              IconButton(
                icon: const Icon(Icons.record_voice_over, size: 20),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DebugVoicesScreen()),
                ),
                tooltip: 'Debug voix TTS',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCityCard(BuildContext context, _CityWithStats cityStats) {
    final city = cityStats.city;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // Navigation vers la carte de la ville
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MapScreen(city: city),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.location_city,
                      size: 64,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 16,
                    child: Text(
                      city.localizedName('fr'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(blurRadius: 4, color: Colors.black38),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${cityStats.poiCount} POIs',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Catégories
            Padding(
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: cityStats.categories.map((catKey) {
                  final cat = Categories.byKey(catKey);
                  if (cat == null) return const SizedBox.shrink();
                  return Chip(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    label: Text(
                      '${cat.emoji} ${cat.labelFr}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: cat.color.withValues(alpha: 0.1),
                    side: BorderSide(color: cat.color.withValues(alpha: 0.3)),
                    padding: EdgeInsets.zero,
                  );
                }).toList(),
              ),
            ),
            // Langues disponibles
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: [
                  Icon(Icons.translate, size: 16, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    city.availableLanguages
                        .map((l) => l.toUpperCase())
                        .join(' · '),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.explore_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'Aucune ville disponible',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'Reviens bientôt!',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Impossible de charger les villes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              'Vérifie ta connexion internet',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Données d'une ville avec ses statistiques.
class _CityWithStats {
  final City city;
  final int poiCount;
  final List<String> categories;

  const _CityWithStats({
    required this.city,
    required this.poiCount,
    required this.categories,
  });
}


