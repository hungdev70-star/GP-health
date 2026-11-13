import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/family_contact.dart';

class ContactStore {
  static const _storageKey = 'gp_health_family_contacts_v1';

  Future<List<FamilyContact>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final data = jsonDecode(raw) as List<dynamic>;
      return data.map((item) => FamilyContact.fromJson(item as Map<String, dynamic>)).toList();
    } on FormatException {
      return [];
    } on TypeError {
      return [];
    }
  }

  Future<void> save(List<FamilyContact> contacts) async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(contacts.map((item) => item.toJson()).toList());
    final saved = await prefs.setString(_storageKey, data);
    if (!saved) throw StateError('Could not save family contacts on this device.');
  }
}
