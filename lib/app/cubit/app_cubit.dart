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

  /// Attempts to unlock and set a previously saved API key
  Future<bool> unlockWithPassword(String password) async {
    final apiKey = await _apiKeyRepository.getApiKey(password: password);
    if (apiKey != null) {
      setApiKey(apiKey);
      return true;
    }
    return false;
  }
}
