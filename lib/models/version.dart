import 'package:equatable/equatable.dart';

/// {@template version}
/// A model representing a version of an app.
/// {@endtemplate}
class Version extends Equatable {
  /// {@macro version}
  const Version({
    required this.id,
    required this.appId,
    required this.version,
    required this.changelog,
  });

  /// The id of the version
  final int id;

  /// The id of the app this version belongs to
  final int appId;

  /// The version string
  final String version;

  /// The changelog for this version
  final String changelog;

  @override
  List<Object?> get props => [id, appId, version, changelog];
}
