import 'package:askaide/bloc/chat_message_bloc.dart';
import 'package:askaide/helper/lru.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatBlocManager {
  static final ChatBlocManager _singleton = ChatBlocManager._internal();

  factory ChatBlocManager() {
    return _singleton;
  }

  ChatBlocManager._internal();

  late final ChatMessageBloc Function(int roomId, {int? chatHistoryId})
      blocBuilder;
  init(ChatMessageBloc Function(int roomId, {int? chatHistoryId}) blocBuilder) {
    this.blocBuilder = blocBuilder;
  }

  final LRUCache<String, ChatMessageBloc> _blocs = LRUCache(10);

  ChatMessageBloc getBloc(int roomId, {int? chatHistoryId}) {
    final key = '$roomId-$chatHistoryId';
    if (_blocs.containsKey(key)) {
      return _blocs.get(key)!;
    } else {
      final bloc = blocBuilder(roomId, chatHistoryId: chatHistoryId);
      _blocs.put(key, bloc);

      return bloc;
    }
  }

  void dispose() {
    _blocs.clear();
  }
}

abstract class BlocExt<K, V> extends Bloc<K, V> implements Disposable {
  BlocExt(super.initialState);

  @override
  void dispose() {
    super.close();
  }

  @override
  Future<void> close() async {
    return;
  }
}
