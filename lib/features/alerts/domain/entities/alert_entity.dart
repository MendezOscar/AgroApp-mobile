class AlertEntity {
  final String id;
  final String? deviceId;
  final String? plotId;
  final String alertType;
  final String severity;
  final String message;
  final bool isRead;
  final DateTime triggeredAt;
  final DateTime? readAt;

  const AlertEntity({
    required this.id,
    this.deviceId,
    this.plotId,
    required this.alertType,
    required this.severity,
    required this.message,
    required this.isRead,
    required this.triggeredAt,
    this.readAt,
  });
}
