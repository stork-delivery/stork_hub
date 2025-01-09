part of 'app_cubit.dart';

class AppState extends Equatable {
  const AppState({
    this.apiKey,
  });

  final String? apiKey;

  @override
  List<Object?> get props => [apiKey];
}
