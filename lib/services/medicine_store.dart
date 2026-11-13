import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/medicine.dart';

/// On-device storage for the first offline GP Health prototype.
/// This is convenience storage, not encrypted medical-record storage.
class MedicineStore {
  static const _storageKey = 'gp_health_medicines_v1';

  Future<List<Medicine>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => Medicine.fromJson(item as Map<String, dynamic>))
          .toList();
    } on FormatException {
      // Do not crash the app if a previous local value is damaged.
      return [];
    } on TypeError {
      return [];
    }
  }

  Future<void> save(List<Medicine> medicines) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(medicines.map((item) => item.toJson()).toList());
    final saved = await prefs.setString(_storageKey, encoded);
    if (!saved) throw StateError('Could not save medicine data on this device.');
  }
}
