/// Modèle Point — Représente un POI (Point d'Intérêt).
class Point {
  final String id;
  final String cityId;
  final Map<String, String> name;
  final double lat;
  final double lng;
  final int triggerRadiusM;
  final String type;
  final List<String> categories;
  final String? imageUrl;
  final Map<String, dynamic>? logistics;
  final bool isPublished;

  const Point({
    required this.id,
    required this.cityId,
    required this.name,
    required this.lat,
    required this.lng,
    this.triggerRadiusM = 40,
    this.type = 'building',
    this.categories = const [],
    this.imageUrl,
    this.logistics,
    this.isPublished = false,
  });

  factory Point.fromJson(Map<String, dynamic> json) {
    Map<String, String> parsedName;
    final rawName = json['name'];
    if (rawName is Map) {
      parsedName = rawName.map((k, v) => MapEntry(k.toString(), v.toString()));
    } else {
      parsedName = {'fr': rawName?.toString() ?? ''};
    }

    return Point(
      id: json['id'] as String,
      cityId: json['city_id'] as String? ?? '',
      name: parsedName,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      triggerRadiusM: json['trigger_radius_m'] as int? ?? 40,
      type: json['type'] as String? ?? 'building',
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      imageUrl: json['image_url'] as String?,
      logistics: json['logistics'] as Map<String, dynamic>?,
      isPublished: json['is_published'] as bool? ?? false,
    );
  }

  String localizedName(String lang) {
    return name[lang] ?? name['fr'] ?? name['en'] ?? name.values.first;
  }

  /// Première catégorie (pour la couleur principale).
  String get primaryCategory =>
      categories.isNotEmpty ? categories.first : 'histoire';
}
