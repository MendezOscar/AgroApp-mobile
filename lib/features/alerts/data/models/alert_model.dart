import '../../domain/entities/alert_entity.dart';

class AlertModel extends AlertEntity {
  const AlertModel({
    required super.id,
    super.deviceId,
    super.plotId,
    required super.alertType,
    required super.severity,
    required super.message,
    required super.isRead,
    required super.triggeredAt,
    super.readAt,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) => AlertModel(
        id: json['id'],
        deviceId: json['deviceId'],
        plotId: json['plotId'],
        alertType: json['alertType'],
        severity: json['severity'],
        message: json['message'],
        isRead: json['isRead'],
        triggeredAt: DateTime.parse(json['triggeredAt']),
        readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
      );
}
