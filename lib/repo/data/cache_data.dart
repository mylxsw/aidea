import 'package:sqflite/sqflite.dart';

class CacheDataProvider {
  Database conn;
  CacheDataProvider(this.conn);

  /// 设置缓存
  Future<void> set(
    String key,
    String value,
    Duration ttl, {
    String? group,
  }) async {
    await conn.delete('cache', where: 'key = ?', whereArgs: [key]);
    await conn.insert('cache', <String, Object?>{
      'key': key,
      'value': value,
      'group': group,
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'valid_before': DateTime.now().add(ttl).millisecondsSinceEpoch,
    });
  }

  Future<Map<String, String>> getAllInGroup(String group) async {
    List<Map<String, Object?>> cacheValue = await conn.query(
      'cache',
      where: '`group` = ? AND valid_before >= ?',
      whereArgs: [group, DateTime.now().millisecondsSinceEpoch],
    );

    if (cacheValue.isEmpty) {
      return {};
    }

    Map<String, String> ret = {};
    for (var item in cacheValue) {
      ret[item['key'] as String] = item['value'] as String;
    }

    return ret;
  }

  // 查询缓存值
  Future<String?> get(String key) async {
    List<Map<String, Object?>> cacheValue = await conn.query(
      'cache',
      where: 'key = ? AND valid_before >= ?',
      whereArgs: [key, DateTime.now().millisecondsSinceEpoch],
      limit: 1,
    );

    if (cacheValue.isEmpty) {
      return null;
    }

    return cacheValue.first['value'] as String;
  }

  /// 删除缓存
  Future<void> remove(String key) async {
    await conn.delete('cache', where: 'key = ?', whereArgs: [key]);
  }

  /// 清理过期 keys
  Future<void> gc() async {
    await conn.delete(
      'cache',
      where: 'valid_before < ?',
      whereArgs: [DateTime.now().millisecondsSinceEpoch],
    );
  }

  /// 清空所有缓存
  Future<void> clearAll() async {
    await conn.delete('cache');
  }
}
