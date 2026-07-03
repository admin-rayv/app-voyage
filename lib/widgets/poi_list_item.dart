import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../models/point.dart' as models;
import '../config/categories.dart';
import '../l10n/l10n.dart';
import '../config/theme.dart';

/// Widget d'un POI dans la vue liste.

class PoiListItem extends StatelessWidget {
  final models.Point poi;
  final bool isVisited;
  final bool isPlaying;
  final LatLng? userPosition;
  final VoidCallback onTap;

  const PoiListItem({
    super.key,
    required this.poi,
    this.isVisited = false,
    this.isPlaying = false,
    this.userPosition,
    required this.onTap,
  });

  int? get _distanceMeters {
    if (userPosition == null) return null;
    return Geolocator.distanceBetween(
      userPosition!.latitude,
      userPosition!.longitude,
      poi.lat,
      poi.lng,
    ).round();
  }

  @override
  Widget build(BuildContext context) {
    final cat = Categories.byKey(poi.primaryCategory);
    final distance = _distanceMeters;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      color: isVisited ? AppTheme.softBackgroundOf(context) : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Icône catégorie (Hero → marqueur de la mini-carte du détail)
              Hero(
                tag: 'poi-icon-${poi.id}',
                child: Material(
                  type: MaterialType.transparency,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color:
                          (isVisited ? Colors.grey : (cat?.color ?? Colors.grey))
                              .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: (isVisited
                                ? Colors.grey
                                : (cat?.color ?? Colors.grey))
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            isVisited ? '✓' : cat?.emoji ?? '📍',
                            style: TextStyle(
                              fontSize: isVisited ? 20 : 22,
                              fontWeight: isVisited ? FontWeight.w800 : null,
                              color: isVisited ? Colors.grey.shade700 : null,
                            ),
                          ),
                          if (isPlaying)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.green.shade600,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Nom + catégories
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      poi.localizedName(context.languageCode),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (isVisited || isPlaying)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            if (isVisited)
                              _buildStatusPill(
                                label: context.l10n.legendListened,
                                color: Colors.grey.shade700,
                              ),
                            if (isPlaying)
                              _buildStatusPill(
                                label: context.l10n.legendPlaying,
                                color: Colors.green.shade700,
                              ),
                          ],
                        ),
                      ),
                    Wrap(
                      spacing: 4,
                      children: poi.categories.take(3).map((catKey) {
                        final c = Categories.byKey(catKey);
                        if (c == null) return const SizedBox.shrink();
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: c.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${c.emoji} ${c.label(context.languageCode)}',
                            style: TextStyle(
                              fontSize: 10,
                              color: c.color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              // Distance
              if (distance != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.near_me,
                      size: 14,
                      color: AppTheme.textSecondaryOf(context),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      distance < 1000
                          ? '${distance}m'
                          : '${(distance / 1000).toStringAsFixed(1)}km',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondaryOf(context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right,
                color: AppTheme.textSecondaryOf(context),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusPill({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
