part of 'version_bloc.dart';

@immutable
abstract class VersionState {}

class VersionInitial extends VersionState {}

class VersionCheckLoaded extends VersionState {
  final VersionCheckResp version;

  VersionCheckLoaded(this.version);
}
