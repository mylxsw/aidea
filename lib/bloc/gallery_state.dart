part of 'gallery_bloc.dart';

@immutable
abstract class GalleryState {}

class GalleryInitial extends GalleryState {}

class GalleryLoaded extends GalleryState {
  final PagedData<CreativeGallery> data;

  GalleryLoaded({required this.data});
}

class GalleryItemLoaded extends GalleryState {
  final CreativeGallery item;

  GalleryItemLoaded({required this.item});
}
