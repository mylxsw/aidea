import 'package:sqflite/sqflite.dart';

class SettingDataProvider {
  Database conn;

  SettingDataProvider(this.conn);

  final _settings = <String, String>{};
  final _listeners =
      <Function(SettingDataProvider settings, String key, String value)>[];

  Future<void> loadSettings() async {
    List<Map<String, Object?>> kvs = await conn.query('settings');

    _settings.clear();
    for (var kv in kvs) {
      _settings[kv['key'] as String] = kv['value'] as String;
    }
  }

  void listen(
      Function(SettingDataProvider settings, String key, String value)
          listener) {
    _listeners.add(listener);
  }

  Future<void> set(String key, String value) async {
    _settings[key] = value;
    final kvs =
        await conn.query('settings', where: 'key = ?', whereArgs: [key]);
    if (kvs.isEmpty) {
      await conn.insert('settings', {'key': key, 'value': value});
    } else {
      await conn.update('settings', {'value': value},
          where: 'key = ?', whereArgs: [key]);
    }

    for (var f in _listeners) {
      f(this, key, value);
    }
  }

  String? get(String key) {
    return _settings[key];
  }

  String getDefault(String key, String defaultValue) {
    return _settings[key] ?? defaultValue;
  }

  int getDefaultInt(String key, int defaultValue) {
    return int.tryParse(_settings[key] ?? '') ?? defaultValue;
  }

  bool getDefaultBool(String key, bool defaultValue) {
    return _settings[key] == 'true' ? true : defaultValue;
  }

  double getDefaultDouble(String key, double defaultValue) {
    return double.tryParse(_settings[key] ?? '') ?? defaultValue;
  }
}
