import 'package:equatable/equatable.dart';
import 'package:stork_hub/models/models.dart';

enum HomeStatus {
  initial,
  loading,
  loaded,
  error,
}

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.apps = const [],
    this.error,
  });

  final HomeStatus status;
  final List<App> apps;
  final String? error;

  @override
  List<Object?> get props => [status, apps, error];

  HomeState copyWith({
    HomeStatus? status,
    List<App>? apps,
    String? error,
  }) {
    return HomeState(
      status: status ?? this.status,
      apps: apps ?? this.apps,
      error: error ?? this.error,
    );
  }
}
