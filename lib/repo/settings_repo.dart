import 'package:askaide/repo/data/settings_data.dart';

class SettingRepository {
  final SettingDataProvider _dataProvider;

  SettingRepository(this._dataProvider) {
    _dataProvider.loadSettings();
  }

  void listen(
      Function(SettingDataProvider settings, String key, String value)
          listener) {
    _dataProvider.listen(listener);
  }

  Future<void> set(String key, String value) async {
    return await _dataProvider.set(key, value);
  }

  String? get(String key) {
    return _dataProvider.get(key);
  }

  String stringDefault(String key, String defaultValue) {
    return _dataProvider.getDefault(key, defaultValue);
  }

  int intDefault(String key, int defaultValue) {
    return _dataProvider.getDefaultInt(key, defaultValue);
  }

  bool boolDefault(String key, bool defaultValue) {
    return _dataProvider.getDefaultBool(key, defaultValue);
  }

  double doubleDefault(String key, double defaultValue) {
    return _dataProvider.getDefaultDouble(key, defaultValue);
  }
}
