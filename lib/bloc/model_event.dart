part of 'model_bloc.dart';

@immutable
sealed class ModelEvent {}

class ModelsLoadEvent extends ModelEvent {}

class ModelLoadEvent extends ModelEvent {
  final String modelId;

  ModelLoadEvent(this.modelId);
}

class ModelCreateEvent extends ModelEvent {
  final AdminModelAddReq req;

  ModelCreateEvent(this.req);
}

class ModelUpdateEvent extends ModelEvent {
  final String modelId;
  final AdminModelUpdateReq req;

  ModelUpdateEvent(this.modelId, this.req);
}

class ModelDeleteEvent extends ModelEvent {
  final String modelId;

  ModelDeleteEvent(this.modelId);
}
