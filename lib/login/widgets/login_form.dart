import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stork_hub/app/app.dart';
import 'package:stork_hub/l10n/l10n.dart';
import 'package:stork_hub/login/login.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _apiKeyController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _apiKeyController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: BlocBuilder<LoginCubit, LoginState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!state.hasSavedKey) ...[
                TextField(
                  controller: _apiKeyController,
                  decoration: InputDecoration(
                    labelText: l10n.loginApiKeyLabel,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: l10n.loginPasswordLabel,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final password = _passwordController.text;
                  final scaffoldMessenger = ScaffoldMessenger.of(context);

                  if (!state.hasSavedKey) {
                    final apiKey = _apiKeyController.text;
                    if (apiKey.isEmpty || password.isEmpty) {
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text(l10n.loginFillAllFieldsMessage),
                        ),
                      );
                      return;
                    }

                    await context.read<AppCubit>().saveAndSetApiKey(
                          apiKey: apiKey,
                          password: password,
                        );
                  } else {
                    if (password.isEmpty) {
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text(l10n.loginEnterPasswordMessage),
                        ),
                      );
                      return;
                    }

                    final success = await context
                        .read<AppCubit>()
                        .unlockWithPassword(password);

                    if (!success && mounted) {
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text(l10n.loginInvalidPasswordMessage),
                        ),
                      );
                    }
                  }
                },
                child: Text(
                  state.hasSavedKey
                      ? l10n.loginUnlockButton
                      : l10n.loginLoginButton,
                ),
              ),
              if (state.hasSavedKey) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    showDialog<void>(
                      context: context,
                      builder: (alertContext) {
                        return AlertDialog(
                          title: Text(l10n.loginResetKeyDialogTitle),
                          content: Text(l10n.loginResetKeyDialogContent),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(alertContext),
                              child: Text(l10n.loginResetKeyDialogCancelButton),
                            ),
                            TextButton(
                              onPressed: () {
                                context.read<LoginCubit>().resetKey();
                                Navigator.pop(alertContext);
                              },
                              child: Text(l10n.loginResetKeyDialogResetButton),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text(l10n.loginResetKeyButton),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
