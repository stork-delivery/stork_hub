import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:stork_hub/repositories/api_key_repository.dart';

part 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit({
    required ApiKeyRepository apiKeyRepository,
  })  : _apiKeyRepository = apiKeyRepository,
        super(const AppState());

  final ApiKeyRepository _apiKeyRepository;

  void setApiKey(String? apiKey) => emit(AppState(apiKey: apiKey));

  /// Saves the API key with encryption and updates the state
  Future<void> saveAndSetApiKey({
    required String apiKey,
    required String password,
  }) async {
    await _apiKeyRepository.saveApiKey(
      apiKey: apiKey,
      password: password,
    );

    setApiKey(apiKey);
  }
}
