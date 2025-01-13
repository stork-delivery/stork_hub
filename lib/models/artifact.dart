import 'package:equatable/equatable.dart';

/// {@template artifact}
/// A model representing an artifact of a version.
/// {@endtemplate}
class Artifact extends Equatable {
  /// {@macro artifact}
  const Artifact({
    required this.id,
    required this.versionId,
    required this.name,
    required this.platform,
  });

  /// The unique identifier of the artifact.
  final int id;

  /// The version ID this artifact belongs to.
  final int versionId;

  /// The name of the artifact.
  final String name;

  /// The platform this artifact is for.
  final String platform;

  @override
  List<Object> get props => [id, versionId, name, platform];
}
