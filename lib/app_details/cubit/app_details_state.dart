import 'package:equatable/equatable.dart';
import 'package:stork_hub/models/models.dart';

/// The status of the app details page
enum AppDetailsStatus {
  /// Initial status
  initial,

  /// Loading app details
  loading,

  /// App details loaded successfully
  loaded,

  /// Error loading app details
  error,
}

/// {@template app_details_state}
/// The state of the app details page
/// {@endtemplate}
class AppDetailsState extends Equatable {
  /// {@macro app_details_state}
  const AppDetailsState({
    this.status = AppDetailsStatus.initial,
    this.app,
    this.error,
    this.versions = const [],
  });

  /// The status of the app details page
  final AppDetailsStatus status;

  /// The app being displayed
  final App? app;

  /// The error message if any
  final String? error;

  /// The list of versions for this app
  final List<Version> versions;

  @override
  List<Object?> get props => [status, app, error, versions];

  /// Creates a copy of this state with the given fields replaced with new
  /// values
  AppDetailsState copyWith({
    AppDetailsStatus? status,
    App? app,
    String? error,
    List<Version>? versions,
  }) {
    return AppDetailsState(
      status: status ?? this.status,
      app: app ?? this.app,
      error: error ?? this.error,
      versions: versions ?? this.versions,
    );
  }
}
