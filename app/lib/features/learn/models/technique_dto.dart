/// Technique DTO (Sprint 4 MVP).
class TechniqueDto {
  const TechniqueDto({
    required this.id,
    required this.category,
    required this.titleEn,
    required this.titleDe,
    required this.displayOrder,
  });

  final String id;
  final String category;
  final String titleEn;
  final String titleDe;
  final int displayOrder;

  factory TechniqueDto.fromJson(Map<String, dynamic> json) {
    return TechniqueDto(
      id: json['id'] as String,
      category: json['category'] as String,
      titleEn: json['title_en'] as String,
      titleDe: json['title_de'] as String,
      displayOrder: json['display_order'] as int,
    );
  }
}

/// Technique Step DTO (Sprint 4 MVP).
class TechniqueStepDto {
  const TechniqueStepDto({
    required this.id,
    required this.techniqueId,
    required this.variant,
    required this.idx,
    required this.titleEn,
    required this.titleDe,
    required this.durationS,
  });

  final String id;
  final String techniqueId;
  final String variant; // "gi" | "nogi"
  final int idx;
  final String titleEn;
  final String titleDe;
  final int durationS;

  factory TechniqueStepDto.fromJson(Map<String, dynamic> json) {
    return TechniqueStepDto(
      id: json['id'] as String,
      techniqueId: json['technique_id'] as String,
      variant: json['variant'] as String,
      idx: json['idx'] as int,
      titleEn: json['title_en'] as String,
      titleDe: json['title_de'] as String,
      durationS: json['duration_s'] as int,
    );
  }
}
