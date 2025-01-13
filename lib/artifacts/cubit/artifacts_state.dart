part of 'artifacts_cubit.dart';

/// The status of the artifacts loading
enum ArtifactsStatus {
  /// Initial status
  initial,

  /// Loading artifacts
  loading,

  /// Artifacts loaded successfully
  loaded,

  /// Error loading artifacts
  error,
}

/// {@template artifacts_state}
/// The state of the artifacts dialog
/// {@endtemplate}
class ArtifactsState extends Equatable {
  /// {@macro artifacts_state}
  const ArtifactsState({
    this.status = ArtifactsStatus.initial,
    this.artifacts = const [],
    this.error,
  });

  /// The status of the artifacts loading
  final ArtifactsStatus status;

  /// The list of artifacts
  final List<Artifact> artifacts;

  /// The error message if any
  final String? error;

  @override
  List<Object?> get props => [status, artifacts, error];

  /// Creates a copy of this state with the given fields replaced with new
  /// values
  ArtifactsState copyWith({
    ArtifactsStatus? status,
    List<Artifact>? artifacts,
    String? error,
  }) {
    return ArtifactsState(
      status: status ?? this.status,
      artifacts: artifacts ?? this.artifacts,
      error: error ?? this.error,
    );
  }
}
