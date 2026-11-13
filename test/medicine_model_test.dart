import 'package:flutter_test/flutter_test.dart';
import 'package:gp_health/models/medicine.dart';

void main() {
  group('Medicine model', () {
    test('serializes and restores all medicine fields', () {
      final original = Medicine(
        id: 'medicine-1',
        name: 'Morning tablet',
        time: '8:00 AM',
        note: 'After breakfast',
        taken: true,
      );

      final restored = Medicine.fromJson(original.toJson());

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.time, original.time);
      expect(restored.note, original.note);
      expect(restored.taken, isTrue);
    });

    test('defaults missing optional note and taken fields safely', () {
      final restored = Medicine.fromJson({
        'id': 'medicine-2',
        'name': 'Tablet',
        'time': '9:00 AM',
      });

      expect(restored.note, '');
      expect(restored.taken, isFalse);
    });
  });
}
