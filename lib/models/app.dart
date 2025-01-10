import 'package:equatable/equatable.dart';

/// Represents a Stork application.
class App extends Equatable {
  /// Creates a new [App] instance.
  const App({
    required this.id,
    required this.name,
    this.publicMetadata = false,
  });

  /// The unique identifier of the app.
  final int id;

  /// The name of the app.
  final String name;

  /// Whether this app has public metadata.
  final bool publicMetadata;

  @override
  List<Object?> get props => [id, name, publicMetadata];
}
