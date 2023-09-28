import 'package:askaide/repo/api_server.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'free_statistics_event.dart';
part 'free_statistics_state.dart';

class FreeStatisticsBloc
    extends Bloc<FreeStatisticsEvent, FreeStatisticsState> {
  FreeStatisticsBloc() : super(FreeStatisticsInitial()) {
    /// 加载免费统计数据
    on<FreeStatisticsLoadEvent>((event, emit) async {
      emit(FreeStatisticsLoading());

      final res = await APIServer().userFreeStatistics();
      emit(FreeStatisticsLoaded(freeStatistics: res));
    });
  }
}
