import 'package:askaide/repo/api_server.dart';
import 'package:askaide/repo/model/misc.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'background_image_event.dart';
part 'background_image_state.dart';

class BackgroundImageBloc
    extends Bloc<BackgroundImageEvent, BackgroundImageState> {
  BackgroundImageBloc() : super(BackgroundImageInitial()) {
    on<BackgroundImageLoadEvent>((event, emit) async {
      final images = await APIServer().backgrounds();
      emit(BackgroundImageLoaded(images));
    });
  }
}
