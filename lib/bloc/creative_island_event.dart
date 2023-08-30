part of 'creative_island_bloc.dart';

@immutable
abstract class CreativeIslandEvent {}

// class CreativeIslandSaveEvent extends CreativeIslandEvent {
//   final String itemId;
//   final Map<String, dynamic> arguments;
//   final String prompt;
//   final String answer;

//   CreativeIslandSaveEvent(
//     this.itemId, {
//     this.arguments = const {},
//     this.prompt = '',
//     this.answer = '',
//   });
// }

class CreativeIslandItemLoadEvent extends CreativeIslandEvent {
  final String itemId;
  CreativeIslandItemLoadEvent(this.itemId);
}

class CreativeIslandHistoriesAllLoadEvent extends CreativeIslandEvent {
  final bool forceRefresh;
  final String mode;
  CreativeIslandHistoriesAllLoadEvent(
      {this.forceRefresh = false, required this.mode});
}

class CreativeIslandGalleryLoadEvent extends CreativeIslandEvent {
  final bool forceRefresh;
  final String mode;
  final String? model;
  CreativeIslandGalleryLoadEvent({
    this.forceRefresh = false,
    required this.mode,
    this.model,
  });
}

class CreativeIslandHistoriesLoadEvent extends CreativeIslandEvent {
  final String itemId;
  final bool forceRefresh;
  CreativeIslandHistoriesLoadEvent(this.itemId, {this.forceRefresh = false});
}

class CreativeIslandDeleteEvent extends CreativeIslandEvent {
  final String itemId;
  final int id;
  final String source;
  final String mode;

  CreativeIslandDeleteEvent(this.itemId, this.id,
      {this.source = '', required this.mode});
}

class CreativeIslandListLoadEvent extends CreativeIslandEvent {
  final String mode;

  CreativeIslandListLoadEvent({required this.mode});
}

class CreativeIslandHistoryItemLoadEvent extends CreativeIslandEvent {
  final int itemId;
  final bool forceRefresh;
  CreativeIslandHistoryItemLoadEvent(this.itemId, {this.forceRefresh = false});
}

class CreativeIslandItemsV2LoadEvent extends CreativeIslandEvent {
  final bool forceRefresh;
  CreativeIslandItemsV2LoadEvent({this.forceRefresh = false});
}
