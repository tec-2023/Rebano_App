enum PrayerCategory {
  health('Salud', '🩺'),
  family('Familia', '👨‍👩‍👧‍👦'),
  finances('Finanzas y Empleo', '💼'),
  spiritual('Vida Espiritual', '🕊️'),
  ministry('Ministerio', '⛪'),
  praise('Acción de Gracias', '🙌');

  final String label;
  final String emoji;

  const PrayerCategory(this.label, this.emoji);

  static PrayerCategory fromString(String val) {
    return PrayerCategory.values.firstWhere(
      (c) => c.name.toLowerCase() == val.toLowerCase() || c.label.toLowerCase() == val.toLowerCase(),
      orElse: () => PrayerCategory.health,
    );
  }
}

class PrayerRequest {
  final String id;
  final String churchId;
  final String authorName;
  final String? authorAvatar;
  final String title;
  final String description;
  final PrayerCategory category;
  final DateTime createdAt;
  final bool isAnswered;
  final DateTime? answeredAt;
  final String? testimony;
  final int prayingCount;
  final bool isUserPraying;
  final bool isAnonymous;

  const PrayerRequest({
    required this.id,
    required this.churchId,
    required this.authorName,
    this.authorAvatar,
    required this.title,
    required this.description,
    required this.category,
    required this.createdAt,
    this.isAnswered = false,
    this.answeredAt,
    this.testimony,
    this.prayingCount = 0,
    this.isUserPraying = false,
    this.isAnonymous = false,
  });

  PrayerRequest copyWith({
    String? id,
    String? churchId,
    String? authorName,
    String? authorAvatar,
    String? title,
    String? description,
    PrayerCategory? category,
    DateTime? createdAt,
    bool? isAnswered,
    DateTime? answeredAt,
    String? testimony,
    int? prayingCount,
    bool? isUserPraying,
    bool? isAnonymous,
  }) {
    return PrayerRequest(
      id: id ?? this.id,
      churchId: churchId ?? this.churchId,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      isAnswered: isAnswered ?? this.isAnswered,
      answeredAt: answeredAt ?? this.answeredAt,
      testimony: testimony ?? this.testimony,
      prayingCount: prayingCount ?? this.prayingCount,
      isUserPraying: isUserPraying ?? this.isUserPraying,
      isAnonymous: isAnonymous ?? this.isAnonymous,
    );
  }
}
