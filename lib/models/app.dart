import 'package:equatable/equatable.dart';

/// Represents a Stork application.
class App extends Equatable {
  /// Creates a new [App] instance.
  const App({
    required this.id,
    required this.name,
  });

  /// The unique identifier of the app.
  final int id;

  /// The name of the app.
  final String name;

  @override
  List<Object?> get props => [id, name];
}
