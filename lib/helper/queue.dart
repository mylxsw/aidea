import 'dart:async';
import 'dart:collection';

class QueueFinishedException implements Exception {
  final String message;
  QueueFinishedException(this.message);
}

/// 该队列以一定的时间间隔将队列中的元素传递给回调函数，实现平滑的队列处理
class GracefulQueue<T> {
  final Queue<T> _queue = Queue<T>();
  bool finished = false;
  Timer? _timer;

  void add(T item) {
    if (finished) {
      throw QueueFinishedException('Queue is finished');
    }

    _queue.add(item);
  }

  void dispose() {
    _timer?.cancel();
  }

  Future<void> listen(
      Duration duration, Function(List<T> items) callback) async {
    Completer<void> completer = Completer<void>();
    _timer = Timer.periodic(duration, (timer) {
      if (_queue.isNotEmpty) {
        List<T> items = [];
        for (var i = 0; i < _queue.length; i++) {
          items.add(_queue.removeFirst());
        }

        callback(items);
      } else if (finished) {
        // print(_queue.length);
        timer.cancel();
        completer.complete();
      }
    });

    return completer.future;
  }

  void finish() {
    finished = true;
  }
}
