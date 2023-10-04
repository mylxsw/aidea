import 'package:askaide/repo/cache_repo.dart';
import 'package:askaide/repo/settings_repo.dart';

class Cache {
  late final SettingRepository setting;
  late final CacheRepository cacheRepo;

  init(SettingRepository setting, CacheRepository cacheRepo) {
    this.setting = setting;
    this.cacheRepo = cacheRepo;
  }

  /// 单例
  static final Cache _instance = Cache._internal();
  Cache._internal();

  factory Cache() {
    return _instance;
  }

  Future<bool> boolGet({required String key}) async {
    var value = await cacheRepo.get(key);
    if (value == null || value.isEmpty || value == 'true') {
      return true;
    }

    return false;
  }

  Future<void> setBool({
    required String key,
    required bool value,
    Duration duration = const Duration(days: 1),
  }) async {
    await cacheRepo.set(key, value.toString(), duration);
  }
}
