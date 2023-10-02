import 'package:askaide/helper/ability.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'free_count_event.dart';
part 'free_count_state.dart';

class FreeCountBloc extends Bloc<FreeCountEvent, FreeCountState> {
  List<FreeModelCount> counts = [];

  FreeCountBloc() : super(FreeCountInitial()) {
    // 重新加载所有的模型免费使用次数
    on<FreeCountReloadAllEvent>((event, emit) async {
      if (Ability().supportLocalOpenAI() || !Ability().supportAPIServer()) {
        emit(FreeCountLoadedState(counts: counts));
        return;
      }

      counts = await APIServer().userFreeStatistics();
      emit(FreeCountLoadedState(counts: counts));
    });

    // 重新加载指定模型的免费使用次数
    on<FreeCountReloadEvent>((event, emit) async {
      if (Ability().supportLocalOpenAI() || !Ability().supportAPIServer()) {
        emit(FreeCountLoadedState(counts: counts));
        return;
      }

      final freeCount = await APIServer()
          .userFreeStatisticsForModel(model: event.model.split(':').last);
      if (freeCount.maxCount > 0) {
        var matched = false;
        for (var i = 0; i < counts.length; i++) {
          if (counts[i].model == freeCount.model) {
            counts[i] = freeCount;
            matched = true;
            break;
          }
        }

        if (!matched) {
          counts.add(freeCount);
        }
      }

      emit(FreeCountLoadedState(counts: counts));
    });
  }
}
