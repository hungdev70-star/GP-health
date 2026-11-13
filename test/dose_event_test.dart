import 'package:flutter_test/flutter_test.dart';
import 'package:gp_health/models/dose_event.dart';

void main() {
  test('dose event preserves status and timestamp through JSON', () {
    final recordedAt = DateTime.utc(2026, 11, 13, 9, 30);
    final original = DoseEvent(
      id: 'event-1',
      medicineId: 'medicine-1',
      medicineName: 'Morning tablet',
      status: 'skipped',
      recordedAt: recordedAt,
    );

    final restored = DoseEvent.fromJson(original.toJson());

    expect(restored.id, original.id);
    expect(restored.medicineId, original.medicineId);
    expect(restored.medicineName, original.medicineName);
    expect(restored.status, 'skipped');
    expect(restored.recordedAt, recordedAt);
  });
}
