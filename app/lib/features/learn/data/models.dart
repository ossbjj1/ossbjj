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
    final id = json['id'] as String?;
    final category = json['category'] as String?;
    final titleEn = json['title_en'] as String?;
    final titleDe = json['title_de'] as String?;
    final displayOrderRaw = json['display_order'];

    if (id == null ||
        category == null ||
        titleEn == null ||
        titleDe == null ||
        displayOrderRaw == null) {
      throw FormatException(
          'TechniqueDto.fromJson: missing required field(s) in $json');
    }

    final displayOrder = (displayOrderRaw is num)
        ? displayOrderRaw.toInt()
        : int.parse(displayOrderRaw.toString());

    return TechniqueDto(
      id: id,
      category: category,
      titleEn: titleEn,
      titleDe: titleDe,
      displayOrder: displayOrder,
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
    // Validate required keys
    final id = json['id'] as String?;
    final techniqueId = json['technique_id'] as String?;
    final variant = json['variant'] as String?;
    final idxRaw = json['idx'];
    final titleEn = json['title_en'] as String?;
    final titleDe = json['title_de'] as String?;
    final durationSRaw = json['duration_s'];

    if (id == null ||
        techniqueId == null ||
        variant == null ||
        idxRaw == null ||
        titleEn == null ||
        titleDe == null ||
        durationSRaw == null) {
      throw FormatException(
          'TechniqueStepDto.fromJson: missing required field(s) in $json');
    }

    // Coerce numeric fields
    final idx = (idxRaw is num) ? idxRaw.toInt() : int.parse(idxRaw.toString());
    final durationS = (durationSRaw is num)
        ? durationSRaw.toInt()
        : int.parse(durationSRaw.toString());

    return TechniqueStepDto(
      id: id,
      techniqueId: techniqueId,
      variant: variant,
      idx: idx,
      titleEn: titleEn,
      titleDe: titleDe,
      durationS: durationS,
    );
  }
}
