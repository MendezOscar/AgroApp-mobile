class CropImageEntity {
  final String id;
  final String cropId;
  final String url;
  final String storageKey;
  final String? category;
  final String? aiDiagnosis;
  final DateTime? takenAt;
  final DateTime createdAt;

  const CropImageEntity({
    required this.id,
    required this.cropId,
    required this.url,
    required this.storageKey,
    this.category,
    this.aiDiagnosis,
    this.takenAt,
    required this.createdAt,
  });
}
