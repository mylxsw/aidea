part of 'creative_island_bloc.dart';

@immutable
abstract class CreativeIslandState {}

class CreativeIslandInitial extends CreativeIslandState {}

// class CreativeIslandSaved extends CreativeIslandState {
//   final String? _error;

//   CreativeIslandSaved({String? error}) : _error = error;

//   get error => _error;
// }

class CreativeIslandItemLoaded extends CreativeIslandState {
  final String? _error;
  final CreativeIslandItem item;

  CreativeIslandItemLoaded(this.item, {String? error}) : _error = error;

  get error => _error;
}

class CreativeIslandHistoriesLoading extends CreativeIslandInitial {}

class CreativeIslandHistoriesLoaded extends CreativeIslandState {
  final String? _error;
  final CreativeIslandItem island;
  final List<CreativeItemInServer> histories;

  CreativeIslandHistoriesLoaded(this.island, this.histories, {String? error})
      : _error = error;
  get error => _error;
}

class CreativeIslandGalleryLoaded extends CreativeIslandState {
  final String? _error;
  final List<CreativeItemInServer> items;

  CreativeIslandGalleryLoaded(this.items, {String? error}) : _error = error;
  get error => _error;
}

class CreativeIslandHistoriesAllLoaded extends CreativeIslandState {
  final String? _error;
  final List<CreativeItemInServer> histories;

  CreativeIslandHistoriesAllLoaded(this.histories, {String? error})
      : _error = error;
  get error => _error;
}

class CreativeIslandListLoaded extends CreativeIslandState {
  final Object? _error;
  final List<CreativeIslandItem> items;
  final List<String> categories;
  final String? backgroundImage;

  CreativeIslandListLoaded(
    this.items, {
    Object? error,
    required this.categories,
    this.backgroundImage,
  }) : _error = error;

  get error => _error;
}

class CreativeIslandHistoryItemLoading extends CreativeIslandState {}

class CreativeIslandHistoryItemLoaded extends CreativeIslandState {
  final Object? error;
  final CreativeItemInServer? item;

  CreativeIslandHistoryItemLoaded({this.item, this.error});
}

class CreativeIslandItemsV2Loaded extends CreativeIslandState {
  final Object? error;
  final List<CreativeIslandItemV2> items;

  CreativeIslandItemsV2Loaded({required this.items, this.error});
}
