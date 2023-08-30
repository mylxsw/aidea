part of 'gallery_bloc.dart';

@immutable
abstract class GalleryEvent {}

class GalleryLoadEvent extends GalleryEvent {
  final bool forceRefresh;
  final int page;

  GalleryLoadEvent({this.forceRefresh = false, this.page = 1});
}

class GalleryItemLoadEvent extends GalleryEvent {
  final int id;
  final bool forceRefresh;

  GalleryItemLoadEvent({required this.id, this.forceRefresh = false});
}
