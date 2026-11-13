import 'package:flutter_test/flutter_test.dart';
import 'package:gp_health/models/family_contact.dart';

void main() {
  test('family contact preserves emergency selection when serialized', () {
    final contact = FamilyContact(
      id: 'contact-1',
      name: 'Asha',
      phone: '+919876543210',
      isEmergency: true,
    );

    final restored = FamilyContact.fromJson(contact.toJson());

    expect(restored.id, 'contact-1');
    expect(restored.name, 'Asha');
    expect(restored.phone, '+919876543210');
    expect(restored.isEmergency, isTrue);
  });
}
