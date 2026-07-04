/// Normalisation de texte pour la recherche (POIs) — minuscules et sans
/// accents, pour que « eglise » trouve « Église Saint-Lambert ».
class TextNormalizer {
  TextNormalizer._();

  static const Map<String, String> _accents = {
    'à': 'a', 'â': 'a', 'ä': 'a', 'á': 'a', 'ã': 'a',
    'ç': 'c',
    'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
    'î': 'i', 'ï': 'i', 'í': 'i',
    'ô': 'o', 'ö': 'o', 'ó': 'o', 'õ': 'o',
    'ù': 'u', 'û': 'u', 'ü': 'u', 'ú': 'u',
    'ÿ': 'y',
    'ñ': 'n',
    'œ': 'oe', 'æ': 'ae',
  };

  static String normalize(String text) {
    final lower = text.toLowerCase();
    final buffer = StringBuffer();
    for (final rune in lower.runes) {
      final char = String.fromCharCode(rune);
      buffer.write(_accents[char] ?? char);
    }
    return buffer.toString();
  }

  /// Est-ce que [query] (saisie utilisateur) matche [candidate]?
  static bool matches(String candidate, String query) {
    final normalizedQuery = normalize(query.trim());
    if (normalizedQuery.isEmpty) return true;
    return normalize(candidate).contains(normalizedQuery);
  }
}
