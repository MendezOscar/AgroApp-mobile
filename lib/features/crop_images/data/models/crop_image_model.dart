import '../../domain/entities/crop_image_entity.dart';

class CropImageModel extends CropImageEntity {
  // URL base de tu bucket R2
  static const String _r2PublicUrl =
      'https://pub-ed63580e46a44b668d20f9aef764d2db.r2.dev'; // ← tu PublicUrl

  const CropImageModel({
    required super.id,
    required super.cropId,
    required super.url,
    required super.storageKey,
    super.category,
    super.aiDiagnosis,
    super.takenAt,
    required super.createdAt,
  });

  factory CropImageModel.fromJson(Map<String, dynamic> json) {
    final storageKey = json['storageKey'] as String;
    // Si la url ya es completa la usamos, si no construimos la URL pública
    final url = json['url'].toString().startsWith('http')
        ? json['url']
        : '$_r2PublicUrl/${json['storageKey']}';

    return CropImageModel(
      id: json['id'],
      cropId: json['cropId'],
      url: url,
      storageKey: storageKey,
      category: json['category'],
      aiDiagnosis: json['aiDiagnosis'],
      takenAt: json['takenAt'] != null ? DateTime.parse(json['takenAt']) : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
