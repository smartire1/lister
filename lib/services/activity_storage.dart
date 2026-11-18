import 'dart:convert';

import 'package:lister/models/activity.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActivityStorage {
  static const _key = 'activities';
  final _preferences = SharedPreferencesAsync();

  Future<List<Activity>> load() async {
    final data = await _preferences.getString(_key);
    if (data == null) return [];

    try {
      final items = jsonDecode(data) as List<dynamic>;
      return items
          .map((item) => Activity.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> save(List<Activity> activities) async {
    final data = jsonEncode(
      activities.map((activity) => activity.toJson()).toList(),
    );
    await _preferences.setString(_key, data);
  }
}
