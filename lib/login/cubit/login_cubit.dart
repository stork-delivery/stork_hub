import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:stork_hub/repositories/api_key_repository.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit({
    required ApiKeyRepository apiKeyRepository,
  })  : _apiKeyRepository = apiKeyRepository,
        super(const LoginState());

  final ApiKeyRepository _apiKeyRepository;

  Future<void> load() async {
    emit(state.copyWith(loading: true));

    final hasKey = await _apiKeyRepository.hasApiKey();
    emit(
      state.copyWith(
        hasSavedKey: hasKey,
        loading: false,
      ),
    );
  }

  Future<void> resetKey() async {
    emit(state.copyWith(loading: true));

    await _apiKeyRepository.deleteApiKey();
    emit(
      state.copyWith(
        hasSavedKey: false,
        loading: false,
      ),
    );
  }
}
