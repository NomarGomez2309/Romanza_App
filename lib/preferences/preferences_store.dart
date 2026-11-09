import 'package:shared_preferences/shared_preferences.dart';

abstract interface class PreferencesStore {
  Future<String?> read();
  Future<void> write(String value);
}

class LocalPreferencesStore implements PreferencesStore {
  final _preferences = SharedPreferencesAsync();
  static const key = 'romanza.preferences.v2';
  @override
  Future<String?> read() => _preferences.getString(key);
  @override
  Future<void> write(String value) => _preferences.setString(key, value);
}

class MemoryPreferencesStore implements PreferencesStore {
  String? value;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String value) async {
    this.value = value;
  }
}
