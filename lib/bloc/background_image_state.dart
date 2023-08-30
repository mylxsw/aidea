part of 'background_image_bloc.dart';

@immutable
abstract class BackgroundImageState {}

class BackgroundImageInitial extends BackgroundImageState {}

class BackgroundImageLoaded extends BackgroundImageState {
  final List<BackgroundImage> images;

  BackgroundImageLoaded(this.images);
}
