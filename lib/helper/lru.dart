import 'dart:collection';

abstract class Disposable {
  void dispose();
}

class LRUCache<K, V extends Disposable> {
  final int capacity;
  final LinkedHashMap<K, V> _cache = LinkedHashMap<K, V>();

  LRUCache(this.capacity);

  bool containsKey(K key) {
    return _cache.containsKey(key);
  }

  V? get(K key) {
    if (_cache.containsKey(key)) {
      final value = _cache.remove(key);
      if (value != null) {
        _cache[key] = value;
        return value;
      }
    }
    return null;
  }

  void put(K key, V value) {
    if (_cache.containsKey(key)) {
      _cache.remove(key);
    } else if (_cache.length >= capacity) {
      var removed = _cache.remove(_cache.keys.first);
      if (removed != null) {
        removed.dispose();
      }
    }
    _cache[key] = value;
  }

  void remove(K key) {
    var removed = _cache.remove(key);
    if (removed != null) {
      removed.dispose();
    }
  }

  void clear() {
    _cache.forEach((_, value) => value.dispose());
    _cache.clear();
  }

  int get length => _cache.length;
}
