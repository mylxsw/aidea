class GlobalEvent {
  /// 单例
  static final GlobalEvent _instance = GlobalEvent._internal();
  GlobalEvent._internal();

  factory GlobalEvent() {
    return _instance;
  }

  /// 事件监听器
  final Map<String, List<Function(dynamic data)>> _listeners = {};

  /// 监听事件
  void on(String event, Function(dynamic data) callback) {
    if (_listeners[event] == null) {
      _listeners[event] = [];
    }

    _listeners[event]!.add(callback);
  }

  /// 触发事件
  void emit(String event, [dynamic data]) {
    if (_listeners[event] == null) {
      return;
    }

    for (var callback in _listeners[event]!) {
      callback(data);
    }
  }
}
