import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../models/point.dart' as models;
import '../config/categories.dart';
import '../config/theme.dart';

/// Widget d'un POI dans la vue liste.

class PoiListItem extends StatelessWidget {
  final models.Point poi;
  final LatLng? userPosition;
  final VoidCallback onTap;

  const PoiListItem({
    super.key,
    required this.poi,
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Icône catégorie
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: (cat?.color ?? Colors.grey).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: (cat?.color ?? Colors.grey).withValues(alpha: 0.3),
                  ),
                ),
                child: Center(
                  child: Text(
                    cat?.emoji ?? '📍',
                    style: const TextStyle(fontSize: 22),
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
                      poi.localizedName('fr'),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
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
                            '${c.emoji} ${c.labelFr}',
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
                    Icon(Icons.near_me, size: 14, color: AppTheme.textSecondary),
                    const SizedBox(height: 2),
                    Text(
                      distance < 1000
                          ? '${distance}m'
                          : '${(distance / 1000).toStringAsFixed(1)}km',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, color: AppTheme.textSecondary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
