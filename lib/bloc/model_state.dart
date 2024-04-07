part of 'model_bloc.dart';

@immutable
sealed class ModelState {}

final class ModelInitial extends ModelState {}

class ModelsLoaded extends ModelState {
  final List<AdminModel> models;

  ModelsLoaded(this.models);
}

class ModelLoaded extends ModelState {
  final AdminModel model;

  ModelLoaded(this.model);
}

class ModelOperationResult extends ModelState {
  final bool success;
  final String message;

  ModelOperationResult(this.success, this.message);
}
