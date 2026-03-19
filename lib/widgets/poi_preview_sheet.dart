import 'package:flutter/material.dart';
import '../models/point.dart';
import '../config/categories.dart';

/// Bottom sheet de prévisualisation d'un POI sélectionné.
class PoiPreviewSheet extends StatelessWidget {
  final Point point;
  final String lang;
  final VoidCallback onClose;
  final VoidCallback onDetail;

  const PoiPreviewSheet({
    super.key,
    required this.point,
    required this.lang,
    required this.onClose,
    required this.onDetail,
  });

  @override
  Widget build(BuildContext context) {
    final cat = Categories.byKey(point.primaryCategory);
    final color = cat?.color ?? Categories.defaultColor;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
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
          const SizedBox(height: 12),

          // Header: emoji + name + close
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(cat?.emoji ?? '📍', style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  point.localizedName(lang),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: onClose,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Category chips
          Wrap(
            spacing: 6,
            children: point.categories.map((c) {
              final cfg = Categories.byKey(c);
              return Chip(
                label: Text(
                  '${cfg?.emoji ?? ''} ${cfg?.label(lang) ?? c}',
                  style: const TextStyle(fontSize: 11),
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                backgroundColor: (cfg?.color ?? Colors.grey).withValues(alpha: 0.12),
                side: BorderSide.none,
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // Action button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onDetail,
              icon: const Icon(Icons.headphones, size: 18),
              label: const Text('Écouter'),
              style: FilledButton.styleFrom(
                backgroundColor: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
