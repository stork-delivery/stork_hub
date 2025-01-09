import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stork_hub/login/login.dart';
import 'package:stork_hub/repositories/api_key_repository.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginCubit>(
      create: (context) => LoginCubit(
        apiKeyRepository: context.read<ApiKeyRepository>(),
      )..load(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Login'),
        ),
        body: const Padding(
          padding: EdgeInsets.all(16),
          child: LoginForm(),
        ),
      ),
    );
  }
}
