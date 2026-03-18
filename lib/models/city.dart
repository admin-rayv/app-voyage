/// Modèle City — Représente une ville disponible dans l'app.
class City {
  final String id;
  final String slug;
  final Map<String, String> name;
  final String country;
  final String? region;
  final double centerLat;
  final double centerLng;
  final String timezone;
  final List<String> availableLanguages;
  final DateTime? createdAt;

  const City({
    required this.id,
    required this.slug,
    required this.name,
    required this.country,
    this.region,
    required this.centerLat,
    required this.centerLng,
    this.timezone = 'America/Toronto',
    this.availableLanguages = const ['fr', 'en'],
    this.createdAt,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    // Parse name JSONB — peut être Map ou String
    Map<String, String> parsedName;
    final rawName = json['name'];
    if (rawName is Map) {
      parsedName = rawName.map((k, v) => MapEntry(k.toString(), v.toString()));
    } else {
      parsedName = {'fr': rawName?.toString() ?? '', 'en': rawName?.toString() ?? ''};
    }

    return City(
      id: json['id'] as String,
      slug: json['slug'] as String? ?? '',
      name: parsedName,
      country: json['country'] as String? ?? 'CA',
      region: json['region'] as String?,
      centerLat: (json['center_lat'] as num).toDouble(),
      centerLng: (json['center_lng'] as num).toDouble(),
      timezone: json['timezone'] as String? ?? 'America/Toronto',
      availableLanguages: (json['available_languages'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          ['fr', 'en'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'slug': slug,
        'name': name,
        'country': country,
        'region': region,
        'center_lat': centerLat,
        'center_lng': centerLng,
        'timezone': timezone,
        'available_languages': availableLanguages,
      };

  /// Retourne le nom dans la langue demandée, avec fallback FR → EN → première dispo.
  String localizedName(String lang) {
    return name[lang] ?? name['fr'] ?? name['en'] ?? name.values.first;
  }

  @override
  String toString() => 'City($slug)';
}
