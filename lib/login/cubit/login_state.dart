part of 'login_cubit.dart';

class LoginState extends Equatable {
  const LoginState({
    this.hasSavedKey = false,
    this.loading = false,
  });

  final bool hasSavedKey;
  final bool loading;

  LoginState copyWith({
    bool? hasSavedKey,
    bool? loading,
  }) {
    return LoginState(
      hasSavedKey: hasSavedKey ?? this.hasSavedKey,
      loading: loading ?? this.loading,
    );
  }

  @override
  List<Object?> get props => [hasSavedKey, loading];
}
