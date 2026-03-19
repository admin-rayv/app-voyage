import 'package:flutter/material.dart';
import '../config/categories.dart';

/// Barre horizontale de filtres par catégorie.
class CategoryFilterBar extends StatelessWidget {
  final Set<String> activeCategories;
  final void Function(String key) onToggle;
  final VoidCallback onSelectAll;
  final String lang;

  const CategoryFilterBar({
    super.key,
    required this.activeCategories,
    required this.onToggle,
    required this.onSelectAll,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    final allSelected = activeCategories.length == Categories.all.length;

    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: [
          // Bouton "Tous"
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: FilterChip(
              label: const Text('Tous'),
              selected: allSelected,
              onSelected: (_) => onSelectAll(),
              selectedColor: Colors.black87,
              labelStyle: TextStyle(
                color: allSelected ? Colors.white : Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              backgroundColor: Colors.white,
              side: BorderSide.none,
              elevation: 2,
              padding: const EdgeInsets.symmetric(horizontal: 4),
            ),
          ),
          // Un chip par catégorie
          ...Categories.all.map((cat) {
            final active = activeCategories.contains(cat.key);
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: FilterChip(
                label: Text('${cat.emoji} ${cat.label(lang)}'),
                selected: active,
                onSelected: (_) => onToggle(cat.key),
                selectedColor: cat.color.withValues(alpha: 0.85),
                labelStyle: TextStyle(
                  color: active ? Colors.white : Colors.black87,
                  fontSize: 12,
                  fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                ),
                backgroundColor: Colors.white,
                side: BorderSide.none,
                elevation: 2,
                padding: const EdgeInsets.symmetric(horizontal: 4),
              ),
            );
          }),
        ],
      ),
    );
  }
}
