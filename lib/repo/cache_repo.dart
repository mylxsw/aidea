import 'dart:async';

import 'package:askaide/repo/data/cache_data.dart';

class CacheRepository {
  final CacheDataProvider cacheProvider;
  var lastGC = DateTime.now();

  CacheRepository(this.cacheProvider);

  Future<void> set(
    String key,
    String value,
    Duration ttl, {
    String? group,
  }) async {
    return cacheProvider.set(key, value, ttl, group: group);
  }

  Future<String?> get(String key) async {
    if (DateTime.now().difference(lastGC) > const Duration(minutes: 10)) {
      cacheProvider.gc().whenComplete(() {
        lastGC = DateTime.now();
      });
    }

    return cacheProvider.get(key);
  }

  Future<Map<String, String>> getAllInGroup(String group) async {
    return cacheProvider.getAllInGroup(group);
  }

  Future<void> remove(String key) async {
    return cacheProvider.remove(key);
  }

  Future<void> clearAll() async {
    return cacheProvider.clearAll();
  }
}
