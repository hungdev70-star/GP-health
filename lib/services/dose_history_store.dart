import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/dose_event.dart';

/// Stores a local, on-device record of actions users report for each dose.
/// This is a self-reported log, not proof that a medicine was taken.
class DoseHistoryStore {
  static const _key = 'gp_health_dose_history_v1';

  Future<List<DoseEvent>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => DoseEvent.fromJson(item as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    } on FormatException {
      return [];
    } on TypeError {
      return [];
    }
  }

  Future<void> add(DoseEvent event) async {
    final events = await load();
    events.insert(0, event);
    // Keep the latest 500 entries to prevent unbounded local growth.
    final retained = events.take(500).map((item) => item.toJson()).toList();
    final prefs = await SharedPreferences.getInstance();
    final saved = await prefs.setString(_key, jsonEncode(retained));
    if (!saved) throw StateError('Could not save dose history on this device.');
  }
}
