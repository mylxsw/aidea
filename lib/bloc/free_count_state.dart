part of 'free_count_bloc.dart';

@immutable
sealed class FreeCountState {}

final class FreeCountInitial extends FreeCountState {}

class FreeCountLoadedState extends FreeCountState {
  final List<FreeModelCount> counts;
  final bool needSignin;

  FreeModelCount? model(String model) {
    model = model.split(':').last;
    for (var i = 0; i < counts.length; i++) {
      if (counts[i].model == model) {
        return counts[i];
      }
    }

    return null;
  }

  FreeCountLoadedState({required this.counts, this.needSignin = false});
}
