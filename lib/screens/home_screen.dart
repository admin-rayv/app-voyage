import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/city.dart';
import '../services/supabase_service.dart';
import '../config/categories.dart';
import '../l10n/l10n.dart';
import '../config/theme.dart';
import '../services/group_session_service.dart';
import '../widgets/group_session_sheet.dart';
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
    // 2 requêtes au total (villes + résumé des POIs), peu importe le
    // nombre de villes — avant: 1 fetch complet des POIs par ville.
    final results = await Future.wait([
      SupabaseService.getCities(),
      SupabaseService.getPublishedPointSummaries(),
    ]);
    final cities = results[0].map((j) => City.fromJson(j)).toList();
    final summaries = results[1];

    final countByCity = <String, int>{};
    final categoriesByCity = <String, Set<String>>{};
    for (final summary in summaries) {
      final cityId = summary['city_id']?.toString() ?? '';
      countByCity[cityId] = (countByCity[cityId] ?? 0) + 1;
      final cats = summary['categories'];
      if (cats is List) {
        categoriesByCity
            .putIfAbsent(cityId, () => <String>{})
            .addAll(cats.map((c) => c.toString()));
      }
    }

    return cities
        .map(
          (city) => _CityWithStats(
            city: city,
            poiCount: countByCity[city.id] ?? 0,
            categories: (categoriesByCity[city.id] ?? const <String>{})
                .toList()
              ..sort(),
          ),
        )
        .toList();
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
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(context.l10n.citiesLoading),
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
            context.l10n.tagline,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                context.l10n.exploreCity,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              // « Écouter ensemble » dès l'accueil: un invité rejoint une
              // visite par code sans avoir à entrer dans une ville.
              ValueListenableBuilder<String?>(
                valueListenable: GroupSessionService().activeCode,
                builder: (context, code, _) => IconButton(
                  icon: Badge(
                    isLabelVisible: code != null,
                    child: const Icon(Icons.groups_outlined, size: 22),
                  ),
                  onPressed: () => GroupSessionSheet.show(context),
                  tooltip: context.l10n.groupListenTooltip,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.settings, size: 22),
                onPressed: () => context.pushNamed('settings'),
                tooltip: context.l10n.settingsTooltip,
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
          context.pushNamed('map', extra: city);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo de la ville (image_url en DB) avec fallback dégradé
            SizedBox(
              height: 160,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildCityImage(city),
                  // Voile pour la lisibilité du texte
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.45),
                        ],
                        begin: Alignment.center,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 16,
                    child: Text(
                      city.localizedName(context.languageCode),
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
                        context.l10n.poiCountBadge(cityStats.poiCount),
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  if (city.imageCredit != null &&
                      city.imageCredit!.trim().isNotEmpty)
                    Positioned(
                      top: 8,
                      right: 10,
                      child: Text(
                        city.imageCredit!,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 9,
                          shadows: const [
                            Shadow(blurRadius: 3, color: Colors.black54),
                          ],
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
                      '${cat.emoji} ${cat.label(context.languageCode)}',
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
                  Icon(Icons.translate, size: 16, color: AppTheme.textSecondaryOf(context)),
                  const SizedBox(width: 4),
                  Text(
                    city.availableLanguages
                        .map((l) => l.toUpperCase())
                        .join(' · '),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondaryOf(context),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: AppTheme.textSecondaryOf(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Photo réseau si image_url est renseignée en DB, sinon dégradé de marque.
  Widget _buildCityImage(City city) {
    final imageUrl = city.imageUrl;
    final fallback = DecoratedBox(
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
      child: Center(
        child: Icon(
          Icons.location_city,
          size: 64,
          color: Colors.white.withValues(alpha: 0.3),
        ),
      ),
    );

    if (imageUrl == null || imageUrl.trim().isEmpty) {
      return fallback;
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => fallback,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : fallback,
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.explore_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            context.l10n.noCities,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.comeBackSoon,
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
            Text(
              context.l10n.citiesError,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.checkConnection,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh),
              label: Text(context.l10n.retry),
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
