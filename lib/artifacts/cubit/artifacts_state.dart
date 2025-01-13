part of 'artifacts_cubit.dart';

/// The status of the artifacts loading
enum ArtifactsStatus {
  /// Initial status
  initial,

  /// Loading artifacts
  loading,

  /// Downloading artifact
  downloading,

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
    this.downloadedFile,
  });

  /// The status of the artifacts loading
  final ArtifactsStatus status;

  /// The list of artifacts
  final List<Artifact> artifacts;

  /// The error message if any
  final String? error;

  /// The downloaded file if any
  final String? downloadedFile;

  @override
  List<Object?> get props => [status, artifacts, error, downloadedFile];

  /// Creates a copy of this state with the given fields replaced with new
  /// values
  ArtifactsState copyWith({
    ArtifactsStatus? status,
    List<Artifact>? artifacts,
    String? error,
    String? downloadedFile,
  }) {
    return ArtifactsState(
      status: status ?? this.status,
      artifacts: artifacts ?? this.artifacts,
      error: error ?? this.error,
      downloadedFile: downloadedFile ?? this.downloadedFile,
    );
  }
}
