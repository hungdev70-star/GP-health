class DoseEvent {
  const DoseEvent({
    required this.id,
    required this.medicineId,
    required this.medicineName,
    required this.status,
    required this.recordedAt,
  });

  final String id;
  final String medicineId;
  final String medicineName;
  final String status; // taken or skipped
  final DateTime recordedAt;

  Map<String, Object?> toJson() => {
    'id': id,
    'medicineId': medicineId,
    'medicineName': medicineName,
    'status': status,
    'recordedAt': recordedAt.toIso8601String(),
  };

  factory DoseEvent.fromJson(Map<String, dynamic> json) => DoseEvent(
    id: json['id'] as String,
    medicineId: json['medicineId'] as String,
    medicineName: json['medicineName'] as String,
    status: json['status'] as String,
    recordedAt: DateTime.parse(json['recordedAt'] as String),
  );
}
