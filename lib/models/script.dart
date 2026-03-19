/// Modèle Script — Contenu audio d'un POI dans une langue.
class Script {
  final String id;
  final String pointId;
  final String language;
  final String content;
  final String persona;
  final int? wordCount;
  final int? estimatedDurationSec;

  const Script({
    required this.id,
    required this.pointId,
    required this.language,
    required this.content,
    this.persona = 'marco',
    this.wordCount,
    this.estimatedDurationSec,
  });

  factory Script.fromJson(Map<String, dynamic> json) {
    return Script(
      id: json['id'] as String,
      pointId: json['point_id'] as String,
      language: json['language'] as String,
      content: json['content'] as String,
      persona: json['persona'] as String? ?? 'marco',
      wordCount: json['word_count'] as int?,
      estimatedDurationSec: json['estimated_duration_sec'] as int?,
    );
  }
}
