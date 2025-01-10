import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stork_hub/app/app.dart';
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
    return BlocBuilder<LoginCubit, LoginState>(
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
                decoration: const InputDecoration(
                  labelText: 'API Key',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
            ],
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
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
                      const SnackBar(
                        content: Text('Please fill in all fields'),
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
                      const SnackBar(
                        content: Text('Please enter your password'),
                      ),
                    );
                    return;
                  }

                  final success = await context
                      .read<AppCubit>()
                      .unlockWithPassword(password);

                  if (!success && mounted) {
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                        content: Text('Invalid password'),
                      ),
                    );
                  }
                }
              },
              child: Text(state.hasSavedKey ? 'Unlock' : 'Login'),
            ),
            if (state.hasSavedKey) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (alertContext) {
                      return AlertDialog(
                        title: const Text('Reset API Key'),
                        content: const Text(
                          'Are you sure you want to reset your API key? '
                          'You will need to enter it again.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(alertContext),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              context.read<LoginCubit>().resetKey();
                              Navigator.pop(alertContext);
                            },
                            child: const Text('Reset'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('Reset API Key'),
              ),
            ],
          ],
        );
      },
    );
  }
}
