part of 'free_statistics_bloc.dart';

@immutable
sealed class FreeStatisticsState {}

final class FreeStatisticsInitial extends FreeStatisticsState {}

final class FreeStatisticsLoading extends FreeStatisticsState {}

final class FreeStatisticsLoaded extends FreeStatisticsState {
  final List<FreeModelCount> freeStatistics;

  FreeStatisticsLoaded({required this.freeStatistics});
}
