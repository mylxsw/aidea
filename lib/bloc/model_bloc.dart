import 'package:askaide/repo/api/admin/models.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'model_event.dart';
part 'model_state.dart';

class ModelBloc extends Bloc<ModelEvent, ModelState> {
  ModelBloc() : super(ModelInitial()) {
    /// 加载所有模型
    on<ModelsLoadEvent>((event, emit) async {
      final channels = await APIServer().adminModels();
      emit(ModelsLoaded(channels));
    });

    /// 加载单个模型
    on<ModelLoadEvent>((event, emit) async {
      final channel = await APIServer().adminModel(modelId: event.modelId);
      emit(ModelLoaded(channel));
    });

    /// 创建模型
    on<ModelCreateEvent>((event, emit) async {
      try {
        await APIServer().adminCreateModel(event.req);
        emit(ModelOperationResult(true, '创建成功'));
      } catch (e) {
        emit(ModelOperationResult(false, e.toString()));
      }
    });

    /// 更新模型
    on<ModelUpdateEvent>((event, emit) async {
      try {
        await APIServer().adminUpdateModel(
          modelId: event.modelId,
          req: event.req,
        );
        emit(ModelOperationResult(true, '更新成功'));
      } catch (e) {
        emit(ModelOperationResult(false, e.toString()));
      }
    });

    /// 删除模型
    on<ModelDeleteEvent>((event, emit) async {
      try {
        await APIServer().adminDeleteModel(modelId: event.modelId);
        emit(ModelOperationResult(true, '删除成功'));
      } catch (e) {
        emit(ModelOperationResult(false, e.toString()));
      }
    });
  }
}
